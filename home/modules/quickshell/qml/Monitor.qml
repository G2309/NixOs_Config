pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool available: false
    property string profile: ""
    property string mode: "auto"
    property string scheduled: ""
    property string dayStart: ""
    property string nightStart: ""
    property int brightness: 0
    property int contrast: 0
    property int sharpness: 0
    property bool sharpnessSupported: false
    property double holdUntil: 0
    property var limits: ({
            brightness: { min: 0, max: 100, step: 5 },
            contrast: { min: 30, max: 100, step: 5 },
            sharpness: { min: 0, max: 100, step: 25 }
        })

    readonly property string nextChange: scheduled === "night" ? dayStart : nightStart

    readonly property string statePath: Quickshell.env("HOME") + "/.local/state/monitor-ctl/state.json"

    function run(args) {
        Quickshell.execDetached(["monitor-ctl"].concat(args));
    }

    function hold() {
        holdUntil = Date.now() + 2500;
    }

    function snap(feature, value) {
        const l = limits[feature];
        let v = Math.round(value / l.step) * l.step;
        return Math.max(l.min, Math.min(l.max, v));
    }

    function setValue(feature, value) {
        const v = snap(feature, value);
        hold();
        root[feature] = v;
        root.mode = "manual";
        run(["set", feature, String(v)]);
    }

    function preview(feature, value) {
        hold();
        root[feature] = snap(feature, value);
    }

    function applyProfile(name) {
        hold();
        root.profile = name;
        root.mode = "manual";
        run(["profile", name]);
    }

    function resume() {
        hold();
        root.mode = "auto";
        run(["resume"]);
    }

    function parse(text) {
        let s;
        try {
            s = JSON.parse(text);
        } catch (e) {
            return;
        }
        available = s.available === true;
        scheduled = s.scheduled || "";
        dayStart = s.dayStart || "";
        nightStart = s.nightStart || "";
        sharpnessSupported = s.sharpnessSupported === true;
        if (s.limits)
            limits = s.limits;
        if (Date.now() < holdUntil)
            return;
        profile = s.profile || "";
        mode = s.mode || "auto";
        brightness = s.brightness || 0;
        contrast = s.contrast || 0;
        sharpness = s.sharpness || 0;
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.parse(text())
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: stateFile.reload()
    }

    Component.onCompleted: run(["refresh"])
}
