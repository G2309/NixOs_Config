import Quickshell
import QtQuick

Text {
    color: Theme.text
    font.pixelSize: 13
    font.bold: true
    font.family: Theme.fontFamily
    text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }
}
