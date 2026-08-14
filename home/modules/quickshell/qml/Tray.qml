import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 10
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        IconImage {
            id: trayIcon
            required property var modelData

            implicitSize: 16
            source: trayIcon.modelData.icon

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) trayIcon.modelData.activate();
                    else trayIcon.modelData.secondaryActivate();
                }
            }
        }
    }
}
