import "services-niri"
import "widgets"
import "config"
import "modules"
import "modules/bar/popouts" as BarPopouts
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
            
            // Left sidebar shell - define first so other components can reference it
            PanelWindow {
                id: mainBar
                screen: modelData
                anchors.left: true
                anchors.top: true
                anchors.bottom: true
                
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
                    const dateHeight = 16; // Date text  
                    const spacingAfterDate = 8;
                    const iconsRowStart = statusInnerStart + timeHeight + 4 + dateHeight + spacingAfterDate;
                    
                    // Individual icon areas (they're in a Row with spacing: 4)
                    const iconSize = 16;
                    const iconSpacing = 4;
                    
                    // Volume icon (first in row)
                    const volumeY = iconsRowStart;
                    const volumeStart = volumeY - spacing / 2;
                    const volumeEnd = volumeY + iconSize + spacing / 2;
                    
                    // Network icon (second in row, offset by first icon + spacing)
                    const networkY = iconsRowStart;
                    const networkStart = volumeEnd;
                    const networkEnd = networkStart + iconSize + spacing;
                    
                    // Battery icon (third in row)  
                    const batteryY = iconsRowStart;
                    const batteryStart = networkEnd;
                    const batteryEnd = batteryStart + iconSize + spacing;

                    if (y >= volumeStart && y <= volumeEnd) {
                        popouts.currentName = "volume";
                        popouts.currentCenter = Qt.binding(() => volumeY + iconSize / 2);
                        popouts.hasCurrent = true;
                    } else if (y >= networkStart && y <= networkEnd) {
                        popouts.currentName = "network";
                        popouts.currentCenter = Qt.binding(() => networkY + iconSize / 2);
                        popouts.hasCurrent = true;
                    } else if (y >= batteryStart && y <= batteryEnd) {
                        popouts.currentName = "battery";
                        popouts.currentCenter = Qt.binding(() => batteryY + iconSize / 2);  
                        popouts.hasCurrent = true;
                    } else {
                        popouts.hasCurrent = false;
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "#1C1B1F" // Improved surface color
                    radius: 16
                    border.color: "#48454E"
                    border.width: 1
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 16
                        
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
                                    color: "#C9C5D0" // Force explicit text color
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
                            color: "#201F25" // Force explicit surface container color
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
                                    color: "#E5E1E9" // Force explicit text color
                                }
                                
                                // Date
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Time.date ? Time.date.toLocaleDateString(Qt.locale(), "MMM dd") : "Jan 01"
                                    font.pointSize: 8
                                    color: "#C9C5D0" // Force explicit text color
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
                                        color: Audio && Audio.muted ? "#EA8DC1" : "#C8BFFF"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: Audio && Audio.muted ? "󰖁" : "󰕾"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: Audio && Audio.muted ? "#690005" : "#30285F"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (Audio) Audio.muted = !Audio.muted
                                            }
                                        }
                                    }
                                    
                                    // Network indicator
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: Network && Network.connected ? "#C8BFFF" : "#48454E"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: Network && Network.connected ? "󰤨" : "󰤭"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: Network && Network.connected ? "#30285F" : "#C9C5D0"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }
                                    
                                    // Battery indicator (enhanced with level and charging status)
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: SystemUsage && SystemUsage.isCharging ? "#473F77" :
                                               (SystemUsage && SystemUsage.batteryLevel <= 20 ? "#654C4C" : "#C9C3DC")
                                        visible: SystemUsage && SystemUsage.hasBattery
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: SystemUsage && SystemUsage.isCharging ? "󰂄" : "󰁹"
                                            font.pointSize: 8
                                            font.family: "Nerd Font"
                                            color: SystemUsage && SystemUsage.isCharging ? "#E5DEFF" :
                                                   (SystemUsage && SystemUsage.batteryLevel <= 20 ? "#F2B8B5" : "#312E41")
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
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
                                   "#473F77" :
                                   (SystemUsage && SystemUsage.batteryLevel <= 20 ? 
                                    "#654C4C" :
                                    "#3E3544")
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
                                           "#E5DEFF" :
                                           (SystemUsage && SystemUsage.batteryLevel <= 20 ?
                                            "#F2B8B5" :
                                            "#E8DEF8")
                                }
                                
                                Text {
                                    text: SystemUsage ? Math.round(SystemUsage.batteryLevel).toString() + "%" : "0%"
                                    font.pointSize: 10
                                    color: SystemUsage && SystemUsage.isCharging ?
                                           "#E5DEFF" :
                                           (SystemUsage && SystemUsage.batteryLevel <= 20 ?
                                            "#F2B8B5" :
                                            "#E8DEF8")
                                }
                            }
                        }
                        
                        // Power button
                        Rectangle {
                            width: parent.width - 16
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#93000A" // Force explicit error container color
                            radius: 20
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                font.pointSize: 16
                                font.family: "Nerd Font"
                                color: "#FFDAD6" // Force explicit on-error-container color
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
            
            // Border exclusion zones for rounded corners
            Exclusions {
                screen: modelData
                bar: mainBar
            }
            
            // Border using StyledWindow like original Caelestia
            StyledWindow {
                id: borderWindow
                screen: modelData
                name: "border"
                WlrLayershell.namespace: "caelestia-border"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                
                anchors.left: true
                anchors.right: true
                anchors.top: true
                anchors.bottom: true
                
                color: "transparent"
                
                Component.onCompleted: {
                    console.log("Border window created successfully!");
                }
                
                Border {
                    width: borderWindow.width
                    height: borderWindow.height
                    bar: mainBar
                }
            }

            // Popouts panel window for hover interactions  
            PanelWindow {
                id: popoutsWindow
                screen: modelData
                anchors.left: true
                anchors.top: true
                anchors.bottom: true
                
                WlrLayershell.namespace: "caelestia-popouts"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                
                color: "transparent"
                implicitWidth: 200 // Bar width + popout space
                
                // Popout background styling
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 136
                        color: "transparent"
                        
                        // Import the proper popouts
                        BarPopouts.Wrapper {
                            id: popouts
                            screen: modelData
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 112
                            
                            // Visual container for the popouts
                            Rectangle {
                                visible: popouts.hasCurrent
                                anchors.centerIn: parent
                                width: popouts.implicitWidth + 24
                                height: popouts.implicitHeight + 24
                                color: "#201F25"
                                radius: 12
                                border.color: "#48454E"
                                border.width: 1
                                
                                // Smooth animations matching original Caelestia
                                opacity: popouts.hasCurrent ? 1 : 0
                                scale: popouts.hasCurrent ? 1 : 0.8
                                
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: popouts.hasCurrent ? 300 : 200
                                        easing.type: Easing.BezierSpline
                                        easing.bezierCurve: popouts.hasCurrent ? [0.05, 0.7, 0.1, 1] : [0.4, 0, 1, 1]
                                    }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: popouts.hasCurrent ? 300 : 200
                                        easing.type: Easing.BezierSpline
                                        easing.bezierCurve: popouts.hasCurrent ? [0.34, 1.56, 0.64, 1] : [0.4, 0, 1, 1]
                                    }
                                }
                            }
                            
                            // Position animation
                            y: Math.max(12, Math.min(parent.height - height - 12, popouts.currentCenter - height / 2))
                            
                            Behavior on y {
                                enabled: popouts.hasCurrent
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                                }
                            }
                        }
                    }
                }
                
                // Proper interaction system like original Caelestia
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    onPositionChanged: ({x, y}) => {
                        // Show popouts on hover within bar area
                        if (x < 64) { // Within bar width
                            mainBar.checkPopout(y)
                        } else if (x < 200 && popouts.hasCurrent) {
                            // Keep popout active when hovering over popout area
                            // popouts.hasCurrent remains true
                        } else {
                            popouts.hasCurrent = false
                        }
                    }
                    
                    onExited: {
                        popouts.hasCurrent = false
                    }
                }
            }

            // Right-side OSD Panel
            PanelWindow {
                id: osdWindow
                screen: modelData
                anchors.right: true
                anchors.top: true
                anchors.bottom: true
                
                WlrLayershell.namespace: "caelestia-osd"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusionMode: ExclusionMode.Normal
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                
                color: "transparent"
                implicitWidth: 80
                
                // Simple OSD placeholder since OSDPanel doesn't exist
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 8
                    width: 64
                    height: 200
                    color: "transparent"
                    visible: false // Hidden for now until proper OSD is implemented
                }
                
                // Mouse area for hover detection on the right edge
                MouseArea {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4 // Thin hover zone
                    hoverEnabled: true
                    
                    onEntered: {
                        // osdPanel.show() - disabled until OSD is implemented
                    }
                }
            }
        }
    }
    
    // Enhanced Popout Components with sophisticated animations
    Component {
        id: volumePopout
        
        Column {
            spacing: 8
            padding: 12
            
            // Animate entire column
            opacity: 0
            scale: 0.9
            
            Component.onCompleted: {
                opacity = 1
                scale = 1
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                }
            }
            
            Text {
                text: "Volume"
                font.pointSize: 12
                font.bold: true
                color: "#E5E1E9"
                
                // Subtle slide-in animation
                transform: Translate {
                    id: titleTransform
                    x: -10
                    
                    Behavior on x {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
                
                Component.onCompleted: titleTransform.x = 0
            }
            
            Row {
                spacing: 8
                
                Text {
                    text: Audio && Audio.muted ? "󰖁" : "󰕾"
                    font.pointSize: 16
                    font.family: "Nerd Font"
                    color: "#C8BFFF"
                    
                    // Icon bounce animation on mute toggle
                    transform: Scale {
                        id: iconScale
                        origin.x: width / 2
                        origin.y: height / 2
                        xScale: 1
                        yScale: 1
                    }
                    
                    onTextChanged: {
                        // Bounce effect when text changes
                        iconScale.xScale = 1.2
                        iconScale.yScale = 1.2
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
                
                Text {
                    text: Audio ? Math.round(Audio.volume * 100) + "%" : "0%"
                    font.pointSize: 10
                    color: "#C9C5D0"
                    
                    // Number animation for volume changes
                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 1.1
                                duration: 100
                            }
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 1.0
                                duration: 100
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: 80
                height: 4
                radius: 2
                color: "#48454E"
                
                // Animated progress bar
                Rectangle {
                    id: volumeBar
                    width: 0
                    height: parent.height
                    radius: parent.radius
                    color: "#C8BFFF"
                    
                    Component.onCompleted: {
                        width = Audio ? parent.width * Audio.volume : 0
                    }
                    
                    // Smooth volume bar animation
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.2, 0, 0, 1]
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
                
                // Shimmer effect on hover
                Rectangle {
                    anchors.fill: volumeBar
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: "#FFFFFF20" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    transform: Translate {
                        id: shimmer
                        x: -parent.width
                        
                        SequentialAnimation on x {
                            running: Audio && Audio.volume > 0
                            loops: Animation.Infinite
                            PauseAnimation { duration: 2000 }
                            NumberAnimation {
                                from: -parent.width
                                to: parent.width
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: networkPopout
        
        Column {
            spacing: 8
            padding: 12
            
            // Animate entire column with enhanced entrance
            opacity: 0
            scale: 0.9
            
            Component.onCompleted: {
                opacity = 1
                scale = 1
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                }
            }
            
            Text {
                text: "Network"
                font.pointSize: 12
                font.bold: true
                color: "#E5E1E9"
                
                // Slide-in animation for title
                transform: Translate {
                    id: networkTitleTransform
                    x: -10
                    
                    Behavior on x {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
                
                Component.onCompleted: networkTitleTransform.x = 0
            }
            
            Row {
                spacing: 8
                
                Text {
                    text: Network && Network.connected ? "󰤨" : "󰤭"
                    font.pointSize: 16
                    font.family: "Nerd Font"
                    color: Network && Network.connected ? "#C8BFFF" : "#EA8DC1"
                    
                    // Icon animation on connection state change
                    transform: Scale {
                        id: networkIconScale
                        origin.x: width / 2
                        origin.y: height / 2
                        xScale: 1
                        yScale: 1
                    }
                    
                    onTextChanged: {
                        // Pulse effect when connection state changes
                        networkIconScale.xScale = 1.3
                        networkIconScale.yScale = 1.3
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.4, 0, 0.2, 1]
                        }
                    }
                    
                    // Scale animation behavior
                    Behavior on transform {
                        PropertyAnimation {
                            duration: 200
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                        }
                    }
                    
                    // Reset scale after animation
                    Timer {
                        interval: 200
                        running: networkIconScale.xScale > 1
                        onTriggered: {
                            networkIconScale.xScale = 1
                            networkIconScale.yScale = 1
                        }
                    }
                }
                
                Text {
                    text: Network && Network.connected ? "Connected" : "Disconnected"
                    font.pointSize: 10
                    color: "#C9C5D0"
                    
                    // Subtle fade animation on text change
                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation {
                                target: parent
                                property: "opacity"
                                to: 0.7
                                duration: 100
                            }
                            NumberAnimation {
                                target: parent
                                property: "opacity"
                                to: 1.0
                                duration: 200
                            }
                        }
                    }
                }
            }
            
            Text {
                text: Network && Network.connected ? (Network.ssid || "Wired Connection") : ""
                font.pointSize: 9
                color: "#C9C5D0"
                visible: !!(Network && Network.connected)
                
                // Fade in/out animation for SSID
                Behavior on visible {
                    NumberAnimation {
                        target: parent
                        property: "opacity"
                        duration: 300
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.4, 0, 0.2, 1]
                    }
                }
                
                // Slide up animation when SSID appears
                transform: Translate {
                    id: ssidTransform
                    y: visible ? 0 : 10
                    
                    Behavior on y {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
            }
            
            // Signal strength indicator (if available)
            Rectangle {
                width: 80
                height: 4
                radius: 2
                color: "#48454E"
                visible: Network && Network.connected && (Network.signalStrength !== undefined && Network.signalStrength !== null)
                
                Rectangle {
                    width: (Network && Network.connected && Network.signalStrength !== undefined) ? 
                           parent.width * (Network.signalStrength / 100) : 0
                    height: parent.height
                    radius: parent.radius
                    color: {
                        if (!Network || !Network.connected || Network.signalStrength === undefined) return "#48454E"
                        if (Network.signalStrength >= 75) return "#C8BFFF"
                        if (Network.signalStrength >= 50) return "#C8BFFF"
                        if (Network.signalStrength >= 25) return "#F2B8B5"
                        return "#EA8DC1"
                    }
                    
                    // Animated signal strength bar
                    Behavior on width {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.4, 0, 0.2, 1]
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: batteryPopout
        
        Column {
            spacing: 8
            padding: 12
            visible: SystemUsage && SystemUsage.hasBattery
            
            // Animate entire column with enhanced entrance
            opacity: 0
            scale: 0.9
            
            Component.onCompleted: {
                opacity = 1
                scale = 1
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                }
            }
            
            Text {
                text: "Battery"
                font.pointSize: 12
                font.bold: true
                color: "#E5E1E9"
                
                // Slide-in animation for title
                transform: Translate {
                    id: batteryTitleTransform
                    x: -10
                    
                    Behavior on x {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
                
                Component.onCompleted: batteryTitleTransform.x = 0
            }
            
            Row {
                spacing: 8
                
                Text {
                    text: {
                        if (SystemUsage && SystemUsage.isCharging) return "󰂄"
                        if (SystemUsage && SystemUsage.batteryLevel >= 90) return "󰁹"
                        if (SystemUsage && SystemUsage.batteryLevel >= 60) return "󰂀"
                        if (SystemUsage && SystemUsage.batteryLevel >= 40) return "󰁿"
                        if (SystemUsage && SystemUsage.batteryLevel >= 20) return "󰁼"
                        return "󰁺"
                    }
                    font.pointSize: 16
                    font.family: "Nerd Font"
                    color: SystemUsage && SystemUsage.isCharging ? "#C8BFFF" : 
                           (SystemUsage && SystemUsage.batteryLevel <= 20 ? "#EA8DC1" : "#C8BFFF")
                    
                    // Icon animation on battery level or charging state change
                    transform: Scale {
                        id: batteryIconScale
                        origin.x: width / 2
                        origin.y: height / 2
                        xScale: 1
                        yScale: 1
                    }
                    
                    onTextChanged: {
                        // Gentle pulse effect when battery icon changes
                        batteryIconScale.xScale = 1.2
                        batteryIconScale.yScale = 1.2
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 500
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.4, 0, 0.2, 1]
                        }
                    }
                    
                    // Scale animation behavior
                    Behavior on transform {
                        PropertyAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                        }
                    }
                    
                    // Reset scale after animation
                    Timer {
                        interval: 300
                        running: batteryIconScale.xScale > 1
                        onTriggered: {
                            batteryIconScale.xScale = 1
                            batteryIconScale.yScale = 1
                        }
                    }
                    
                    // Blinking animation for low battery
                    SequentialAnimation on opacity {
                        running: SystemUsage && SystemUsage.batteryLevel <= 10 && !SystemUsage.isCharging
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            to: 0.3
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                Text {
                    text: SystemUsage ? Math.round(SystemUsage.batteryLevel) + "%" : "0%"
                    font.pointSize: 10
                    color: "#C9C5D0"
                    
                    // Number animation for battery level changes
                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 1.1
                                duration: 150
                            }
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 1.0
                                duration: 150
                            }
                        }
                    }
                }
            }
            
            Text {
                text: SystemUsage && SystemUsage.isCharging ? "Charging" : "On Battery"
                font.pointSize: 9
                color: "#C9C5D0"
                
                // Subtle fade animation on charging state change
                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation {
                            target: parent
                            property: "opacity"
                            to: 0.6
                            duration: 200
                        }
                        NumberAnimation {
                            target: parent
                            property: "opacity"
                            to: 1.0
                            duration: 300
                        }
                    }
                }
            }
            
            Rectangle {
                width: 80
                height: 4
                radius: 2
                color: "#48454E"
                
                // Animated battery level bar
                Rectangle {
                    id: batteryBar
                    width: SystemUsage ? parent.width * (SystemUsage.batteryLevel / 100) : 0
                    height: parent.height
                    radius: parent.radius
                    color: SystemUsage && SystemUsage.batteryLevel <= 20 ? "#EA8DC1" : "#C8BFFF"
                    
                    // Smooth battery bar animation
                    Behavior on width {
                        NumberAnimation {
                            duration: 600
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.4, 0, 0.2, 1]
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 400
                        }
                    }
                }
                
                // Charging animation shimmer effect
                Rectangle {
                    anchors.fill: batteryBar
                    radius: parent.radius
                    visible: SystemUsage && SystemUsage.isCharging
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: "#FFFFFF30" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    transform: Translate {
                        id: chargingShimmer
                        x: -parent.width
                        
                        SequentialAnimation on x {
                            running: SystemUsage && SystemUsage.isCharging
                            loops: Animation.Infinite
                            PauseAnimation { duration: 1500 }
                            NumberAnimation {
                                from: -parent.width
                                to: parent.width
                                duration: 1200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
                
                // Low battery warning pulse
                Rectangle {
                    anchors.fill: batteryBar
                    radius: parent.radius
                    color: "#FF000040"
                    visible: SystemUsage && SystemUsage.batteryLevel <= 15 && !SystemUsage.isCharging
                    
                    SequentialAnimation on opacity {
                        running: visible
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            to: 0.0
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 0.8
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
