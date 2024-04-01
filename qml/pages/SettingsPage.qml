import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property string response_status_text: "<not yet executed>"
    property string response_body: "<not yet executed>"

    Component.onCompleted: {
        address.text = settings.address
        username.text = settings.username
        password.text = settings.password
        switch (settings.autoRefreshIntervalMs) {
        case 0:
            comboAutoRefreshIntervalMs.currentIndex = 0
            switchShowAutoRefreshTimer.enabled = false
            break
        case 5000:
            comboAutoRefreshIntervalMs.currentIndex = 1
            break
        case 30000:
            comboAutoRefreshIntervalMs.currentIndex = 2
            break
        case 60000:
            comboAutoRefreshIntervalMs.currentIndex = 3
            break
        case 120000:
            comboAutoRefreshIntervalMs.currentIndex = 4
            break
        case 300000:
            comboAutoRefreshIntervalMs.currentIndex = 5
            break
        case 1200000:
            comboAutoRefreshIntervalMs.currentIndex = 6
            break
        }

    }
    Component.onDestruction: {
        settings.address = address.text
        settings.username = username.text
        settings.password = password.text
        settings.showAutoRefreshTimer = switchShowAutoRefreshTimer.checked
        settings.sync()
    }

    function resetConnectionTestResult() {
        settingsPage.response_status_text = ""
        settingsPage.response_body = ""
    }

    Column {
        id: column
        width: settingsPage.width
        spacing: Theme.paddingMedium
        anchors.fill: parent
        PageHeader {
            title: qsTr("Settings")
        }
        SectionHeader {
            text: "Power Strip Connection"
        }
        TextField {
            id: address
            inputMethodHints: Qt.ImhUrlCharactersOnly + Qt.ImhNoAutoUppercase
            label: "Power strip IP or hostname"
        }
        Label {
            x: Theme.horizontalPageMargin
            font.pixelSize: Theme.fontSizeMedium
            text: "Base URL: http://" + address.text + "/"
        }
        TextField {
            id: username
            inputMethodHints: Qt.ImhNoAutoUppercase
            validator: RegExpValidator{ regExp: /.{1,}/ }
            label: "Username"
        }
        PasswordField {
            id: password
            validator: RegExpValidator{ regExp: /.{1,}/ }
            label: "Password"
        }
        ComboBox {
            id: comboAutoRefreshIntervalMs
            width: 480
            label: "Auto refresh interval"

            menu: ContextMenu {
                MenuItem {
                    text: "disabled"
                    onClicked: settings.autoRefreshIntervalMs = 0
                }
                MenuItem {
                    text: "5s"
                    onClicked: settings.autoRefreshIntervalMs = 5 * 1000
                }
                MenuItem {
                    text: "30s"
                    onClicked: settings.autoRefreshIntervalMs = 30 * 1000
                }
                MenuItem {
                    text: "1m"
                    onClicked: settings.autoRefreshIntervalMs = 60 * 1000
                }
                MenuItem {
                    text: "2m"
                    onClicked: settings.autoRefreshIntervalMs = 120 * 1000
                }
                MenuItem {
                    text: "5m"
                    onClicked: settings.autoRefreshIntervalMs = 300 * 1000
                }
                MenuItem {
                    text: "30m"
                    onClicked: settings.autoRefreshIntervalMs = 1800 * 1000
                }
            }
            onCurrentIndexChanged: {
                switchShowAutoRefreshTimer.enabled = currentIndex > 0
                autoRefreshTimer.stop()
                autoRefreshTimer.start()
            }
        }
        TextSwitch {
            id: switchShowAutoRefreshTimer
            checked: settings.showAutoRefreshTimer
            text: "Show auto refresh timer"
        }

        SectionHeader {
            text: "Connection Test"
        }
        Button {
            text: "Test connection"
            anchors.horizontalCenter: parent.horizontalCenter
            x: Theme.horizontalPageMargin
            onClicked: {
                resetConnectionTestResult()
                response_column.visible = true
                var request = new XMLHttpRequest();
                settingsPage.response_status_text = "Waiting for response..."
                testRequestIndicator.visible = true
                testRequestIndicator.running = true
                request.onreadystatechange = (function(req) {
                    return function() {
                        if (req.readyState === XMLHttpRequest.DONE) {

                            testRequestIndicator.running = false
                            testRequestIndicator.visible = false

                            if (!request.response) {
                                errorMessage.visible = true
                                settingsPage.response_status_text = ""
                                return
                            } else {
                                errorMessage.visible = false
                            }
                            console.log("response: " + req.response)
                            settingsPage.response_status_text = req.status + " " + req.statusText
                            settingsPage.response_body = req.responseText
                        }
                    }
                })(request);
                var credentials = Qt.btoa(settings.username + settings.password)
                request.open('GET', 'http://' + address.text + '?Stat=' + credentials, true)
                request.send('\n\n')
            }
        }
        Column {
            id: response_column
            visible: false
            width: parent.width
            //spacing: Theme.paddingMedium
            SectionHeader {
                text: "Response Status"
            }
            Row {
                id: errorMessage
                visible: false
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                Icon {
                    id: errorIcon
                    color: Theme.errorColor
                    source: "image://theme/icon-splus-error"
                }
                Label {
                    id: labelErrorMessage
                    color: Theme.errorColor
                    text: "Request to GET status failed"
                }
            }
            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                BusyIndicator {
                    visible: false
                    id: testRequestIndicator
                }
                Label {
                    text: settingsPage.response_status_text
                }
            }
            SectionHeader {
                text: "Response Body"
            }
            Label {
                x: Theme.horizontalPageMargin
                width: response_column.width - (2 * Theme.horizontalPageMargin)
                wrapMode: Text.WrapAnywhere
                text: settingsPage.response_body
            }
        }
    }
}
