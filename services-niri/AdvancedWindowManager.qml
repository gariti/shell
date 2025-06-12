pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Enhanced window management properties
    property var windows: []
    property var focusedWindow: null
    property var workspaces: []
    property var outputs: []
    
    // Advanced window state tracking
    property var windowHistory: []  // Focus history tracking
    property var floatingWindows: []  // Floating state detection
    property var fullscreenWindows: []  // Fullscreen state management
    property var workspaceAssignments: ({})  // Window workspace tracking
    property var urgentWindows: []  // Urgent window tracking
    
    // Window management statistics
    property int totalWindows: 0
    property int floatingCount: 0
    property int fullscreenCount: 0
    property bool eventStreamActive: false
    
    // Advanced window management functions
    function getWindowById(id: int): var {
        return windows.find(w => w.id === id) || null;
    }
    
    function getWindowsByWorkspace(workspaceId: int): var {
        return windows.filter(w => w.workspace_id === workspaceId);
    }
    
    function getFloatingWindows(): var {
        return windows.filter(w => w.is_floating === true);
    }
    
    function getFullscreenWindows(): var {
        return fullscreenWindows;
    }
    
    function getUrgentWindows(): var {
        return windows.filter(w => w.is_urgent === true);
    }
    
    // Window state management
    function toggleWindowFloating(windowId = -1) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
            Qt.callLater(() => {
                toggleFloatingProc.command = ["niri", "msg", "action", "toggle-window-floating"];
                toggleFloatingProc.running = true;
            });
        } else {
            toggleFloatingProc.command = ["niri", "msg", "action", "toggle-window-floating"];
            toggleFloatingProc.running = true;
        }
    }
    
    function setWindowFloating(windowId = -1, floating = true) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
        }
        Qt.callLater(() => {
            const action = floating ? "move-window-to-floating" : "move-window-to-tiling";
            setFloatingProc.command = ["niri", "msg", "action", action];
            setFloatingProc.running = true;
        });
    }
    
    function toggleWindowFullscreen(windowId = -1) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
        }
        Qt.callLater(() => {
            fullscreenProc.command = ["niri", "msg", "action", "fullscreen-window"];
            fullscreenProc.running = true;
        });
    }
    
    function moveWindowToWorkspace(windowId, workspaceRef) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
        }
        Qt.callLater(() => {
            moveToWorkspaceProc.command = ["niri", "msg", "action", "move-window-to-workspace", workspaceRef];
            moveToWorkspaceProc.running = true;
        });
    }
    
    function setWindowUrgent(windowId, urgent = true) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
        }
        Qt.callLater(() => {
            const action = urgent ? "set-window-urgent" : "unset-window-urgent";
            urgentProc.command = ["niri", "msg", "action", action];
            urgentProc.running = true;
        });
    }
    
    function focusPreviousWindow() {
        focusPrevProc.command = ["niri", "msg", "action", "focus-window-previous"];
        focusPrevProc.running = true;
    }
    
    function closeWindow(windowId = -1) {
        if (windowId > 0) {
            focusWindowProc.command = ["niri", "msg", "action", "focus-window", windowId.toString()];
            focusWindowProc.running = true;
        }
        Qt.callLater(() => {
            closeProc.command = ["niri", "msg", "action", "close-window"];
            closeProc.running = true;
        });
    }
    
    // Advanced workspace management
    function getWorkspaceWindows(workspaceId: int): var {
        return windows.filter(w => w.workspace_id === workspaceId);
    }
    
    function getActiveWorkspace(): var {
        return workspaces.find(w => w.is_focused === true) || null;
    }
    
    function getWorkspaceByName(name: string): var {
        return workspaces.find(w => w.name === name) || null;
    }
    
    // Focus history management  
    function addToHistory(windowId) {
        if (windowId && windowId !== (windowHistory[0] || -1)) {
            windowHistory.unshift(windowId);
            // Keep only last 10 windows in history
            if (windowHistory.length > 10) {
                windowHistory = windowHistory.slice(0, 10);
            }
        }
    }
    
    function getPreviousWindow(): var {
        if (windowHistory.length > 1) {
            return getWindowById(windowHistory[1]);
        }
        return null;
    }
    
    // Data refresh functions
    function refreshAll() {
        refreshWindows();
        refreshWorkspaces();
        refreshOutputs();
    }
    
    function refreshWindows() {
        windowsProc.command = ["niri", "msg", "--json", "windows"];
        windowsProc.running = true;
    }
    
    function refreshWorkspaces() {
        workspacesProc.command = ["niri", "msg", "--json", "workspaces"];
        workspacesProc.running = true;
    }
    
    function refreshOutputs() {
        outputsProc.command = ["niri", "msg", "--json", "outputs"];
        outputsProc.running = true;
    }
    
    function refreshFocusedWindow() {
        focusedWindowProc.command = ["niri", "msg", "--json", "focused-window"];
        focusedWindowProc.running = true;
    }
    
    // Event stream management
    function startEventStream() {
        if (!eventStreamActive) {
            console.log("AdvancedWindowManager: Starting event stream");
            eventStreamProc.running = true;
            eventStreamActive = true;
        }
    }
    
    function stopEventStream() {
        if (eventStreamActive) {
            console.log("AdvancedWindowManager: Stopping event stream");
            eventStreamProc.running = false;
            eventStreamActive = false;
        }
    }
    
    // Helper functions
    function updateStatistics() {
        totalWindows = windows.length;
        floatingCount = windows.filter(w => w.is_floating === true).length;
        fullscreenCount = fullscreenWindows.length;
    }
    
    function updateWorkspaceAssignments() {
        let assignments = {};
        for (const window of windows) {
            if (window.workspace_id) {
                if (!assignments[window.workspace_id]) {
                    assignments[window.workspace_id] = [];
                }
                assignments[window.workspace_id].push(window);
            }
        }
        workspaceAssignments = assignments;
    }
    
    // Sync function for compatibility with Hyprland service
    function syncWindowData(clientData) {
        // Update our internal window data with client data from Hyprland compatibility layer
        if (clientData && Array.isArray(clientData)) {
            // Extract relevant window information and update our tracking
            for (const client of clientData) {
                if (client.windowId) {
                    addToHistory(client.windowId);
                    
                    // Update fullscreen tracking
                    if (client.fullscreen && !fullscreenWindows.includes(client.windowId)) {
                        fullscreenWindows.push(client.windowId);
                    } else if (!client.fullscreen && fullscreenWindows.includes(client.windowId)) {
                        const index = fullscreenWindows.indexOf(client.windowId);
                        fullscreenWindows.splice(index, 1);
                    }
                    
                    // Update floating tracking
                    if (client.floating && !floatingWindows.includes(client.windowId)) {
                        floatingWindows.push(client.windowId);
                    } else if (!client.floating && floatingWindows.includes(client.windowId)) {
                        const index = floatingWindows.indexOf(client.windowId);
                        floatingWindows.splice(index, 1);
                    }
                    
                    // Update urgent tracking
                    if (client.urgent && !urgentWindows.includes(client.windowId)) {
                        urgentWindows.push(client.windowId);
                    } else if (!client.urgent && urgentWindows.includes(client.windowId)) {
                        const index = urgentWindows.indexOf(client.windowId);
                        urgentWindows.splice(index, 1);
                    }
                    
                    // Update workspace windows mapping
                    if (client.workspace) {
                        if (!workspaceWindows[client.workspace]) {
                            workspaceWindows[client.workspace] = [];
                        }
                        if (!workspaceWindows[client.workspace].find(w => w.windowId === client.windowId)) {
                            workspaceWindows[client.workspace].push(client);
                        }
                    }
                }
            }
        }
    }
    
    // Process definitions
    Process {
        id: windowsProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    root.windows = response || [];
                    updateStatistics();
                    updateWorkspaceAssignments();
                } catch (e) {
                    console.error("AdvancedWindowManager: Failed to parse windows:", e);
                }
            }
        }
    }
    
    Process {
        id: workspacesProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    root.workspaces = response || [];
                } catch (e) {
                    console.error("AdvancedWindowManager: Failed to parse workspaces:", e);
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
                    root.outputs = response || [];
                } catch (e) {
                    console.error("AdvancedWindowManager: Failed to parse outputs:", e);
                }
            }
        }
    }
    
    Process {
        id: focusedWindowProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const response = JSON.parse(data);
                    const newFocused = response || null;
                    if (newFocused && newFocused.id !== (root.focusedWindow?.id || -1)) {
                        root.focusedWindow = newFocused;
                        addToHistory(newFocused.id);
                    }
                } catch (e) {
                    console.error("AdvancedWindowManager: Failed to parse focused window:", e);
                }
            }
        }
    }
    
    // Real-time event stream processor
    Process {
        id: eventStreamProc
        command: ["niri", "msg", "event-stream"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    // Parse event stream data
                    if (data.includes("Windows changed:")) {
                        refreshWindows();
                    } else if (data.includes("Workspaces changed:")) {
                        refreshWorkspaces();
                    } else if (data.includes("Window focused:") || data.includes("Window unfocused:")) {
                        refreshFocusedWindow();
                    }
                } catch (e) {
                    console.error("AdvancedWindowManager: Event stream error:", e);
                }
            }
        }
        onExited: {
            eventStreamActive = false;
            if (exitCode !== 0) {
                console.warn("AdvancedWindowManager: Event stream ended with code:", exitCode);
            }
        }
    }
    
    // Action processes
    Process { id: focusWindowProc }
    Process { id: toggleFloatingProc }
    Process { id: setFloatingProc }
    Process { id: fullscreenProc }
    Process { id: moveToWorkspaceProc }
    Process { id: urgentProc }
    Process { id: focusPrevProc }
    Process { id: closeProc }
    
    // Periodic refresh timer (fallback if event stream fails)
    Timer {
        id: refreshTimer
        interval: 3000
        repeat: true
        running: !eventStreamActive
        onTriggered: {
            refreshAll();
            refreshFocusedWindow();
        }
    }
    
    // Initialization
    Component.onCompleted: {
        console.log("AdvancedWindowManager: Initializing");
        refreshAll();
        refreshFocusedWindow();
        // Start event stream for real-time updates
        Qt.callLater(startEventStream);
    }
    
    Component.onDestruction: {
        stopEventStream();
    }
}
