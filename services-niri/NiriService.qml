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
            
            // console.log("Updated workspaces:", workspaces, "Active:", activeWorkspace);
        } catch (e) {
            console.warn("Failed to parse workspace data:", e);
            // Fallback to static workspaces
            workspaces = [1, 2, 3, 4, 5];
        }
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
        running: true
        repeat: true
        interval: 2000 // Update every 2 seconds for more responsive workspace switching
        onTriggered: updateWorkspaces()
    }
}
