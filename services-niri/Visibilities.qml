pragma Singleton

import Quickshell

Singleton {
    property var screens: ({})
    property var panels: ({})

    function getForActive(): PersistentProperties {
        // For Niri compatibility, return the first available screen or create default
        const screenEntries = Object.entries(screens);
        if (screenEntries.length > 0) {
            return screenEntries[0][1];
        }
        // Return default if no screens available
        return null;
    }
}
