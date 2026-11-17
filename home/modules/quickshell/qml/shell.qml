import Quickshell
import QtQuick

ShellRoot {
    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
