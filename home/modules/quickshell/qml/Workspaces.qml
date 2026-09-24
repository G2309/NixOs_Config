import Quickshell
import QtQuick

Loader {
    source: Quickshell.env("SWAYSOCK")
        ? "WorkspacesSway.qml"
        : "WorkspacesHyprland.qml"
}
