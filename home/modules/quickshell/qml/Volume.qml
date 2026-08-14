import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: volumeRoot
    property var sink: Pipewire.defaultAudioSink

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    PwObjectTracker {
        objects: volumeRoot.sink ? [volumeRoot.sink] : []
    }

    Text {
        id: label
        color: {
            const audio = volumeRoot.sink ? volumeRoot.sink.audio : null;
            return (audio && audio.muted) ? Theme.overlay0 : Theme.text;
        }
        font.pixelSize: 13
        font.family: Theme.fontFamily
        text: {
            const audio = volumeRoot.sink ? volumeRoot.sink.audio : null;
            if (!audio) return "--";
            if (audio.muted) return "muted";
            return Math.round(audio.volume * 100) + "%";
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const audio = volumeRoot.sink ? volumeRoot.sink.audio : null;
            if (audio) audio.muted = !audio.muted;
        }
        onWheel: wheel => {
            const audio = volumeRoot.sink ? volumeRoot.sink.audio : null;
            if (!audio) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            audio.volume = Math.max(0, Math.min(1.5, audio.volume + step));
        }
    }
}
