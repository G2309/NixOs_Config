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

    // Left and right groups are anchored to their respective edges and the
    // clock is anchored to the exact center of the bar, so a long window
    // title (clamped/elided in WindowTitle.qml) can never push the clock
    // out of place — it only eats into its own reserved space.
    RowLayout {
        id: leftGroup
        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
            right: bar.horizontalCenter
            rightMargin: 12
        }
        spacing: 12

        Workspaces {}
        WindowTitle { Layout.fillWidth: true }
    }

    ClockWidget {
        anchors.centerIn: parent
    }

    RowLayout {
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 16

        Tray {}
        Volume {}
        NetworkIndicator {}
        Battery {}
    }
}
