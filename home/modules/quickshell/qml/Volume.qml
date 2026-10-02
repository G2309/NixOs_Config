import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property real volume: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property bool boosted: volume > 1.001

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    function icon() {
        if (!audio)
            return "󰖁";
        if (muted || volume <= 0.001)
            return "󰝟";
        if (volume < 0.34)
            return "󰕿";
        if (volume < 0.67)
            return "󰖀";
        return "󰕾";
    }

    function setVolume(v) {
        if (!audio)
            return;
        audio.muted = false;
        audio.volume = Math.round(Math.max(0, Math.min(1.5, v)) * 100) / 100;
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    RowLayout {
        id: row
        spacing: 7

        Text {
            text: root.icon()
            color: root.muted ? Theme.overlay0 : Theme.mauve
            font.pixelSize: 15
            font.family: Theme.fontFamily

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.audio)
                        root.audio.muted = !root.audio.muted;
                }
            }
        }

        BarSlider {
            implicitWidth: 80
            value: Math.min(1, root.volume)
            fillColor: root.muted ? Theme.overlay0 : (root.boosted ? Theme.peach : Theme.mauve)
            onMoved: v => root.setVolume(v)
            onReleased: v => root.setVolume(v)
        }

        Text {
            Layout.preferredWidth: 38
            horizontalAlignment: Text.AlignRight
            text: !root.audio ? "--" : (root.muted ? "mute" : Math.round(root.volume * 100) + "%")
            color: root.muted ? Theme.overlay0 : (root.boosted ? Theme.peach : Theme.text)
            font.pixelSize: 13
            font.family: Theme.fontFamily
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: Quickshell.execDetached(["pavucontrol"])
        onWheel: wheel => root.setVolume(root.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}
