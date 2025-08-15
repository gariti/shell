import QtQuick
import QtQuick.Effects
import Quickshell.Io
import "../../../widgets"
import "../../../config"

Text {
    id: osIcon
    text: "\ue843"  // Static NixOS icon
    
    // Fixed size settings for consistent appearance
    width: 24
    height: 24
    font.pointSize: 28
    font.family: Appearance.font.family.mono  // Use Nerd Font for NixOS symbol
    
    // Set dynamic color that changes with wallpaper
    color: Colours.palette.lavender  // Direct binding to wallust color
    
    // Center the text within the fixed dimensions
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    // Remove any default padding/margins
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    
    // Smooth transitions for hover effects
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    // Make the icon clickable with hover effects
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: launchDesktopMenu()
        cursorShape: Qt.PointingHandCursor
        
        onEntered: {
            osIcon.scale = 1.15
            osIcon.color = Colours.palette.mauve
        }
        
        onExited: {
            osIcon.scale = 1.0
            osIcon.color = Colours.palette.lavender
        }
        
        onPressed: {
            osIcon.scale = 1.05
        }
        
        onReleased: {
            osIcon.scale = mouseArea.containsMouse ? 1.15 : 1.0
        }
    }
    
    // Simple process launcher
    Process {
        id: launchProcess
    }
    
    // Function to launch desktop context menu
    function launchDesktopMenu() {
        console.log("Launching desktop context menu");
        launchProcess.command = ["/etc/nixos/scripts/desktop-right-click-menu.sh"];
        launchProcess.startDetached();
    }
    
    // Color automatically updates via direct binding to Colours.palette.lavender
}