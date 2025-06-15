pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "." as Services

Singleton {
    id: root

    // Access to advanced window manager
    property var advancedManager: Services.AdvancedWindowManager

    // Define Client component for compatibility
    component Client: QtObject {
        property int workspace: 1
        property string wmClass: ""
        property string title: ""
        property int pid: 0
        property bool floating: false
        property bool fullscreen: false
        property var monitor: null
        property bool urgent: false
        property int windowId: 0
    }

    // Live properties populated from Niri IPC and AdvancedWindowManager
    property list<Client> clients: []
    property list<QtObject> workspaces: []
    property list<QtObject> monitors: []
    property Client activeClient: null
    property QtObject activeWorkspace: null
    property QtObject focusedMonitor: null
    property int activeWsId: 1
    property point cursorPos: Qt.point(0, 0)
    
    // Enhanced properties using AdvancedWindowManager
    property var floatingWindows: advancedManager ? advancedManager.floatingWindows : []
    property var fullscreenWindows: advancedManager ? advancedManager.fullscreenWindows : []
    property var urgentWindows: advancedManager ? advancedManager.urgentWindows : []
    property var focusHistory: advancedManager ? advancedManager.focusHistory : []
    property var workspaceWindows: advancedManager ? advancedManager.workspaceWindows : {}
    
    // Workspace occupancy tracking for compatibility
    property var occupied: ({})
    
    function updateOccupied() {
        let newOccupied = {};
        for (const client of clients) {
            if (client.workspace) {
                newOccupied[client.workspace] = true;
            }
        }
        occupied = newOccupied;
    }

    function reload() {
        // Refresh all data from Niri
        workspacesProc.running = true;
        windowsProc.running = true;
        outputsProc.running = true;
        focusedWindowProc.running = true; // Also query focused window
    }

    function dispatch(request) {
        // Convert Hyprland-style dispatch to Niri actions using AdvancedWindowManager
        if (request.startsWith("workspace ")) {
            const wsParam = request.split(" ")[1];
            if (wsParam.startsWith("r+") || wsParam.startsWith("r-")) {
                // Relative workspace switching
                const direction = wsParam.charAt(1) === "+" ? "down" : "up";
                advancedManager.switchWorkspaceRelative(direction === "down" ? 1 : -1);
            } else {
                // Absolute workspace switching
                advancedManager.switchToWorkspace(parseInt(wsParam));
            }
        } else if (request.startsWith("movetoworkspace ")) {
            const wsId = request.split(" ")[1];
            if (activeClient && activeClient.windowId) {
                advancedManager.moveWindowToWorkspace(activeClient.windowId, parseInt(wsId));
            }
        } else if (request.startsWith("togglefloating")) {
            if (activeClient && activeClient.windowId) {
                advancedManager.toggleWindowFloating(activeClient.windowId);
            }
        } else if (request.startsWith("fullscreen")) {
            if (activeClient && activeClient.windowId) {
                advancedManager.toggleWindowFullscreen(activeClient.windowId);
            }
        } else if (request.startsWith("closewindow")) {
            if (activeClient && activeClient.windowId) {
                advancedManager.closeWindow(activeClient.windowId);
            }
        } else if (request.startsWith("togglespecialworkspace")) {
            // Niri doesn't have special workspaces, map to regular workspace switching
            console.log("Special workspaces not supported in Niri, ignoring command:", request);
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
                    let foundActiveClient = null;
                    
                    for (const win of winData) {
                        const client = clientComponent.createObject(root, {
                            workspace: win.workspace_id,
                            wmClass: win.app_id,
                            title: win.title,
                            pid: win.pid,
                            floating: win.is_floating,
                            fullscreen: false, // Will be updated from AdvancedWindowManager
                            urgent: win.is_urgent || false,
                            windowId: win.id
                        });
                        newClients.push(client);
                        
                        if (win.is_focused) {
                            foundActiveClient = client;
                        }
                    }
                    
                    root.clients = newClients;
                    
                    // If we found a focused window from the list, use it
                    if (foundActiveClient) {
                        root.activeClient = foundActiveClient;
                    } else {
                        // Otherwise query the focused window separately
                        focusedWindowProc.running = true;
                    }
                    
                    root.updateOccupied(); // Update workspace occupancy
                    
                    // Sync with AdvancedWindowManager for enhanced features
                    if (advancedManager && advancedManager.syncWindowData) {
                        advancedManager.syncWindowData(newClients);
                    }
                } catch (e) {
                    console.error("Failed to parse window data:", e);
                }
            }
        }
    }

    // Process to get the currently focused window
    Process {
        id: focusedWindowProc
        command: ["niri", "msg", "-j", "focused-window"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const focusedWin = JSON.parse(data);
                    if (focusedWin && focusedWin.id) {
                        // Find the client with this window ID
                        const client = root.clients.find(c => c.windowId === focusedWin.id);
                        if (client) {
                            root.activeClient = client;
                        } else {
                            // Create a temporary client if not found in the list
                            const tempClient = clientComponent.createObject(root, {
                                workspace: focusedWin.workspace_id,
                                wmClass: focusedWin.app_id,
                                title: focusedWin.title,
                                pid: focusedWin.pid,
                                floating: focusedWin.is_floating,
                                fullscreen: false,
                                urgent: focusedWin.is_urgent || false,
                                windowId: focusedWin.id
                            });
                            root.activeClient = tempClient;
                        }
                    } else {
                        root.activeClient = null;
                    }
                } catch (e) {
                    console.error("Failed to parse focused window data:", e);
                    root.activeClient = null;
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

    // Enhanced functions for advanced window management
    function focusPreviousWindow() {
        if (advancedManager.focusHistory.length > 1) {
            const prevWindowId = advancedManager.focusHistory[1];
            advancedManager.focusWindow(prevWindowId);
        }
    }
    
    function getFloatingWindows() {
        return advancedManager.floatingWindows;
    }
    
    function getFullscreenWindows() {
        return advancedManager.fullscreenWindows;
    }
    
    function getUrgentWindows() {
        return advancedManager.urgentWindows;
    }
    
    function getWindowsInWorkspace(workspaceId) {
        return (advancedManager && advancedManager.workspaceWindows) ? 
               (advancedManager.workspaceWindows[workspaceId] || []) : [];
    }
    
    function toggleFloating(windowId) {
        if (windowId) {
            advancedManager.toggleWindowFloating(windowId);
        } else if (activeClient) {
            advancedManager.toggleWindowFloating(activeClient.windowId);
        }
    }
    
    function toggleFullscreen(windowId) {
        if (windowId) {
            advancedManager.toggleWindowFullscreen(windowId);
        } else if (activeClient) {
            advancedManager.toggleWindowFullscreen(activeClient.windowId);
        }
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
        
        // Connect to AdvancedWindowManager signals for real-time updates (only if available)
        if (advancedManager && advancedManager.windowStateChanged) {
            advancedManager.windowStateChanged.connect(function(windowId, state) {
                // Update corresponding client in our clients list
                for (let client of clients) {
                    if (client.windowId === windowId) {
                        client.floating = state.floating;
                        client.fullscreen = state.fullscreen;
                        client.urgent = state.urgent;
                        break;
                    }
                }
            });
        }
        
        if (advancedManager && advancedManager.focusChanged) {
            advancedManager.focusChanged.connect(function(windowId) {
                // Update activeClient
                for (let client of clients) {
                    if (client.windowId === windowId) {
                        activeClient = client;
                        break;
                    }
                }
            });
        }
    }
}
