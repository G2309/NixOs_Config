import Quickshell.Services.UPower
import QtQuick

Text {
    readonly property var device: UPower.displayDevice

    visible: device && device.isLaptopBattery
    color: device && device.state === UPowerDeviceState.Charging ? Theme.green : Theme.text
    font.pixelSize: 13
    font.family: Theme.fontFamily
    text: device ? Math.round(device.percentage) + "%" : ""
}
