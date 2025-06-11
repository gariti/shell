import "services-niri"
import "widgets"
import "config"
import "modules/drawers"
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
            
            // Border exclusion zones for rounded corners
            Exclusions {
                screen: modelData
                bar: mainBar
            }
            
            // Border and rounded corner window
            StyledWindow {
                id: borderWindow
                screen: modelData
                name: "border-mask"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Background
                
                color: "transparent"
                
                anchors.fill: true
                
                Border {
                    bar: mainBar
                }
            }
            
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
                implicitWidth: 64
                
                // Popout detection function like original Caelestia
                function checkPopout(y: real): void {
                    const spacing = 8;
                    
                    // Calculate positions based on actual layout
                    // System status rectangle starts around y=300, height=120
                    const statusStart = 300;
                    const statusInnerStart = statusStart + 12; // margins
                    
                    // Icon positions within status area
                    const timeHeight = 20; // Time text
                    const timeY = statusInnerStart + 12 + timeHeight;
                    
                    // Battery icon at ~y=340
                    const batteryY = timeY + spacing + 4;
                    
                    // Network icon at ~y=365  
                    const networkY = batteryY + spacing + 20;
                    
                    // Audio icon at ~y=390
                    const audioY = networkY + spacing + 20;
                    
                    // Settings icon at ~y=415
                    const settingsY = audioY + spacing + 20;
                    
                    // Detect which popout should be shown
                    if (y >= batteryY - 10 && y <= batteryY + 20) {
                        console.log("Battery popout area");
                        popoutBattery.visible = true;
                        popoutNetwork.visible = false;
                        popoutAudio.visible = false;
                        popoutSystem.visible = false;
                    } else if (y >= networkY - 10 && y <= networkY + 20) {
                        console.log("Network popout area");
                        popoutBattery.visible = false;
                        popoutNetwork.visible = true;
                        popoutAudio.visible = false;
                        popoutSystem.visible = false;
                    } else if (y >= audioY - 10 && y <= audioY + 20) {
                        console.log("Audio popout area");
                        popoutBattery.visible = false;
                        popoutNetwork.visible = false;
                        popoutAudio.visible = true;
                        popoutSystem.visible = false;
                    } else if (y >= settingsY - 10 && y <= settingsY + 20) {
                        console.log("Settings popout area");
                        popoutBattery.visible = false;
                        popoutNetwork.visible = false;
                        popoutAudio.visible = false;
                        popoutSystem.visible = true;
                    } else {
                        popoutBattery.visible = false;
                        popoutNetwork.visible = false;
                        popoutAudio.visible = false;
                        popoutSystem.visible = false;
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: Colours.palette.m3surface
                    radius: 0
                    
                    // Left bar content
                    Column {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        spacing: 16
                        
                        // OS Icon
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: Colours.palette.m3primaryContainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "apps"
                                font.pointSize: 20
                                color: Colours.palette.m3onPrimaryContainer
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Launching application launcher");
                                    if (Apps.canLaunchRofi) {
                                        Apps.launchRofi();
                                    } else {
                                        Apps.launchTerminal();
                                    }
                                }
                            }
                        }
                        
                        // Workspaces
                        Rectangle {
                            width: 48
                            height: 180
                            radius: 24
                            color: Colours.palette.m3surfaceContainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Repeater {
                                    model: 5
                                    
                                    Rectangle {
                                        required property int index
                                        width: 32
                                        height: 24
                                        radius: 12
                                        color: (index + 1) === workspace.activeWorkspace ? 
                                               Colours.palette.m3primary : 
                                               Colours.palette.m3surfaceContainerHigh
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            font.family: "IBM Plex Sans"
                                            font.pointSize: 10
                                            color: (index + 1) === workspace.activeWorkspace ? 
                                                   Colours.palette.m3onPrimary : 
                                                   Colours.palette.m3onSurface
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            
                                            onEntered: {
                                                parent.scale = 1.1;
                                            }
                                            
                                            onExited: {
                                                parent.scale = 1.0;
                                            }
                                            
                                            onClicked: {
                                                console.log("Switching to workspace", index + 1);
                                                workspace.switchToWorkspace(index + 1);
                                            }
                                        }
                                        
                                        Behavior on scale {
                                            NumberAnimation { duration: 200 }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 300 }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Window info section
                        Rectangle {
                            width: 48
                            height: 60
                            radius: 12
                            color: Colours.palette.m3surfaceContainerLow
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                MaterialIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "computer"
                                    font.pointSize: 16
                                    color: Colours.palette.m3primary
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Niri"
                                    font.family: "IBM Plex Sans"
                                    font.pointSize: 8
                                    color: Colours.palette.m3onSurface
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            height: 1
                            Layout.fillHeight: true
                        }
                        
                        // System status rectangle
                        Rectangle {
                            width: 48
                            height: 120
                            radius: 12
                            color: Colours.palette.m3surfaceContainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onPositionChanged: (mouse) => {
                                    const relativeY = mouse.y + parent.y + parent.parent.y;
                                    mainBar.checkPopout(relativeY);
                                }
                                
                                onExited: {
                                    // Small delay before hiding popouts
                                    hideTimer.start();
                                }
                                
                                onEntered: {
                                    hideTimer.stop();
                                }
                            }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                // Time
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Time.time
                                    font.family: "JetBrains Mono NF"
                                    font.pointSize: 10
                                    font.bold: true
                                    color: Colours.palette.m3onSurface
                                }
                                
                                // Date
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Time.date
                                    font.family: "IBM Plex Sans"
                                    font.pointSize: 8
                                    color: Colours.palette.m3onSurfaceVariant
                                }
                                
                                // Battery icon
                                MaterialIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: SystemUsage && SystemUsage.isCharging ? "battery_charging_full" : "battery_std"
                                    font.pointSize: 16
                                    color: SystemUsage && SystemUsage.batteryLevel <= 20 ? 
                                           Colours.palette.m3error : Colours.palette.m3primary
                                }
                                
                                // Network icon
                                MaterialIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Network.connected ? "wifi" : "wifi_off"
                                    font.pointSize: 16
                                    color: Network.connected ? Colours.palette.m3primary : Colours.palette.m3outline
                                }
                                
                                // Audio icon
                                MaterialIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Audio.muted ? "volume_off" : "volume_up"
                                    font.pointSize: 16
                                    color: Audio.muted ? Colours.palette.m3outline : Colours.palette.m3primary
                                }
                                
                                // Settings icon
                                MaterialIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "settings"
                                    font.pointSize: 16
                                    color: Colours.palette.m3secondary
                                }
                            }
                        }
                        
                        // Power button
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: Colours.palette.m3errorContainer
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "power_settings_new"
                                font.pointSize: 20
                                color: Colours.palette.m3onErrorContainer
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.LeftButton) {
                                        console.log("Opening session menu");
                                        sessionMenu.openSessionMenu();
                                    } else if (mouse.button === Qt.RightButton) {
                                        console.log("Immediate logout");
                                        sessionMenu.logout();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Timer to hide popouts after mouse leaves
            Timer {
                id: hideTimer
                interval: 300
                onTriggered: {
                    popoutBattery.visible = false;
                    popoutNetwork.visible = false;
                    popoutAudio.visible = false;
                    popoutSystem.visible = false;
                }
            }
        }
    }
    
    // Services
    Time {
        id: Time
    }
    
    Colours {
        id: Colours
    }
    
    Apps {
        id: Apps
    }
    
    NiriWorkspaces {
        id: workspace
    }
    
    Network {
        id: Network
    }
    
    Audio {
        id: Audio
    }
    
    SystemUsage {
        id: SystemUsage
    }
    
    SessionMenu {
        id: sessionMenu
    }
    
    // Popout windows
    PanelWindow {
        id: popoutBattery
        visible: false
        screen: Quickshell.screens[0]
        anchors {
            left: true
        }
        
        WlrLayershell.namespace: "caelestia-popout-battery"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        color: "transparent"
        x: 72
        y: 340
        implicitWidth: 200
        implicitHeight: 100
        
        Rectangle {
            anchors.fill: parent
            color: Colours.palette.m3surfaceContainer
            radius: 12
            border.color: Colours.palette.m3outline
            border.width: 1
            
            Column {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: "Battery"
                    font.pointSize: 12
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }
                
                Text {
                    text: SystemUsage ? 
                          Math.round(SystemUsage.batteryLevel) + "%" +
                          (SystemUsage.isCharging ? " (Charging)" : "") :
                          "No battery info"
                    font.pointSize: 10
                    color: SystemUsage && SystemUsage.batteryLevel <= 20 ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                }
                
                Rectangle {
                    width: 80
                    height: 4
                    radius: 2
                    color: Colours.palette.m3outline
                    
                    Rectangle {
                        width: SystemUsage ? parent.width * (SystemUsage.batteryLevel / 100) : 0
                        height: parent.height
                        radius: parent.radius
                        color: SystemUsage && SystemUsage.batteryLevel <= 20 ? Colours.palette.m3error : Colours.palette.m3primary
                        
                        Behavior on width {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }
                
                Text {
                    visible: SystemUsage && SystemUsage.isCharging
                    text: "⚡ Charging"
                    font.pointSize: 8
                    color: Colours.palette.m3primary
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                parent.visible = false;
            }
        }
    }
    
    PanelWindow {
        id: popoutNetwork
        visible: false
        screen: Quickshell.screens[0]
        anchors {
            left: true
        }
        
        WlrLayershell.namespace: "caelestia-popout-network"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        color: "transparent"
        x: 72
        y: 365
        implicitWidth: 200
        implicitHeight: 80
        
        Rectangle {
            anchors.fill: parent
            color: Colours.palette.m3surfaceContainer
            radius: 12
            border.color: Colours.palette.m3outline
            border.width: 1
            
            Column {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: "Network"
                    font.pointSize: 12
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }
                
                Text {
                    text: Network.connected ? 
                          (Network.ssid || "Connected") : 
                          "Disconnected"
                    font.pointSize: 10
                    color: Network.connected ? Colours.palette.m3primary : Colours.palette.m3error
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                parent.visible = false;
            }
        }
    }
    
    PanelWindow {
        id: popoutAudio
        visible: false
        screen: Quickshell.screens[0]
        anchors {
            left: true
        }
        
        WlrLayershell.namespace: "caelestia-popout-audio"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        color: "transparent"
        x: 72
        y: 390
        implicitWidth: 220
        implicitHeight: 100
        
        Rectangle {
            anchors.fill: parent
            color: Colours.palette.m3surfaceContainer
            radius: 12
            border.color: Colours.palette.m3outline
            border.width: 1
            
            Column {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: "Audio"
                    font.pointSize: 12
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }
                
                Row {
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    MaterialIcon {
                        text: Audio.muted ? "volume_off" : "volume_up"
                        font.pointSize: 16
                        color: Audio.muted ? Colours.palette.m3outline : Colours.palette.m3primary
                    }
                    
                    Text {
                        text: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
                        font.pointSize: 10
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
                
                Rectangle {
                    width: 120
                    height: 4
                    radius: 2
                    color: Colours.palette.m3outline
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        width: Audio.muted ? 0 : parent.width * Audio.volume
                        height: parent.height
                        radius: parent.radius
                        color: Colours.palette.m3primary
                        
                        Behavior on width {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                parent.visible = false;
            }
        }
    }
    
    PanelWindow {
        id: popoutSystem
        visible: false
        screen: Quickshell.screens[0]
        anchors {
            left: true
        }
        
        WlrLayershell.namespace: "caelestia-popout-system"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        color: "transparent"
        x: 72
        y: 415
        implicitWidth: 240
        implicitHeight: 120
        
        Rectangle {
            anchors.fill: parent
            color: Colours.palette.m3surfaceContainer
            radius: 12
            border.color: Colours.palette.m3outline
            border.width: 1
            
            Column {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: "System"
                    font.pointSize: 12
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }
                
                Row {
                    spacing: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "CPU"
                            font.pointSize: 8
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        
                        Text {
                            text: SystemUsage ? Math.round(SystemUsage.cpuPerc * 100) + "%" : "N/A"
                            font.pointSize: 10
                            color: Colours.palette.m3primary
                        }
                    }
                    
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "Memory"
                            font.pointSize: 8
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        
                        Text {
                            text: SystemUsage ? Math.round(SystemUsage.memPerc * 100) + "%" : "N/A"
                            font.pointSize: 10
                            color: Colours.palette.m3secondary
                        }
                    }
                    
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "Storage"
                            font.pointSize: 8
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        
                        Text {
                            text: SystemUsage ? Math.round(SystemUsage.storagePerc * 100) + "%" : "N/A"
                            font.pointSize: 10
                            color: Colours.palette.m3tertiary
                        }
                    }
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                parent.visible = false;
            }
        }
    }
}
