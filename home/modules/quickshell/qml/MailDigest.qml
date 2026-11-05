import Quickshell
import Quickshell.Io
import QtQuick

Row {
    id: root

    property bool available: false
    property bool voice: false
    readonly property bool busy: digest.running
    readonly property string voicePath: Quickshell.env("HOME") + "/.local/state/mail-digest/voz"

    visible: available
    spacing: 2

    function setVoice(on) {
        root.voice = on;
        saveVoice.command = ["sh", "-c", "mkdir -p \"$(dirname \"$1\")\" && printf %s \"$2\" > \"$1\"", "sh", root.voicePath, on ? "1" : "0"];
        saveVoice.running = true;
        if (!on)
            Quickshell.execDetached(["pkill", "-x", "pw-play"]);
    }

    Rectangle {
        width: 18
        height: 12
        radius: 4
        color: root.busy ? Theme.mauve : (mailArea.containsMouse ? Theme.surface1 : Theme.surface0)

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
            id: mailArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.busy)
                    return;
                digest.command = root.voice ? ["mail-digest", "--voz"] : ["mail-digest"];
                digest.running = true;
            }
        }
    }

    Rectangle {
        width: 14
        height: 12
        radius: 4
        color: root.voice ? Theme.mauve : (voiceArea.containsMouse ? Theme.surface1 : Theme.surface0)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            text: root.voice ? "󰕾" : "󰖁"
            color: root.voice ? Theme.crust : Theme.subtext0
            font.pixelSize: 9
            font.family: Theme.fontFamily
        }

        MouseArea {
            id: voiceArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setVoice(!root.voice)
        }
    }

    Process {
        id: digest
        command: ["mail-digest"]
    }

    Process {
        id: saveVoice
    }

    FileView {
        path: root.voicePath
        printErrors: false
        onLoaded: root.voice = text().trim() === "1"
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v mail-digest"]
        onExited: code => root.available = code === 0
    }
}
