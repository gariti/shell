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
        
        implicitHeight: 48
        color: Colours.palette.m3surface
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            
            // Left: Workspace indicator
            Rectangle {
                Layout.preferredWidth: 80
                Layout.fillHeight: true
                color: Colours.palette.m3primary
                radius: Appearance.rounding.normal
                
                Text {
                    anchors.centerIn: parent
                    text: "Niri"
                    color: Colours.palette.m3onPrimary
                    font.family: Appearance.font.family.sans
                    font.weight: Font.Medium
                }
            }
            
            // Left spacer
            Item {
                Layout.fillWidth: true
            }
            
            // Center: Time and Date
            Column {
                Layout.alignment: Qt.AlignCenter
                spacing: 2
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Time.time
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.sans
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Time.date
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.sans
                    font.pixelSize: 12
                }
            }
            
            // Right spacer
            Item {
                Layout.fillWidth: true
            }
            
            // Right: System indicators
            Row {
                spacing: Appearance.spacing.normal
                
                // Network indicator
                Rectangle {
                    width: 36
                    height: 36
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: Network.connected ? "📶" : "📵"
                        font.pixelSize: 16
                    }
                    
                    // Hover effect
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceVariant
                        onExited: parent.color = "transparent"
                    }
                }
                
                // Audio indicator  
                Rectangle {
                    width: 36
                    height: 36
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: Audio.muted ? "🔇" : "🔊"
                        font.pixelSize: 16
                    }
                    
                    // Click to toggle mute
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceVariant
                        onExited: parent.color = "transparent"
                        onClicked: Audio.toggleMute()
                    }
                }
                
                // Battery indicator (if available)
                Rectangle {
                    width: 36
                    height: 36
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    visible: SystemUsage.hasBattery
                    
                    Text {
                        anchors.centerIn: parent
                        text: "🔋"
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceVariant
                        onExited: parent.color = "transparent"
                    }
                }
                
                // Settings indicator
                Rectangle {
                    width: 36
                    height: 36
                    color: "transparent"
                    border.color: Colours.palette.m3outline
                    border.width: 1
                    radius: Appearance.rounding.small
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⚙️"
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceVariant
                        onExited: parent.color = "transparent"
                        onClicked: {
                            // Future: Open settings menu
                            console.log("Settings clicked")
                        }
                    }
                }
            }
        }
    }
}
