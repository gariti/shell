import QtQuick
import "./services-niri"

QtObject {
    id: testApp
    
    Component.onCompleted: {
        console.log("Testing AdvancedWindowManager...");
        
        // Test data access
        console.log("Total windows:", AdvancedWindowManager.totalWindows);
        console.log("Floating windows:", AdvancedWindowManager.floatingWindows);
        console.log("Fullscreen windows:", AdvancedWindowManager.fullscreenWindows);
        console.log("Focus history:", AdvancedWindowManager.focusHistory);
        console.log("Workspace windows:", JSON.stringify(AdvancedWindowManager.workspaceWindows));
        
        // Test Hyprland compatibility
        console.log("Hyprland clients:", Hyprland.clients.length);
        console.log("Hyprland active workspace ID:", Hyprland.activeWsId);
        console.log("Hyprland occupied workspaces:", JSON.stringify(Hyprland.occupied));
        
        console.log("Advanced window management services test completed!");
    }
}
