import QtQuick

Column {
    id: root

    visible: Monitor.available
    spacing: 2

    Repeater {
        model: [
            { name: "day", icon: "󰖨", label: "Día" },
            { name: "night", icon: "󰖔", label: "Noche" }
        ]

        Rectangle {
            id: btn

            required property var modelData
            readonly property bool active: Monitor.profile === modelData.name

            width: 60
            height: 14
            radius: 5
            color: active ? Theme.mauve : (area.containsMouse ? Theme.surface1 : Theme.surface0)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Row {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: btn.modelData.icon
                    color: btn.active ? Theme.crust : Theme.subtext0
                    font.pixelSize: 10
                    font.family: Theme.fontFamily
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: btn.modelData.label
                    color: btn.active ? Theme.crust : Theme.subtext0
                    font.pixelSize: 9
                    font.bold: btn.active
                    font.family: Theme.fontFamily
                }
            }

            Rectangle {
                visible: btn.active && Monitor.mode === "auto"
                width: 4
                height: 4
                radius: 2
                color: Theme.crust
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!btn.active)
                        Monitor.applyProfile(btn.modelData.name);
                }
            }
        }
    }
}
