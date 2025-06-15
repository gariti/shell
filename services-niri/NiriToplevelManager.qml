pragma Singleton

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Provide both ToplevelManager and Niri-specific window data
    readonly property var toplevels: ToplevelManager.toplevels
    
    // Niri-specific window information
    property list<QtObject> niriWindows: []
    property QtObject focusedWindow: null
    
    // Function to get Niri window data
    function updateNiriWindows(): void {
        windowQuery.running = true;
    }
    
    // Function to find toplevel by Niri window data
    function findToplevelByNiriWindow(niriWin: QtObject): QtObject {
        if (!niriWin) {
            console.log("NiriToplevelManager: No niri window provided");
            return null;
        }
        
        console.log("NiriToplevelManager: Looking for toplevel for window:", niriWin.title, "class:", niriWin.wmClass);
        console.log("NiriToplevelManager: Available toplevels:", ToplevelManager.toplevels.values.length);
        
        // Try to match by title first
        let toplevel = ToplevelManager.toplevels.values.find(t => t.title === niriWin.title);
        console.log("NiriToplevelManager: Title match result:", toplevel ? "FOUND" : "NOT FOUND");
        
        // If not found, try by app_id
        if (!toplevel && niriWin.wmClass) {
            toplevel = ToplevelManager.toplevels.values.find(t => t.appId === niriWin.wmClass);
            console.log("NiriToplevelManager: AppId match result:", toplevel ? "FOUND" : "NOT FOUND");
        }
        
        console.log("NiriToplevelManager: Final result:", toplevel ? "TOPLEVEL FOUND" : "NO TOPLEVEL");
        return toplevel || null;
    }
    
    Process {
        id: windowQuery
        command: ["niri", "msg", "--json", "windows"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const windows = JSON.parse(data);
                    const newWindows = [];
                    let focused = null;
                    
                    for (const win of windows) {
                        const windowObj = windowComponent.createObject(root, {
                            id: win.id,
                            title: win.title,
                            app_id: win.app_id,
                            workspace_id: win.workspace_id,
                            is_focused: win.is_focused,
                            is_floating: win.is_floating
                        });
                        
                        newWindows.push(windowObj);
                        
                        if (win.is_focused) {
                            focused = windowObj;
                        }
                    }
                    
                    root.niriWindows = newWindows;
                    root.focusedWindow = focused;
                } catch (e) {
                    console.error("Failed to parse Niri window data:", e);
                }
            }
        }
    }
    
    Component {
        id: windowComponent
        QtObject {
            property int id: 0
            property string title: ""
            property string app_id: ""
            property int workspace_id: 1
            property bool is_focused: false
            property bool is_floating: false
        }
    }
    
    Timer {
        running: true
        interval: 1000
        repeat: true
        onTriggered: root.updateNiriWindows()
    }
    
    Component.onCompleted: updateNiriWindows()
}
