import "services-niri"
import "widgets"
import "config"
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    // Shared workspace switching process
    Process {
        id: workspaceProcess
    }
    
    // Main shell for each screen
    Variants {
        model: Quickshell.screens

        Scope {
            required property ShellScreen modelData
            
            // Left sidebar shell
            PanelWindow {
                id: mainBar
                screen: modelData
                anchors {
                    left: true
                    top: true
                    bottom: true
                }
                
                WlrLayershell.namespace: "caelestia-shell"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusionMode: ExclusionMode.Normal
                
                color: "transparent"
                implicitWidth: 60
                
                Rectangle {
                    anchors.fill: parent
                    color: "#141318" // Force explicit dark background color
                    radius: 0
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        // OS Icon - Clickable Application Launcher
                        Rectangle {
                            width: parent.width - 16
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#473F77" // Force explicit primary container color
                            radius: 20
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󱄅"
                                font.pointSize: 18
                                font.family: "Nerd Font"
                                color: "#E5DEFF" // Force explicit on-container color
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Launch application menu
                                    launcherProcess.command = ["sh", "-c", "rofi -show drun || alacritty"]
                                    launcherProcess.startDetached()
                                }
                            }
                            
                            Process {
                                id: launcherProcess
                            }
                        }
                        
                        // Workspaces
                        Rectangle {
                            width: parent.width - 16
                            height: Math.max(160, workspaceColumn.implicitHeight + 16)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#201F25" // Force explicit surface container color
                            radius: 20
                            
                            Column {
                                id: workspaceColumn
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Repeater {
                                    model: NiriService.workspaces.length > 0 ? NiriService.workspaces : [1, 2, 3, 4, 5]
                                    
                                    Rectangle {
                                        width: 30
                                        height: 30
                                        radius: 15
                                        color: modelData === NiriService.activeWorkspace ? 
                                               "#C8BFFF" : "#48454E" // Force explicit workspace colors
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.toString()
                                            font.pointSize: 10
                                            color: modelData === NiriService.activeWorkspace ? 
                                                   "#30285F" : "#C9C5D0" // Force explicit text colors
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                NiriService.switchToWorkspace(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Active Window Info
                        Rectangle {
                            width: parent.width - 16
                            height: 80
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#201F25" // Force explicit surface container color
                            radius: 20
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "󰖲"
                                    font.pointSize: 20
                                    font.family: "Nerd Font"
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Niri"
                                    font.pointSize: 10
                                    color: Colours.palette ? Colours.palette.m3onSurfaceVariant : "#C9C5D0"
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            width: 1
                            height: 1
                        }
                        
                        // System status
                        Rectangle {
                            width: parent.width - 16
                            height: 120
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Colours.palette ? Colours.palette.m3surfaceContainer : "#201F25"
                            radius: 20
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                // Time
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Time.date ? Time.date.toLocaleTimeString(Qt.locale(), "hh:mm") : "00:00"
                                    font.pointSize: 12
                                    font.bold: true
                                    color: Colours.palette ? Colours.palette.m3onSurface : "#E5E1E9"
                                }
                                
                                // Date
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Time.date ? Time.date.toLocaleDateString(Qt.locale(), "MMM dd") : "Jan 01"
                                    font.pointSize: 8
                                    color: Colours.palette ? Colours.palette.m3onSurfaceVariant : "#C9C5D0"
                                }
                                
                                // System indicators
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    
                                    // Volume indicator
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: Audio && Audio.muted ? 
                                               (Colours.palette ? Colours.palette.m3error : "#EA8DC1") : 
                                               (Colours.palette ? Colours.palette.m3primary : "#C8BFFF")
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: Audio && Audio.muted ? "󰖁" : "󰕾"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: Audio && Audio.muted ? 
                                                   (Colours.palette ? Colours.palette.m3onError : "#690005") : 
                                                   (Colours.palette ? Colours.palette.m3onPrimary : "#30285F")
                                        }
                                    }
                                    
                                    // Network indicator
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: Network && Network.connected ? 
                                               (Colours.palette ? Colours.palette.m3primary : "#C8BFFF") : 
                                               (Colours.palette ? Colours.palette.m3surfaceVariant : "#48454E")
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: Network && Network.connected ? "󰤨" : "󰤭"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: Network && Network.connected ? 
                                                   (Colours.palette ? Colours.palette.m3onPrimary : "#30285F") : 
                                                   (Colours.palette ? Colours.palette.m3onSurfaceVariant : "#C9C5D0")
                                        }
                                    }
                                    
                                    // Battery indicator (enhanced with level and charging status)
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: SystemUsage && SystemUsage.isCharging ? 
                                               (Colours.palette ? Colours.palette.m3primaryContainer : "#473F77") :
                                               (SystemUsage && SystemUsage.batteryLevel <= 20 ? 
                                                (Colours.palette ? Colours.palette.m3errorContainer : "#654C4C") :
                                                (Colours.palette ? Colours.palette.m3secondary : "#C9C3DC"))
                                        visible: SystemUsage && SystemUsage.hasBattery
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: SystemUsage && SystemUsage.isCharging ? "󰂄" : "󰁹"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: SystemUsage && SystemUsage.isCharging ?
                                                   (Colours.palette ? Colours.palette.m3onPrimaryContainer : "#E5DEFF") :
                                                   (SystemUsage && SystemUsage.batteryLevel <= 20 ?
                                                    (Colours.palette ? Colours.palette.m3onErrorContainer : "#F2B8B5") :
                                                    (Colours.palette ? Colours.palette.m3onSecondary : "#312E41"))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Battery Status Widget (detailed, if available)
                        Rectangle {
                            width: parent.width - 16
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: SystemUsage && SystemUsage.isCharging ? 
                                   (Colours.palette ? Colours.palette.m3primaryContainer : "#473F77") :
                                   (SystemUsage && SystemUsage.batteryLevel <= 20 ? 
                                    (Colours.palette ? Colours.palette.m3errorContainer : "#654C4C") :
                                    (Colours.palette ? Colours.palette.m3secondaryContainer : "#3E3544"))
                            radius: 20
                            visible: SystemUsage && SystemUsage.hasBattery
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                Text {
                                    text: {
                                        if (SystemUsage && SystemUsage.isCharging) return "󰂄"
                                        if (SystemUsage && SystemUsage.batteryLevel >= 90) return "󰁹"
                                        if (SystemUsage && SystemUsage.batteryLevel >= 80) return "󰂂"
                                        if (SystemUsage && SystemUsage.batteryLevel >= 60) return "󰂀"
                                        if (SystemUsage && SystemUsage.batteryLevel >= 40) return "󰁿"
                                        if (SystemUsage && SystemUsage.batteryLevel >= 20) return "󰁼"
                                        return "󰁺"
                                    }
                                    font.pointSize: 14
                                    font.family: "Nerd Font"
                                    color: SystemUsage && SystemUsage.isCharging ?
                                           (Colours.palette ? Colours.palette.m3onPrimaryContainer : "#E5DEFF") :
                                           (SystemUsage && SystemUsage.batteryLevel <= 20 ?
                                            (Colours.palette ? Colours.palette.m3onErrorContainer : "#F2B8B5") :
                                            (Colours.palette ? Colours.palette.m3onSecondaryContainer : "#E8DEF8"))
                                }
                                
                                Text {
                                    text: SystemUsage ? Math.round(SystemUsage.batteryLevel).toString() + "%" : "0%"
                                    font.pointSize: 10
                                    color: SystemUsage && SystemUsage.isCharging ?
                                           (Colours.palette ? Colours.palette.m3onPrimaryContainer : "#E5DEFF") :
                                           (SystemUsage && SystemUsage.batteryLevel <= 20 ?
                                            (Colours.palette ? Colours.palette.m3onErrorContainer : "#F2B8B5") :
                                            (Colours.palette ? Colours.palette.m3onSecondaryContainer : "#E8DEF8"))
                                }
                            }
                        }
                        
                        // Power button
                        Rectangle {
                            width: parent.width - 16
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Colours.palette ? Colours.palette.m3errorContainer : "#93000A"
                            radius: 20
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                font.pointSize: 16
                                font.family: "Nerd Font"
                                color: Colours.palette ? Colours.palette.m3onErrorContainer : "#FFDAD6"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.LeftButton) {
                                        // Left click: show session menu
                                        sessionProcess.command = ["sh", "-c", "echo -e 'Logout\\nShutdown\\nReboot\\nSuspend' | rofi -dmenu -p 'Session' | xargs -I {} sh -c 'case {} in Logout) loginctl terminate-session ;; Shutdown) systemctl poweroff ;; Reboot) systemctl reboot ;; Suspend) systemctl suspend ;; esac'"]
                                        sessionProcess.startDetached()
                                    } else if (mouse.button === Qt.RightButton) {
                                        // Right click: immediate logout
                                        powerProcess.command = ["loginctl", "terminate-session", ""]
                                        powerProcess.startDetached()
                                    }
                                }
                            }
                            
                            Process {
                                id: sessionProcess
                            }
                            
                            Process {
                                id: powerProcess
                            }
                        }
                    }
                }
            }
        }
    }
}
