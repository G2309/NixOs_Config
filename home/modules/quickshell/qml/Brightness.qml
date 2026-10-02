import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool open: false
    readonly property bool hovering: trigger.containsMouse || popupHover.hovered

    visible: Monitor.available
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    function icon(v) {
        if (v < 34)
            return "󰃞";
        if (v < 67)
            return "󰃟";
        return "󰃠";
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
            text: root.icon(Monitor.brightness)
            color: Theme.yellow
            font.pixelSize: 15
            font.family: Theme.fontFamily
        }

        Text {
            text: Monitor.brightness + "%"
            color: Theme.text
            font.pixelSize: 13
            font.family: Theme.fontFamily
            Layout.preferredWidth: 34
        }
    }

    MouseArea {
        id: trigger
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.open = !root.open
        onWheel: wheel => {
            const dir = wheel.angleDelta.y > 0 ? 1 : -1;
            Monitor.preview("brightness", Monitor.brightness + dir * Monitor.limits.brightness.step);
            scrollTimer.restart();
        }
    }

    Timer {
        id: scrollTimer
        interval: 400
        onTriggered: Monitor.setValue("brightness", Monitor.brightness)
    }

    Timer {
        id: closeTimer
        interval: 700
        onTriggered: root.open = false
    }

    PopupWindow {
        visible: root.open
        implicitWidth: 280
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
                spacing: 14

                Text {
                    text: "Monitor"
                    color: Theme.text
                    font.pixelSize: 14
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                MonitorSetting {
                    feature: "brightness"
                    label: "Brillo"
                    icon: "󰃠"
                }

                MonitorSetting {
                    feature: "contrast"
                    label: "Contraste"
                    icon: "󰆕"
                }

                MonitorSetting {
                    feature: "sharpness"
                    label: "Nitidez"
                    icon: "󰂵"
                    visible: Monitor.sharpnessSupported
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.surface0
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: Theme.subtext0
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        text: Monitor.mode === "manual"
                            ? "Manual hasta las " + Monitor.nextChange
                            : "Automático · cambia a las " + Monitor.nextChange
                    }

                    Rectangle {
                        visible: Monitor.mode === "manual"
                        implicitWidth: resumeLabel.implicitWidth + 16
                        implicitHeight: 22
                        radius: 7
                        color: resumeArea.containsMouse ? Theme.mauve : Theme.surface0

                        Text {
                            id: resumeLabel
                            anchors.centerIn: parent
                            text: "Volver al horario"
                            color: resumeArea.containsMouse ? Theme.crust : Theme.text
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }

                        MouseArea {
                            id: resumeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Monitor.resume()
                        }
                    }
                }
            }
        }
    }
}
