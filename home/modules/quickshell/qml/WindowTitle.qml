import Quickshell.Wayland
import QtQuick

Text {
    elide: Text.ElideRight
    color: Theme.subtext0
    font.pixelSize: 13
    font.family: Theme.fontFamily
    text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
}
