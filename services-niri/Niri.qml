pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Client type definition for compatibility
    property Component clientComponent: Component {
        QtObject {
            property var workspace
            property string wmClass: ""
            property string title: ""
            property string className: ""
        }
    }

    // Stub properties for Niri compatibility
    readonly property list<QtObject> clients: []
    readonly property list<QtObject> workspaces: [defaultWorkspace]
    readonly property list<QtObject> monitors: [defaultMonitor]
    property QtObject activeClient: null
    readonly property QtObject activeWorkspace: defaultWorkspace
    readonly property QtObject focusedMonitor: defaultMonitor
    readonly property int activeWsId: 1
    property point cursorPos: Qt.point(0, 0)

    // Client type for compatibility
    readonly property var client: clientComponent

    // Default workspace object
    readonly property QtObject defaultWorkspace: QtObject {
        readonly property int id: 1
        readonly property string name: "main"
    }

    // Default monitor object  
    readonly property QtObject defaultMonitor: QtObject {
        readonly property string name: "default"
        readonly property QtObject activeWorkspace: root.defaultWorkspace
    }

    function reload() {
        // Niri doesn't have the same reload mechanism
        console.log("Niri reload requested (no-op)")
    }

    function dispatch(request: string): void {
        // Niri doesn't have Hyprland's dispatch mechanism
        console.log("Niri dispatch requested:", request, "(no-op)")
    }

    Component.onCompleted: reload()
}
