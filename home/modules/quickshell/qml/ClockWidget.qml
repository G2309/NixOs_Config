import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Controls

Item {
    id: clockRoot

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
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
    }

    PopupWindow {
        id: calendarPopup
        visible: hover.hovered
        implicitWidth: 260
        implicitHeight: 250
        color: "transparent"

        anchor.item: clockRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        anchor.margins.top: 8

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.crust
            border.color: Theme.surface0
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(clock.date, "MMMM yyyy")
                    color: Theme.text
                    font.bold: true
                    font.pixelSize: 14
                    font.family: Theme.fontFamily
                }

                Controls.DayOfWeekRow {
                    Layout.fillWidth: true
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
                    month: clock.date.getMonth()
                    year: clock.date.getFullYear()
                    locale: Qt.locale("en_US")

                    delegate: Item {
                        id: dayDelegate
                        required property var model
                        implicitWidth: 26
                        implicitHeight: 26

                        Rectangle {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            color: Theme.mauve
                            visible: dayDelegate.model.today
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayDelegate.model.day
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                            opacity: dayDelegate.model.month === grid.month ? 1 : 0.35
                            color: dayDelegate.model.today ? Theme.crust : Theme.text
                        }
                    }
                }
            }
        }
    }
}
