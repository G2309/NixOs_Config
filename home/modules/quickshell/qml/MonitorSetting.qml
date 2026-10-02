import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: row

    required property string feature
    required property string label
    required property string icon

    readonly property var lim: Monitor.limits[feature]
    readonly property int current: Monitor[feature]

    spacing: 6
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: row.icon
            color: Theme.mauve
            font.pixelSize: 14
            font.family: Theme.fontFamily
        }

        Text {
            text: row.label
            color: Theme.text
            font.pixelSize: 12
            font.family: Theme.fontFamily
            Layout.fillWidth: true
        }

        Text {
            text: row.current + "%"
            color: Theme.subtext0
            font.pixelSize: 12
            font.family: Theme.fontFamily
        }
    }

    BarSlider {
        Layout.fillWidth: true
        implicitHeight: 6
        value: row.current / 100
        step: row.lim.step / 100
        minimum: row.lim.min / 100
        maximum: row.lim.max / 100
        onMoved: v => Monitor.preview(row.feature, v * 100)
        onReleased: v => Monitor.setValue(row.feature, v * 100)
    }
}
