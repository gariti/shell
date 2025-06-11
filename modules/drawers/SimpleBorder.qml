import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Simple persistent border implementation
StyledWindow {
    id: borderWindow
    
    required property ShellScreen screen
    required property Item bar
    
    // Window configuration
    WlrLayershell.namespace: "caelestia-simple-border"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    color: "transparent"
    
    // Anchor to screen edges
    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true
    
    Component.onCompleted: {
        console.log("Simple border window created for screen:", screen.name);
    }
    
    // Top border
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: BorderConfig.thickness
        color: BorderConfig.colour
        z: 1000
    }
    
    // Bottom border
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: BorderConfig.thickness
        color: BorderConfig.colour
        z: 1000
    }
    
    // Left border (excluding bar area)
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: BorderConfig.thickness
        color: BorderConfig.colour
        z: 1000
    }
    
    // Right border
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: BorderConfig.thickness
        color: BorderConfig.colour
        z: 1000
    }
}
