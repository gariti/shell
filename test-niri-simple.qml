import "services-niri"
import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // Simple test window to verify Niri integration
    Scope {
        PanelWindow {
            id: testPanel
            
            screen: Quickshell.screens[0]
            anchors {
                left: true
                right: true
                top: true
            }
            
            height: 40
            
            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        text: "Niri Test - Workspaces: " + (Hyprland.workspaces.length || 0)
                        color: "white"
                    }
                    
                    Text {
                        text: "Windows: " + (Hyprland.clients.length || 0)
                        color: "white"
                    }
                    
                    Text {
                        text: "Active WS: " + (Hyprland.activeWsId || "none")
                        color: "white"
                    }
                }
            }
        }
    }
}
