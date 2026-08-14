import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 32
    color: Theme.crust

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 16

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 12

            Workspaces {}
            WindowTitle {}
        }

        Item { Layout.fillWidth: true }

        ClockWidget { Layout.alignment: Qt.AlignVCenter }

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 16

            Tray {}
            Volume {}
            NetworkIndicator {}
            Battery {}
        }
    }
}
