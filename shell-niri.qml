// filepath: /etc/nixos/caelestia-shell/shell-niri.qml
import "modules"
import "modules/drawers"
import "modules/background"
import "modules/bar" as Bar
import "modules/bar/popouts" as BarPopouts
import "widgets"
import "services"
import "config"
import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // Background wallpaper
    Background {}
    
    // Main panel for Niri - using actual caelestia Bar component
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData
            
            screen: modelData
            anchors {
                left: true
                top: true
                bottom: true
            }
            
            implicitWidth: bar.implicitWidth + BorderConfig.thickness * 2
            
            WlrLayershell.namespace: "caelestia-shell"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            
            color: Colours.palette.m3surfaceContainerLowest
            
            BarPopouts.Wrapper {
                id: popouts
                screen: modelData
            }
            
            Bar.Bar {
                id: bar
                screen: modelData
                popouts: popouts
                
                anchors.fill: parent
            }
        }
    }
    
    // Drawers (for expanded functionality)
    Drawers {}
    
    // Shortcuts for global hotkeys (but disabled for Niri)
    // Shortcuts {}
}
