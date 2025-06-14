import "services-niri"
import "config"
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        anchors {
            left: true
            right: true
            top: true
        }
        
        height: 48
        color: Colours.palette.m3surface // Use proper color service
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            
            // Left: Workspace indicator
            Rectangle {
                Layout.preferredWidth: 60
                Layout.fillHeight: true
                color: Colours.palette.m3primary // Use proper color service
                radius: Appearance.rounding.normal
                
                Text {
                    anchors.centerIn: parent
                    text: "Niri"
                    color: Colours.palette.m3onPrimary
                    font.family: Appearance.font.family.sans
                    font.weight: Font.Medium
                }
            }
            
            // Center: Spacer
            Item {
                Layout.fillWidth: true
            }
            
            // Center: Time and Date (now with live updates)
            Column {
                Layout.alignment: Qt.AlignCenter
                spacing: 2
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Time.time // Live time from service
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.sans
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Time.date // Live date from service
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.sans
                    font.pixelSize: 12
                }
            }
            
            // Right: Spacer
            Item {
                Layout.fillWidth: true
            }
            
            // Right: System indicators
            Row {
                spacing: Appearance.spacing.normal
                
                // Network indicator
                Rectangle {
                    width: 32
                    height: 32
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📶"
                        font.pixelSize: 16
                    }
                }
                
                // Audio indicator with real status
                Rectangle {
                    width: 32
                    height: 32
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: Audio.muted ? "🔇" : "🔊"
                        font.pixelSize: 16
                    }
                }
                
                // Settings indicator
                Rectangle {
                    width: 32
                    height: 32
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⚙️"
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
