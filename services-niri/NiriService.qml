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
    
    // Additional Niri state
    property var windows: []
    property var focusedWindow: null
    property var outputs: []
    property bool available: false

    // Function to switch workspaces via niri msg
    function switchToWorkspace(id: int): void {
        switchProc.command = ["niri", "msg", "action", "focus-workspace", id.toString()];
        switchProc.startDetached();
        activeWorkspace = id; // Update immediately for UI responsiveness
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
            let workspaceList = [];
            let activeWs = 1;
            
            for (let ws of data) {
                workspaceList.push(ws.idx);
                if (ws.is_focused) {
                    activeWs = ws.idx;
                }
            }
            
            workspaces = workspaceList.length > 0 ? workspaceList : [1, 2, 3, 4, 5];
            workspaceData = data;
            activeWorkspace = activeWs;
            
            console.log("NiriService: Updated workspaces:", workspaces, "Active:", activeWorkspace, "WindowCount:", data.length);
        } catch (e) {
            console.warn("Failed to parse workspace data:", e);
            // Fallback to static workspaces
            workspaces = [1, 2, 3, 4, 5];
        }
    }

    // Component initialization
    Component.onCompleted: {
        checkAvailability();
        updateWorkspaces();
        updateTimer.start();
    }

    Process {
        id: switchProc
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
        interval: 2000 // Update every 2 seconds for more responsive workspace switching
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
