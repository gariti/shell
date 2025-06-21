pragma Singleton

import "../utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string currentValuePath: `${Paths.state}/transparency/last.txt`.slice(7)

    property real actualCurrent: 1.0

    readonly property real current: actualCurrent

    function setTransparency(value: real): void {
        actualCurrent = Math.max(0.1, Math.min(1.0, value));
        setTransparencyProc.transparencyValue = actualCurrent;
        setTransparencyProc.startDetached();
        
        // Also update any shell windows immediately
        shellTransparency.setOpacity(actualCurrent);
    }

    reloadableId: "transparency"

    IpcHandler {
        target: "transparency"

        function get(): real {
            return root.actualCurrent;
        }

        function set(value: real): void {
            root.setTransparency(value);
        }

        function increase(): void {
            root.setTransparency(Math.min(1.0, root.actualCurrent + 0.05));
        }

        function decrease(): void {
            root.setTransparency(Math.max(0.1, root.actualCurrent - 0.05));
        }
    }

    FileView {
        path: root.currentValuePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const value = parseFloat(text().trim());
            if (!isNaN(value)) {
                root.actualCurrent = value;
            }
        }
    }

    Process {
        id: setTransparencyProc

        property real transparencyValue

        command: ["caelestia", "shell", "transparency", transparencyValue.toString()]
    }

    // Fallback transparency controller for shell windows
    QtObject {
        id: shellTransparency

        function setOpacity(value: real): void {
            // This would need to be connected to actual shell window opacity
            // For now, just log the change
            console.log("Setting shell transparency to:", value);
        }
    }
}
