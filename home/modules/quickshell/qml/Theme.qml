pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property color rosewater: "#f4dbd6"
    property color flamingo: "#f0c6c6"
    property color pink: "#f5bde6"
    property color mauve: "#c6a0f6"
    property color red: "#ed8796"
    property color maroon: "#ee99a0"
    property color peach: "#f5a97f"
    property color yellow: "#eed49f"
    property color green: "#a6da95"
    property color teal: "#8bd5ca"
    property color sky: "#91d7e3"
    property color sapphire: "#7dc4e4"
    property color blue: "#8aadf4"
    property color lavender: "#b7bdf8"
    property color text: "#cad3f5"
    property color subtext1: "#b8c0e0"
    property color subtext0: "#a5adcb"
    property color overlay2: "#939ab7"
    property color overlay1: "#8087a2"
    property color overlay0: "#6e738d"
    property color surface2: "#5b6078"
    property color surface1: "#494d64"
    property color surface0: "#363a4f"
    property color base: "#24273a"
    property color mantle: "#1e2030"
    property color crust: "#181926"

    readonly property string fontFamily: "FiraCode Nerd Font"

    property bool loaded: false
    readonly property string themePath: Quickshell.env("HOME") + "/.cache/wallpaper-theme/colors.json"

    function apply(raw) {
        let c;
        try {
            c = JSON.parse(raw);
        } catch (e) {
            return;
        }
        for (const k in c) {
            if (k in root && typeof c[k] === "string" && /^#[0-9a-fA-F]{6}$/.test(c[k]))
                root[k] = c[k];
        }
        root.loaded = true;
    }

    FileView {
        id: themeFile
        path: root.themePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.apply(text())
    }

    Timer {
        interval: 5000
        running: !root.loaded
        repeat: true
        onTriggered: themeFile.reload()
    }
}
