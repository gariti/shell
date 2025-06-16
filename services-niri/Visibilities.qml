pragma Singleton

import Quickshell
import "../utils"

Singleton {
    property var screens: ({})
    property var panels: ({})

    function getForActive(): PersistentProperties {
        // For Niri compatibility, try to get the preferred launcher screen first
        const preferredScreen = DisplayManager.getPreferredLauncherScreen();
        if (preferredScreen) {
            const screenEntries = Object.entries(screens);
            for (const [key, value] of screenEntries) {
                // Check if this entry corresponds to the preferred screen
                if (key.includes(preferredScreen.name)) {
                    console.log("Visibilities: Using preferred screen for launcher:", preferredScreen.name);
                    return value;
                }
            }
        }
        
        // Fallback: return the first available screen
        const screenEntries = Object.entries(screens);
        if (screenEntries.length > 0) {
            console.log("Visibilities: Using fallback screen for launcher");
            return screenEntries[0][1];
        }
        
        // Return default if no screens available
        return null;
    }
    
    // Get visibilities for a specific screen
    function getForScreen(screen): PersistentProperties {
        if (!screen) return null;
        
        const screenEntries = Object.entries(screens);
        for (const [key, value] of screenEntries) {
            if (key.includes(screen.name)) {
                return value;
            }
        }
        return null;
    }
}
