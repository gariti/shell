import QtQuick
import Quickshell.Io
import "../widgets"
import "../services-niri"
import "../config"

// Simple OSD Panel for Volume and Brightness Controls
Item {
    id: osd
    
    property bool isVisible: false
    
    // Auto-hide after inactivity
    function show() {
        isVisible = true
        hideTimer.restart()
    }
    
    function hide() {
        isVisible = false
    }
    
    // Position on right side of screen
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 20
    
    width: isVisible ? 80 : 0
    height: 200
    
    opacity: isVisible ? 1 : 0
    
    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#2A282F" // Force explicit dark background
        radius: 20
        border.color: "#48454E"
        border.width: 1
        
        Row {
            anchors.centerIn: parent
            spacing: 20
            
            // Volume Slider
            Column {
                spacing: 8
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Audio && Audio.muted ? "󰖁" : "󰕾"
                    font.family: "Nerd Font"
                    font.pointSize: 16
                    color: "#E5E1E9"
                }
                
                VerticalSlider {
                    id: volumeSlider
                    width: 20
                    height: 120
                    
                    value: Audio ? Audio.volume : 0.5
                    icon: Audio && Audio.muted ? "󰖁" : "󰕾"
                    
                    onMoved: {
                        if (Audio) {
                            Audio.setVolume(value)
                            osd.show()
                        }
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round((Audio ? Audio.volume : 0.5) * 100) + "%"
                    font.pointSize: 10
                    color: "#C9C5D0"
                }
            }
            
            // Brightness Slider  
            Column {
                spacing: 8
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰃞"
                    font.family: "Nerd Font"
                    font.pointSize: 16
                    color: "#E5E1E9"
                }
                
                VerticalSlider {
                    id: brightnessSlider
                    width: 20
                    height: 120
                    
                    value: SystemUsage ? (SystemUsage.brightness || 0.8) : 0.8
                    icon: "󰃞"
                    
                    onMoved: {
                        // Use brightness control script if available
                        brightnessProcess.command = ["brightness-control.sh", "set", Math.round(value * 100).toString()]
                        brightnessProcess.startDetached()
                        osd.show()
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(brightnessSlider.value * 100) + "%"
                    font.pointSize: 10
                    color: "#C9C5D0"
                }
            }
        }
    }
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: osd.hide()
    }
    
    // Brightness control process
    Process {
        id: brightnessProcess
    }
    
    // Mouse area to keep OSD visible while hovering
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hideTimer.stop()
        onExited: hideTimer.restart()
    }
    
    // Keyboard shortcuts connections
    Connections {
        target: Audio
        function onVolumeChanged() { osd.show() }
        function onMutedChanged() { osd.show() }
    }
}
