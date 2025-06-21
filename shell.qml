import "modules"
import "modules/background"
import "modules/drawers"
import "services-niri"
import "config"
import "widgets"
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

ShellRoot {
    // Use the full original shell system with drawers - now with Niri compatibility
    Background {}
    Shortcuts {}
    Drawers {}
    
    // Force instantiation of IPC service singletons
    Component.onCompleted: {
        // Reference singletons to ensure they are instantiated and IPC handlers are registered
        console.log("Transparency current:", Transparency.current);
        console.log("EventStream active:", EventStream.eventStreamActive);
        console.log("NiriWorkspaces count:", NiriWorkspaces.workspaces.length);
    }
}
