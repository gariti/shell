import "services-niri"
import "config"
import "widgets"
import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // Minimal test shell to isolate black shapes issue
    
    Variants {
        model: Quickshell.screens

        StyledWindow {
            required property ShellScreen modelData
            
            screen: modelData
            name: "test-minimal"
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            
            anchors.left: true
            anchors.top: true
            anchors.bottom: true
            
            width: 80
            
            Rectangle {
                anchors.fill: parent
                color: "#141318"
                radius: 15
                
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Rectangle {
                        width: 40
                        height: 40
                        color: Colours.palette.m3primary
                        radius: 20
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🎯"
                            font.pointSize: 20
                        }
                    }
                    
                    Rectangle {
                        width: 40
                        height: 40
                        color: Colours.palette.m3secondary
                        radius: 20
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⏰"
                            font.pointSize: 16
                        }
                    }
                    
                    Rectangle {
                        width: 40
                        height: 40
                        color: Colours.palette.m3tertiary
                        radius: 20
                        
                        Text {
                            anchors.centerIn: parent
                            text: "📶"
                            font.pointSize: 16
                        }
                    }
                }
            }
        }
    }
}
