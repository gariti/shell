pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Define Client component for compatibility
    component Client: QtObject {
        property int workspace: 1
        property string wmClass: ""
        property string title: ""
        property int pid: 0
        property bool floating: false
        property bool fullscreen: false
        property var monitor: null
    }

    // Live properties populated from Niri IPC
    property list<Client> clients: []
    property list<QtObject> workspaces: []
    property list<QtObject> monitors: []
    property Client activeClient: null
    property QtObject activeWorkspace: null
    property QtObject focusedMonitor: null
    property int activeWsId: 1
    property point cursorPos: Qt.point(0, 0)

    function reload() {
        // Refresh all data from Niri
        workspacesProc.running = true;
        windowsProc.running = true;
        outputsProc.running = true;
    }

    function dispatch(request: string): void {
        // Convert Hyprland-style dispatch to Niri actions
        if (request.startsWith("workspace ")) {
            const wsId = request.split(" ")[1];
            niriAction.command = ["niri", "msg", "action", "focus-workspace", wsId];
            niriAction.running = true;
        } else if (request.startsWith("movetoworkspace ")) {
            const wsId = request.split(" ")[1];
            niriAction.command = ["niri", "msg", "action", "move-window-to-workspace", wsId];
            niriAction.running = true;
        }
        // Add more dispatch translations as needed
    }

    // Process to get workspace information
    Process {
        id: workspacesProc
        running: true
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const wsData = JSON.parse(data);
                    const newWorkspaces = [];
                    let activeWs = null;
                    let focusedWs = null;
                    
                    for (const ws of wsData) {
                        const workspace = workspaceComponent.createObject(root, {
                            id: ws.id,
                            name: ws.name || ws.idx.toString(),
                            special: false,
                            monitor: root.monitors.find(m => m.name === ws.output) || null
                        });
                        newWorkspaces.push(workspace);
                        
                        if (ws.is_active) activeWs = workspace;
                        if (ws.is_focused) {
                            focusedWs = workspace;
                            root.activeWsId = ws.id;
                        }
                    }
                    
                    root.workspaces = newWorkspaces;
                    root.activeWorkspace = activeWs || focusedWs;
                } catch (e) {
                    console.error("Failed to parse workspace data:", e);
                }
            }
        }
    }

    // Process to get window information
    Process {
        id: windowsProc
        running: true
        command: ["niri", "msg", "-j", "windows"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const winData = JSON.parse(data);
                    const newClients = [];
                    let activeClient = null;
                    
                    for (const win of winData) {
                        const client = clientComponent.createObject(root, {
                            workspace: win.workspace_id,
                            wmClass: win.app_id,
                            title: win.title,
                            pid: win.pid,
                            floating: win.is_floating,
                            fullscreen: false // Niri doesn't expose this directly
                        });
                        newClients.push(client);
                        
                        if (win.is_focused) {
                            activeClient = client;
                        }
                    }
                    
                    root.clients = newClients;
                    root.activeClient = activeClient;
                } catch (e) {
                    console.error("Failed to parse window data:", e);
                }
            }
        }
    }

    // Process to get output/monitor information  
    Process {
        id: outputsProc
        running: true
        command: ["niri", "msg", "-j", "outputs"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const outputData = JSON.parse(data);
                    const newMonitors = [];
                    
                    for (const [name, output] of Object.entries(outputData)) {
                        const logical = output.logical || {};
                        const monitor = monitorComponent.createObject(root, {
                            id: 0, // Niri doesn't provide numeric IDs
                            name: output.name,
                            x: logical.x || 0,
                            y: logical.y || 0,
                            width: logical.width || 1920,
                            height: logical.height || 1080,
                            scale: logical.scale || 1.0
                        });
                        newMonitors.push(monitor);
                    }
                    
                    root.monitors = newMonitors;
                    root.focusedMonitor = newMonitors[0]; // Niri doesn't expose focused state directly
                } catch (e) {
                    console.error("Failed to parse output data:", e);
                }
            }
        }
    }

    // Process for executing Niri actions
    Process {
        id: niriAction
    }

    // Timer to periodically refresh data
    Timer {
        running: true
        interval: 2000 // Refresh every 2 seconds
        repeat: true
        onTriggered: root.reload()
    }

    // Component definitions
    Component {
        id: clientComponent
        Client {}
    }

    Component {
        id: workspaceComponent
        QtObject {
            property int id: 1
            property string name: "main"
            property bool special: false
            property var monitor: null
        }
    }

    Component {
        id: monitorComponent
        QtObject {
            property int id: 0
            property string name: "default"
            property int x: 0
            property int y: 0
            property int width: 1920
            property int height: 1080
            property real scale: 1.0
            property QtObject activeWorkspace: root.activeWorkspace
        }
    }

    Component.onCompleted: {
        // Initial load
        reload();
    }
}
