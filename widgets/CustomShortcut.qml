import Quickshell
import Quickshell.Io
import QtQuick

// Niri-compatible custom shortcut implementation
Item {
    property string name: ""
    property string description: ""
    
    signal pressed()
    signal released()
    
    // For Niri, global shortcuts are handled via keybindings in config.kdl
    // This is a placeholder for compatibility - actual shortcuts are configured in Niri
    Component.onCompleted: {
        if (name && description) {
            console.log(`Custom shortcut registered: ${name} - ${description}`)
        }
    }
}
