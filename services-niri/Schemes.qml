pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string actualCurrent: "default"
    readonly property string current: actualCurrent

    function setScheme(name: string): void {
        actualCurrent = name;
        console.log("Setting scheme to:", name);
    }

    IpcHandler {
        target: "scheme"

        function get(): string {
            return root.actualCurrent;
        }

        function set(name: string): void {
            root.setScheme(name);
        }

        function list(): string {
            return "default\ndark\nlight\nblue\ngreen\npurple";
        }
    }
}
