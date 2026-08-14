import Quickshell.Networking
import QtQuick

Text {
    color: Networking.connectivity === NetworkConnectivity.Full
        ? Theme.green
        : (Networking.connectivity === NetworkConnectivity.None ? Theme.red : Theme.yellow)
    font.pixelSize: 13
    text: "●"
}
