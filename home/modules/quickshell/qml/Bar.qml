import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    // Floating look: the window itself is transparent and inset from the
    // screen edges via `margins`; the visible bar is a rounded Rectangle
    // (`bg`) drawn inside it, so it reads as a pill floating above content
    // rather than a bar flush against the screen edges.
    readonly property int floatMargin: 4 
    readonly property int barHeight: 36

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: floatMargin
        left: floatMargin
        right: floatMargin
    }

    implicitHeight: barHeight
    exclusiveZone: barHeight + floatMargin
    color: "transparent"

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 14
        color: Theme.crust
    }

    // Left and right groups are anchored to their respective edges and the
    // clock is anchored to the exact center of the bar, so a long window
    // title (clamped/elided in WindowTitle.qml) can never push the clock
    // out of place — it only eats into its own reserved space.
    RowLayout {
        id: leftGroup
        anchors {
            left: bg.left
            leftMargin: 14
            verticalCenter: bg.verticalCenter
            right: bar.horizontalCenter
            rightMargin: 12
        }
        spacing: 12

        Workspaces {}
        WindowTitle { Layout.fillWidth: true }
    }

    ClockWidget {
        anchors.centerIn: bg
    }

    RowLayout {
        anchors {
            right: bg.right
            rightMargin: 14
            verticalCenter: bg.verticalCenter
        }
        spacing: 16

        Tray {}
        Volume {}
        NetworkIndicator {}
        Battery {}
    }
}
