import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool open: false
    property bool recording: false
    property double start: 0
    property double now: Date.now()
    property string modo: "pantalla"
    property bool mic: false
    property bool sistema: true
    readonly property bool hovering: trigger.containsMouse || popupHover.hovered
    readonly property string statePath: Quickshell.env("XDG_RUNTIME_DIR") + "/grabar.json"

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    function elapsed() {
        const s = Math.max(0, Math.floor(now / 1000 - start));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    function begin() {
        open = false;
        Quickshell.execDetached(["grabar", "start", modo, mic ? "si" : "no", sistema ? "si" : "no"]);
    }

    function parse(text) {
        let s;
        try {
            s = JSON.parse(text);
        } catch (e) {
            recording = false;
            return;
        }
        recording = s.recording === true;
        start = s.start || 0;
    }

    onHoveringChanged: {
        if (hovering)
            closeTimer.stop();
        else if (open)
            closeTimer.restart();
    }

    onOpenChanged: {
        if (open && !hovering)
            closeTimer.restart();
    }

    RowLayout {
        id: row
        spacing: 6

        Text {
            text: "󰑊"
            color: root.recording ? Theme.red : Theme.subtext0
            font.pixelSize: 15
            font.family: Theme.fontFamily
        }

        Text {
            visible: root.recording
            text: root.elapsed()
            color: Theme.red
            font.pixelSize: 13
            font.family: Theme.fontFamily
        }
    }

    MouseArea {
        id: trigger
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.recording)
                Quickshell.execDetached(["grabar", "stop"]);
            else
                root.open = !root.open;
        }
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.parse(text())
        onLoadFailed: root.recording = false
    }

    Timer {
        interval: root.recording ? 1000 : 2000
        running: true
        repeat: true
        onTriggered: {
            root.now = Date.now();
            stateFile.reload();
        }
    }

    Timer {
        id: closeTimer
        interval: 700
        onTriggered: root.open = false
    }

    component Chip: Rectangle {
        id: chip

        property string icon
        property string label
        property bool active
        signal clicked

        Layout.fillWidth: true
        implicitHeight: 28
        radius: 8
        color: active ? Theme.mauve : (chipArea.containsMouse ? Theme.surface1 : Theme.surface0)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.icon
                color: chip.active ? Theme.crust : Theme.text
                font.pixelSize: 13
                font.family: Theme.fontFamily
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.label
                color: chip.active ? Theme.crust : Theme.text
                font.pixelSize: 12
                font.bold: chip.active
                font.family: Theme.fontFamily
            }
        }

        MouseArea {
            id: chipArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    PopupWindow {
        visible: root.open
        implicitWidth: 260
        implicitHeight: content.implicitHeight + 28
        color: "transparent"

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        anchor.margins.top: 10

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.crust
            border.color: Theme.surface0
            border.width: 1

            HoverHandler {
                id: popupHover
            }

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    text: "Grabar pantalla"
                    color: Theme.text
                    font.pixelSize: 14
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Chip {
                        icon: "󰍹"
                        label: "Pantalla"
                        active: root.modo === "pantalla"
                        onClicked: root.modo = "pantalla"
                    }

                    Chip {
                        icon: "󰩭"
                        label: "Región"
                        active: root.modo === "region"
                        onClicked: root.modo = "region"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Chip {
                        icon: root.mic ? "󰍬" : "󰍭"
                        label: "Micrófono"
                        active: root.mic
                        onClicked: root.mic = !root.mic
                    }

                    Chip {
                        icon: root.sistema ? "󰕾" : "󰖁"
                        label: "Audio"
                        active: root.sistema
                        onClicked: root.sistema = !root.sistema
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 9
                    color: recArea.containsMouse ? Theme.red : Theme.surface0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰑊  Grabar"
                        color: recArea.containsMouse ? Theme.crust : Theme.red
                        font.pixelSize: 13
                        font.bold: true
                        font.family: Theme.fontFamily
                    }

                    MouseArea {
                        id: recArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.begin()
                    }
                }
            }
        }
    }
}
