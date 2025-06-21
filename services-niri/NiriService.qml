pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Niri workspace properties
    property int activeWorkspace: 1
    property var workspaces: []
    property var workspaceData: []
    property int windowCount: 0
    
    // Per-monitor workspace tracking
    property var monitorWorkspaces: ({}) // Map of monitor name -> workspace array
    property string focusedMonitor: ""
    property int currentMonitorWorkspaceIndex: 1  // Position in the current monitor's vertical stack
    property int currentMonitorWorkspaceCount: 1  // Total workspaces on current monitor
    property string currentWorkspaceName: ""  // Name of current workspace (if named)
    property bool currentWorkspaceIsNamed: false  // Whether current workspace has a name
    
    // Additional Niri state
    property var windows: []
    property var focusedWindow: null
    property var outputs: []
    property bool available: false

    // Signals for immediate UI updates
    signal workspaceChanged()
    signal activeWorkspaceChanged()

    // Function to switch workspaces via niri msg
    function switchToWorkspace(id: int): void {
        switchProc.command = ["niri", "msg", "action", "focus-workspace", id.toString()];
        switchProc.startDetached();
        
        // Trigger immediate update after workspace change
        immediateUpdateTimer.start();
    }

    // General dispatch function for Niri actions
    function dispatch(action: string): void {
        console.log("Niri dispatch:", action);
        // For Niri, we need to use "niri msg action <action>"
        dispatchProc.command = ["niri", "msg", "action", action];
        dispatchProc.startDetached();
        
        // Trigger immediate update after workspace change
        immediateUpdateTimer.start();
    }

    // Functions for workspace naming
    function setWorkspaceName(name: string): void {
        console.log("Setting workspace name:", name);
        setNameProc.command = ["niri", "msg", "action", "set-workspace-name", name];
        setNameProc.startDetached();
    }

    function unsetWorkspaceName(): void {
        console.log("Unsetting workspace name");
        unsetNameProc.command = ["niri", "msg", "action", "unset-workspace-name"];
        unsetNameProc.startDetached();
    }

    // Function to get workspace info from niri
    function updateWorkspaces(): void {
        workspaceQueryProc.command = ["niri", "msg", "-j", "workspaces"];
        workspaceQueryProc.running = true;
    }
    
    // Additional IPC functions for caelestia script integration
    function moveWindowToWorkspace(workspaceId: int): void {
        const wsIndex = workspaceId - 1; // Convert to 0-based
        moveWindowProc.command = [
            "niri", "msg", "action", "move-column-to-workspace",
            JSON.stringify({ "reference": { "Index": wsIndex } })
        ];
        moveWindowProc.running = true;
    }
    
    function closeWindow(): void {
        closeWindowProc.command = ["niri", "msg", "action", "close-window"];
        closeWindowProc.running = true;
    }
    
    function toggleFullscreen(): void {
        fullscreenProc.command = ["niri", "msg", "action", "toggle-fullscreen"];
        fullscreenProc.running = true;
    }
    
    function spawn(command: string): void {
        spawnProc.command = ["niri", "msg", "action", "spawn", "--", "sh", "-c", command];
        spawnProc.running = true;
    }
    
    function getFocusedWindow(): void {
        focusedWindowProc.command = ["niri", "msg", "--json", "focused-window"];
        focusedWindowProc.running = true;
    }
    
    function getAllWindows(): void {
        windowsProc.command = ["niri", "msg", "--json", "windows"];
        windowsProc.running = true;
    }
    
    function getOutputs(): void {
        outputsProc.command = ["niri", "msg", "--json", "outputs"];
        outputsProc.running = true;
    }
    
    // Check if Niri is available
    function checkAvailability(): void {
        niriCheckProc.command = ["niri", "msg", "--json", "outputs"];
        niriCheckProc.running = true;
    }

    // Parse workspace JSON data
    function parseWorkspaces(jsonString: string): void {
        try {
            const data = JSON.parse(jsonString);
            let activeWs = 1;
            let monitorMap = {};
            let currentMonitorIndex = 1;
            let currentMonitorCount = 1;
            let focusedMon = "";
            let activeWorkspaceData = null;
            
            // Group workspaces by monitor
            for (let ws of data) {
                if (!monitorMap[ws.output]) {
                    monitorMap[ws.output] = [];
                }
                monitorMap[ws.output].push({
                    id: ws.id,
                    index: ws.idx,
                    name: ws.name || null,
                    is_active: ws.is_active,
                    is_focused: ws.is_focused,
                    has_windows: ws.active_window_id !== null
                });
                
                // Find the currently focused workspace (the one that has focus)
                if (ws.is_focused) {
                    activeWs = ws.id;
                    focusedMon = ws.output;
                    activeWorkspaceData = ws;
                }
            }
            
            // If no focused workspace found, fall back to active workspace
            if (!activeWorkspaceData) {
                for (let ws of data) {
                    if (ws.is_active) {
                        activeWs = ws.id;
                        focusedMon = ws.output;
                        activeWorkspaceData = ws;
                        break;
                    }
                }
            }
            
            // Update focused monitor data
            if (focusedMon && monitorMap[focusedMon] && activeWorkspaceData) {
                focusedMonitor = focusedMon;
                
                // Sort workspaces by index (idx) to get proper vertical order
                monitorMap[focusedMon].sort((a, b) => a.index - b.index);
                currentMonitorCount = monitorMap[focusedMon].length;
                
                // Set workspace name and status
                currentWorkspaceName = activeWorkspaceData.name || "";
                currentWorkspaceIsNamed = !!activeWorkspaceData.name;
                
                // Find the active workspace's position in the sorted list
                for (let i = 0; i < monitorMap[focusedMon].length; i++) {
                    if (monitorMap[focusedMon][i].id === activeWorkspaceData.id) {
                        currentMonitorWorkspaceIndex = i + 1; // 1-based indexing
                        break;
                    }
                }
            }
            
            workspaceData = data;
            activeWorkspace = activeWs;
            monitorWorkspaces = monitorMap;
            currentMonitorWorkspaceCount = currentMonitorCount;
            
            let displayName = currentWorkspaceIsNamed ? `"${currentWorkspaceName}"` : `${currentMonitorWorkspaceIndex}/${currentMonitorWorkspaceCount}`;
            console.log("NiriService: Monitor", focusedMonitor, "- Workspace", displayName, "- ID:", activeWs, "- Named:", currentWorkspaceIsNamed);
            
            // Emit signals for immediate UI updates
            workspaceChanged();
            activeWorkspaceChanged();
        } catch (e) {
            console.warn("Failed to parse workspace data:", e);
            // Fallback to minimal workspace state
            workspaces = [1];
            currentMonitorWorkspaceIndex = 1;
            currentMonitorWorkspaceCount = 1;
            focusedMonitor = "default";
            currentWorkspaceName = "";
            currentWorkspaceIsNamed = false;
        }
    }

    // Component initialization
    Component.onCompleted: {
        checkAvailability();
        updateWorkspaces();
        updateTimer.start();
        
        // Start workspace event monitor
        startWorkspaceMonitor();
    }

    // Function to start workspace change monitoring
    function startWorkspaceMonitor(): void {
        // Use niri msg --json events to monitor workspace changes in real-time
        workspaceMonitorProc.command = ["niri", "msg", "--json", "event-stream"];
        workspaceMonitorProc.running = true;
    }

    Process {
        id: switchProc
    }

    Process {
        id: dispatchProc
        onExited: {
            // Trigger immediate update after any action completes
            Qt.callLater(() => immediateUpdateTimer.start());
        }
    }

    Process {
        id: setNameProc
        onExited: {
            if (exitCode === 0) {
                Qt.callLater(() => updateWorkspaces());
            }
        }
    }

    Process {
        id: unsetNameProc
        onExited: {
            if (exitCode === 0) {
                Qt.callLater(() => updateWorkspaces());
            }
        }
    }

    Process {
        id: workspaceQueryProc
        stdout: SplitParser {
            onRead: data => {
                let jsonData = data.trim();
                if (jsonData.length > 0) {
                    parseWorkspaces(jsonData);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.warn("Niri workspace query error:", data);
            }
        }
    }

    Process {
        id: workspaceMonitorProc
        running: false
        stdout: SplitParser {
            onRead: data => {
                let jsonData = data.trim();
                if (jsonData.length > 0) {
                    try {
                        const event = JSON.parse(jsonData);
                        // Listen for workspace-related events
                        if (event.WorkspaceActivated || event.WorkspaceFocused || 
                            event.WorkspaceAdded || event.WorkspaceRemoved) {
                            console.log("Workspace event detected:", JSON.stringify(event));
                            // Trigger immediate workspace update
                            Qt.callLater(() => updateWorkspaces());
                        }
                    } catch (e) {
                        console.log("Event data:", jsonData);
                    }
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.warn("Niri event monitor error:", data);
            }
        }
    }

    Process {
        id: queryProc
        command: ["niri", "msg", "version"] // Simple command to test niri availability
        running: true
        stdout: SplitParser {
            onRead: data => {
                // console.log("Niri is available");
                updateWorkspaces(); // Initial workspace update
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.log("Niri commands may not be available");
            }
        }
    }

    Timer {
        id: updateTimer
        running: true
        repeat: true
        interval: 500 // Update every 500ms for much more responsive workspace switching
        onTriggered: updateWorkspaces()
    }

    Timer {
        id: immediateUpdateTimer
        running: false
        repeat: false
        interval: 50 // Immediate update after 50ms delay
        onTriggered: updateWorkspaces()
    }

    // Additional processes for IPC functionality
    Process {
        id: moveWindowProc
        onExited: {
            if (exitCode === 0) {
                Qt.callLater(() => {
                    updateWorkspaces();
                    getAllWindows();
                });
            }
        }
    }
    
    Process {
        id: closeWindowProc
        onExited: {
            if (exitCode === 0) {
                Qt.callLater(() => getAllWindows());
            }
        }
    }
    
    Process {
        id: fullscreenProc
    }
    
    Process {
        id: spawnProc
        onExited: {
            if (exitCode === 0) {
                Qt.callLater(() => getAllWindows());
            }
        }
    }
    
    Process {
        id: focusedWindowProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    root.focusedWindow = response.Ok?.FocusedWindow || null;
                } catch (e) {
                    console.error("Failed to parse focused window:", e);
                }
            }
        }
    }
    
    Process {
        id: windowsProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    root.windows = response.Ok || [];
                    root.windowCount = root.windows.length;
                } catch (e) {
                    console.error("Failed to parse windows:", e);
                }
            }
        }
    }
    
    Process {
        id: outputsProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    root.outputs = response.Ok || [];
                } catch (e) {
                    console.error("Failed to parse outputs:", e);
                }
            }
        }
    }
    
    Process {
        id: niriCheckProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    JSON.parse(data);
                    root.available = true;
                    console.log("Niri IPC: Connected to compositor");
                } catch (e) {
                    root.available = false;
                    console.warn("Niri IPC: Failed to connect");
                }
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
            }
        }
    }
}
