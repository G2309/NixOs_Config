import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

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
                color: wsDelegate.modelData.focused ? Theme.crust : Theme.subtext0
                font.pixelSize: 12
                font.bold: wsDelegate.modelData.focused
                font.family: Theme.fontFamily
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsDelegate.modelData.name)
            }
        }
    }
}
