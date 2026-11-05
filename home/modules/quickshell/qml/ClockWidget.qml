import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Controls

Item {
    id: clockRoot

    property bool pinned: false
    property bool hoverOpen: false
    property int viewMonth: clock.date.getMonth()
    property int viewYear: clock.date.getFullYear()
    property string selected: iso(clock.date.getFullYear(), clock.date.getMonth(), clock.date.getDate())
    property var events: ({})

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    function iso(y, m, d) {
        return y + "-" + String(m + 1).padStart(2, "0") + "-" + String(d).padStart(2, "0");
    }

    function shiftMonth(delta) {
        pinned = true;
        const d = new Date(viewYear, viewMonth + delta, 1);
        viewMonth = d.getMonth();
        viewYear = d.getFullYear();
        refresh();
    }

    function refresh() {
        const next = new Date(viewYear, viewMonth + 1, 1);
        monthProc.command = ["calendario", "mes", iso(viewYear, viewMonth, 1), iso(next.getFullYear(), next.getMonth(), 1)];
        monthProc.running = true;
    }

    function parse(text) {
        const out = {};
        for (const line of text.split("\n").slice(1)) {
            const c = line.split("\t");
            if (c.length < 5 || !c[0])
                continue;
            (out[c[0]] = out[c[0]] || []).push(c[1] ? c[1] + "  " + c[4] : c[4]);
        }
        events = out;
    }

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }

    Process {
        id: monthProc
        stdout: StdioCollector {
            onStreamFinished: clockRoot.parse(this.text)
        }
    }

    Process {
        id: addProc
        onExited: clockRoot.refresh()
    }

    Text {
        id: label
        anchors.fill: parent
        color: Theme.text
        font.pixelSize: 13
        font.bold: true
        font.family: Theme.fontFamily
        text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
                clockRoot.hoverOpen = true;
            } else {
                closeTimer.restart();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 3000
        onTriggered: clockRoot.hoverOpen = false
    }

    TapHandler {
        onTapped: {
            clockRoot.pinned = !clockRoot.pinned;
            if (!clockRoot.pinned) {
                clockRoot.hoverOpen = false;
            } else {
                clockRoot.viewMonth = clock.date.getMonth();
                clockRoot.viewYear = clock.date.getFullYear();
                clockRoot.selected = clockRoot.iso(clockRoot.viewYear, clockRoot.viewMonth, clock.date.getDate());
            }
        }
    }

    Component.onCompleted: refresh()

    PopupWindow {
        id: calendarPopup
        visible: clockRoot.hoverOpen || clockRoot.pinned
        implicitWidth: 260
        implicitHeight: 360
        color: "transparent"

        anchor.item: clockRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        anchor.margins.top: 8

        onVisibleChanged: if (visible) clockRoot.refresh()

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.crust
            border.color: clockRoot.pinned ? Theme.mauve : Theme.surface0
            border.width: 1

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.preferredWidth: 28
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "‹"
                        color: Theme.subtext0
                        font.pixelSize: 16
                        font.family: Theme.fontFamily
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: clockRoot.shiftMonth(-1)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(new Date(clockRoot.viewYear, clockRoot.viewMonth, 1), "MMMM yyyy")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: 14
                        font.family: Theme.fontFamily
                    }

                    Text {
                        Layout.preferredWidth: 28
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "›"
                        color: Theme.subtext0
                        font.pixelSize: 16
                        font.family: Theme.fontFamily
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: clockRoot.shiftMonth(1)
                        }
                    }

                    Text {
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "✕"
                        color: closeArea.containsMouse ? Theme.red : Theme.subtext0
                        font.pixelSize: 12
                        font.family: Theme.fontFamily

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                closeTimer.stop();
                                clockRoot.pinned = false;
                                clockRoot.hoverOpen = false;
                            }
                        }
                    }
                }

                Controls.DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.maximumHeight: 20
                    locale: grid.locale

                    delegate: Text {
                        required property var model
                        text: model.shortName
                        color: Theme.subtext0
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Controls.MonthGrid {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    month: clockRoot.viewMonth
                    year: clockRoot.viewYear
                    locale: Qt.locale("en_US")
                    onClicked: date => {
                        clockRoot.pinned = true;
                        clockRoot.selected = clockRoot.iso(date.getFullYear(), date.getMonth(), date.getDate());
                    }

                    delegate: Item {
                        id: dayDelegate
                        required property var model
                        readonly property string key: clockRoot.iso(model.year, model.month, model.day)
                        implicitWidth: 26
                        implicitHeight: 26

                        Rectangle {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            color: dayDelegate.model.today ? Theme.mauve : "transparent"
                            border.color: Theme.lavender
                            border.width: clockRoot.selected === dayDelegate.key ? 1 : 0
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayDelegate.model.day
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                            opacity: dayDelegate.model.month === grid.month ? 1 : 0.35
                            color: dayDelegate.model.today ? Theme.crust : Theme.text
                        }

                        Rectangle {
                            visible: !!clockRoot.events[dayDelegate.key]
                            width: 4
                            height: 4
                            radius: 2
                            color: dayDelegate.model.today ? Theme.crust : Theme.mauve
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    clip: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: clockRoot.selected
                            color: Theme.subtext0
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }

                        Rectangle {
                            implicitWidth: addText.implicitWidth + 12
                            implicitHeight: 18
                            radius: 5
                            color: addArea.containsMouse ? Theme.surface1 : Theme.surface0

                            Text {
                                id: addText
                                anchors.centerIn: parent
                                text: "+ nota"
                                color: Theme.text
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                            }

                            MouseArea {
                                id: addArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    clockRoot.pinned = true;
                                    addProc.command = ["calendario", "agregar", clockRoot.selected];
                                    addProc.running = true;
                                }
                            }
                        }
                    }

                    Repeater {
                        model: clockRoot.events[clockRoot.selected] || []

                        Text {
                            required property string modelData
                            Layout.fillWidth: true
                            text: "• " + modelData
                            color: Theme.text
                            wrapMode: Text.WordWrap
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }
                    }

                    Text {
                        visible: !(clockRoot.events[clockRoot.selected] || []).length
                        text: "Sin notas"
                        color: Theme.overlay0
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
