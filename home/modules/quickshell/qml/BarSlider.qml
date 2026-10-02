pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: slider

    property real value: 0
    property real step: 0
    property real minimum: 0
    property real maximum: 1
    property color fillColor: Theme.mauve
    property color trackColor: Theme.surface0
    readonly property bool pressed: area.pressed
    readonly property bool hovered: area.containsMouse

    signal moved(real value)
    signal released(real value)

    implicitWidth: 90
    implicitHeight: 6

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height
        radius: height / 2
        color: slider.trackColor

        Rectangle {
            width: parent.width * slider.clamp(slider.value)
            height: parent.height
            radius: height / 2
            color: slider.fillColor
            visible: width > 0

            Behavior on width {
                enabled: !slider.pressed
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }
    }

    Repeater {
        model: slider.step >= 0.1 ? Math.round(1 / slider.step) + 1 : 0

        Rectangle {
            required property int index
            width: 2
            height: slider.height + 4
            radius: 1
            anchors.verticalCenter: parent.verticalCenter
            x: Math.min(slider.width - width, Math.max(0, slider.width * index * slider.step - width / 2))
            color: index * slider.step <= slider.clamp(slider.value) + 0.001 ? Theme.crust : Theme.surface2
            opacity: 0.8
        }
    }

    Rectangle {
        width: 12
        height: 12
        radius: 6
        color: Theme.text
        border.color: slider.fillColor
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(slider.width - width, slider.width * slider.clamp(slider.value) - width / 2))
        opacity: slider.hovered || slider.pressed ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.topMargin: -8
        anchors.bottomMargin: -8
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function valueAt(x) {
            let v = slider.clamp(x / slider.width);
            if (slider.step > 0)
                v = Math.round(v / slider.step) * slider.step;
            return Math.max(slider.minimum, Math.min(slider.maximum, v));
        }

        onPressed: mouse => slider.moved(valueAt(mouse.x))
        onPositionChanged: mouse => {
            if (pressed)
                slider.moved(valueAt(mouse.x));
        }
        onReleased: mouse => slider.released(valueAt(mouse.x))
    }
}
