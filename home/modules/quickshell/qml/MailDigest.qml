import Quickshell.Io
import QtQuick

Rectangle {
    id: root

    property bool available: false
    readonly property bool busy: digest.running

    visible: available
    width: 18
    height: 12
    radius: 4
    color: busy ? Theme.mauve : (area.containsMouse ? Theme.surface1 : Theme.surface0)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.busy ? "󰑓" : "󰇮"
        color: root.busy ? Theme.crust : Theme.subtext0
        font.pixelSize: 10
        font.family: Theme.fontFamily

        RotationAnimation on rotation {
            running: root.busy
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1000
            onRunningChanged: if (!running) icon.rotation = 0
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (!root.busy) digest.running = true
    }

    Process {
        id: digest
        command: ["mail-digest"]
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v mail-digest"]
        onExited: code => root.available = code === 0
    }
}
