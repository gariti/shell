pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<int> workspaces: [1, 2, 3, 4, 5]
    readonly property int activeWorkspace: 1
    property var monitors: ({})

    function dispatch(request: string): void {
        console.log("Niri dispatch:", request);
        // For Niri compatibility, we'll use niri msg command
        dispatchProc.command = ["niri", "msg", request];
        dispatchProc.startDetached();
    }

    function switchToWorkspace(id: int): void {
        dispatch(`workspace switch ${id}`);
    }

    Process {
        id: dispatchProc
    }

    // Mock some properties for compatibility
    readonly property var focusedMonitor: null
    readonly property int activeWsId: activeWorkspace
}
