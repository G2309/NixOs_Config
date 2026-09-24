import Quickshell.I3
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 6

    Repeater {
        model: I3.workspaces

        Rectangle {
            id: wsDelegate
            required property var modelData

            implicitWidth: 22
            implicitHeight: 22
            radius: 6
            color: wsDelegate.modelData.focused
                ? Theme.mauve
                : (wsDelegate.modelData.active ? Theme.surface1 : "transparent")

            Text {
                anchors.centerIn: parent
                text: wsDelegate.modelData.name
                color: {
                    if (wsDelegate.modelData.urgent) return Theme.red;
                    return wsDelegate.modelData.focused ? Theme.crust : Theme.subtext0;
                }
                font.pixelSize: 12
                font.bold: wsDelegate.modelData.focused
                font.family: Theme.fontFamily
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: I3.dispatch("workspace " + wsDelegate.modelData.name)
            }
        }
    }
}
