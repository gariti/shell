pragma Singleton

import "../utils/scripts/fuzzysort.js" as Fuzzy
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<DesktopEntry> list: DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name))
    readonly property list<var> preppedApps: list.map(a => ({
                name: Fuzzy.prepare(a.name),
                comment: Fuzzy.prepare(a.comment),
                entry: a
            }))

    function fuzzyQuery(search: string): var { // Idk why list<DesktopEntry> doesn't work
        return Fuzzy.go(search, preppedApps, {
            all: true,
            keys: ["name", "comment"],
            scoreFn: r => r[0].score > 0 ? r[0].score * 0.9 + r[1].score * 0.1 : 0
        }).map(r => r.obj.entry);
    }

    function launch(entry: DesktopEntry): void {
        if (!entry || !entry.id) {
            console.error("Apps.launch: Invalid entry or missing id");
            return;
        }
        
        console.log("Apps.launch: Launching", entry.id, "with name", entry.name);
        
        // Use a simple Process for each launch
        const procWrapper = launchProc.createObject(root, {
            appId: entry.id
        });
        
        if (!procWrapper) {
            console.error("Apps.launch: Failed to create process wrapper for", entry.id);
        }
    }
    
    Component {
        id: launchProc
        
        Item {
            property string appId
            
            Process {
                id: proc
                command: ["/etc/nixos/caelestia-shell/scripts/launch-detached.sh", appId]
                running: true
                
                onStarted: {
                    console.log("Apps.launch: Process started successfully for", appId);
                    // Destroy this process object after a delay to clean up
                    destroyTimer.start();
                }
                
                onExited: (exitCode, exitStatus) => {
                    console.log("Apps.launch: Process exited with code", exitCode, "status", exitStatus, "for", appId);
                    destroyTimer.start();
                }
            }
            
            Timer {
                id: destroyTimer
                interval: 100
                onTriggered: parent.destroy()
            }
        }
    }
}
