import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"
import "cover"

ApplicationWindow {
    initialPage:  FirstPage { }
    //cover: Qt.resolvedUrl("cover/CoverPage.qml")
    cover: Component { CoverPage { initialPage: initialPage } }
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup {
        id: settings
        path: "/org/gobuki/netpwrctrl"
        property string address: "192.168.0.114"
        property string username: "user1"
        property string password: "anel"
        property int autoRefreshIntervalMs: 0 // 0: disabled
        property bool showAutoRefreshTimer: true
    }

    ListModel {
        id: outletStates
    }

    Timer {
        id: autoRefreshTimer

        interval: settings.autoRefreshIntervalMs
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("refresh timer triggered. " + settings.autoRefreshIntervalMs)
            initialPage.updateState()
            initialPage.resetAutoRefreshProgress()
        }

        onRunningChanged: {
            if (!running) {
                console.log("refresh timer changed state to something != running")
            }
        }
        onIntervalChanged: {
            console.log("refresh timer interval changed" + settings.autoRefreshIntervalMs)
        }

    }
}
