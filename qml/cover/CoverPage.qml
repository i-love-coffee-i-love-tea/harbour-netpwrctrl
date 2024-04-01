import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

CoverBackground {

    property FirstPage initialPage

    Column { // To enable PullDownMenu, place our content in a SilicaFlickable

        id: column
        width: parent.width
        Label {
            width: parent.width
            height: 100
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("NetPwrCtrl")
        }

        /*Flow {
            x: Theme.paddingSmall
            width: parent.width - (Theme.paddingSmall * 2)

            spacing: Theme.paddingSmall
            Repeater {
                 //model: ListModel { id: listModel }
                model: outletStates
                Rectangle {
                    color: outletStates.get(index).currentIndex === 0 ? "green" : "red"
                    width: (parent.width/4)-(Theme.paddingSmall)
                    height: (parent.width/4)-(Theme.paddingSmall)

                    Label {
                        text: index + 1
                    }
                }

            }
        }*/
        SilicaGridView {
           x: Theme.paddingSmall
           width: parent.width - (Theme.paddingSmall * 2)

           cellWidth: (parent.width/4)-(Theme.paddingSmall)
           cellHeight: cellWidth
           model: outletStates
           delegate: Rectangle {
               width: GridView.view.cellWidth
               height: width
               color: outletStates.get(index).currentIndex === 0 ? "green" : "red"

               Label {
                   text: index + 1
               }
           }
       }
    }

    Connections {
        target: outletStates;
        onDataChanged: {
            console.log("outlet data changed")
        }
    }


    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                console.log("cover action triggered")
                initialPage.updateStates()
            }
        }
    }
}
