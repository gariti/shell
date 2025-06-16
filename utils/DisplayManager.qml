pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Properties to track display preferences
    property var externalDisplayNames: ["DP-3", "DP-1", "DP-2", "HDMI-A-1", "HDMI-A-2", "DVI-D-1"]
    property var internalDisplayNames: ["eDP-1", "LVDS-1", "DSI-1"]
    
    // Get the preferred screen for the launcher
    function getPreferredLauncherScreen() {
        const screens = Quickshell.screens;
        
        // First, try to find an external display
        for (const screen of screens) {
            if (isExternalDisplay(screen)) {
                console.log("DisplayManager: Found external display for launcher:", screen.name);
                return screen;
            }
        }
        
        // If no external display found, return the first screen (fallback)
        console.log("DisplayManager: No external display found, using first screen:", screens[0]?.name);
        return screens[0] || null;
    }
    
    // Get all screens that should show the shell components (bars, etc.)
    function getAllShellScreens() {
        return Quickshell.screens;
    }
    
    // Check if a screen is an external display
    function isExternalDisplay(screen) {
        if (!screen || !screen.name) return false;
        
        // Use exact matching or more specific patterns to avoid substring conflicts
        return externalDisplayNames.some(name => {
            if (name === screen.name) return true;
            // For DP ports, ensure it's not an embedded display (eDP)
            if (name.startsWith("DP-") && screen.name.startsWith("DP-")) return true;
            if (name.startsWith("HDMI") && screen.name.includes("HDMI")) return true;
            if (name.startsWith("DVI") && screen.name.includes("DVI")) return true;
            return false;
        });
    }
    
    // Check if a screen is an internal display
    function isInternalDisplay(screen) {
        if (!screen || !screen.name) return false;
        
        return internalDisplayNames.some(name => screen.name === name);
    }
    
    // Get display type string for debugging
    function getDisplayType(screen) {
        if (isExternalDisplay(screen)) return "external";
        if (isInternalDisplay(screen)) return "internal";
        return "unknown";
    }
    
    // Debug function to log all displays
    function debugDisplays() {
        const screens = Quickshell.screens;
        console.log("DisplayManager: Available displays:");
        for (let i = 0; i < screens.length; i++) {
            const screen = screens[i];
            const width = screen.geometry ? screen.geometry.width : "unknown";
            const height = screen.geometry ? screen.geometry.height : "unknown";
            const isExt = isExternalDisplay(screen);
            const isInt = isInternalDisplay(screen);
            console.log(`  ${i}: ${screen.name} (external: ${isExt}, internal: ${isInt}) - ${width}x${height}`);
        }
        
        const preferred = getPreferredLauncherScreen();
        console.log("DisplayManager: Preferred launcher screen:", preferred?.name || "none");
    }
    
    Component.onCompleted: {
        debugDisplays();
    }
}
