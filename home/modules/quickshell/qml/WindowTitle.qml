import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Text {
    Layout.maximumWidth: 380
    elide: Text.ElideRight
    color: Theme.subtext0
    font.pixelSize: 13
    font.family: Theme.fontFamily
    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
}
