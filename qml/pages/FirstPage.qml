import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../netpwrctrl.js" as NetPwrCtrl


Page {
    id: page
    allowedOrientations: Orientation.All

    property bool initialized: false;
    property bool isUpdatingUi: false;
    property var updateState: updateState

    function updateState() {
        console.log("updating power strip and outlet states");
        var request = new XMLHttpRequest();
        request.onreadystatechange = (function(req) {
            return function() {
                if (req.readyState === XMLHttpRequest.DONE) {

                    if (!request.response) {
                        console.log("request failed")
                        errorMessage.visible = true
                        return
                    } else {
                        errorMessage.visible = false
                    }

                    var responseSections = request.response.split('<br>')
                    var stripInfos = responseSections[0].split(';')
                    var outletInfos = responseSections[1].split(';')

                    console.log("outletInfos.length: " + outletInfos.length)
                    isUpdatingUi = true

                    // -1 because of trailing ';'
                    // +3 and /3 because there are 3 values for every outlet
                    for (var i = 0; i < outletInfos.length-1; i+=3) {
                        var name = outletInfos[i]
                        var state = outletInfos[i+1]
                        var outletIndex = i/3
                        console.log(name)
                        // in the combobox 0=on, 1=off
                        var selectionIndex; // default off
                        if (state === "0") {
                            selectionIndex = 1
                        } else {
                            selectionIndex = 0;
                        }
                        if (initialized == false) {
                            outletStates.append({'label': name, 'outlet': (outletIndex+1), 'currentIndex': selectionIndex})
                        } else {
                            outletStates.get(outletIndex).currentIndex = selectionIndex
                        }
                        var item = outlets.itemAt(outletIndex)
                        item.label = name
                        item.currentIndex = selectionIndex
                    }
                    isUpdatingUi = false

                    var hostname = stripInfos[0];
                    var ipAddress = stripInfos[1];
                    var description = stripInfos[2];
                    var timestamp = stripInfos[3];

                    var firmwareVersion = stripInfos[6];
                    var temperature = stripInfos[7];

                    //ip.text = "IP: " + ipAddress
                    firmware.text = "Firmware Version: " + firmwareVersion;
                    temp.text = "Temperature: " + temperature + " C";
                    time.text = "Time: " + timestamp;

                    console.log("states initialized: " + req.response);
                    initialized = true;
                }

            }
        })(request);

        var credentials = Qt.btoa(settings.username + settings.password)
        console.log("GET " + 'http://' + settings.address + '?Stat=' + credentials)
        request.open('GET', 'http://' + settings.address + '?Stat=' + credentials, true);
        request.send('\n\n');
    }

    function resetAutoRefreshProgress() {
        freshTimerProgressBarUpdateTimer.stop()
        autoRefreshProgress.value = 0
        freshTimerProgressBarUpdateTimer.start()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: qsTr("ANEL NET-PwrCtrl PRO")
            }
            Label {
                id: ip
                x: Theme.horizontalPageMargin
                text: qsTr("Strip Address: " + settings.address)
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                id: firmware
                x: Theme.horizontalPageMargin
                text: qsTr("Firmware: ")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                id: temp
                x: Theme.horizontalPageMargin
                text: qsTr("Temperature:")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                id: time
                x: Theme.horizontalPageMargin
                text: qsTr("Time: ")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            ProgressBar {
                id: autoRefreshProgress
                visible: settings.showAutoRefreshTimer
                //label: "time until auto refresh"
                indeterminate: false
                width: parent.width
                maximumValue: settings.autoRefreshIntervalMs / 1000
            }
            SectionHeader {
                text: "Power Strip Outlets"
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
                    text: "Request to GET outlet list failed"
                }
            }
            Repeater {
                id: outlets
                model: outletStates
               /*TextSwitch {
                    text: modelData.name
                    onCheckedChanged: { harbour-netpwrctrl.togglePower(index) }
                }*/

                ComboBox {
                    currentIndex: 1

                    menu: ContextMenu {
                        MenuItem { text: "On" }
                        MenuItem { text: "Off" }
                    }
                    onCurrentIndexChanged: {
                        if (initialized && !isUpdatingUi) {
                            // index: repeater index
                            // currentIndex: combobox selection index
                            var item = outletStates.get(index)
                            outletStates.get(index).currentIndex = currentIndex
                            NetPwrCtrl.togglePower(settings.address, settings.username, settings.password, item.outlet, currentIndex)
                        }
                    }
                }
            }
            SectionHeader {
                text: "Refresh state"
            }
            ProgressBar {
                id: requestProgress
                visible: false
                label: "waiting for request to finish"
                indeterminate: true
                width: parent.width
            }
            ButtonLayout {
                preferredWidth: Theme.buttonWidthLarge
                Button {
                    text: "Refresh"
                    onClicked: {
                       console.log("refresh clicked");
                       requestProgress.visible = true
                       updateState();
                       requestProgress.visible = false
                    }
                }
            }
        }
    }

    Timer {
        id: freshTimerProgressBarUpdateTimer

        interval: 1000
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            autoRefreshProgress.value += 1
        }
        onRunningChanged: {
            if (!running) {
                console.log("progressbar update timer stopped")
            }
        }
    }

    Component.onCompleted: {
        autoRefreshTimer.start()
    }
}
