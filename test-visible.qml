// Test file for maximum visibility
import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            left: true
            right: true
            top: true
        }
        
        height: 50
        
        WlrLayershell.namespace: "caelestia-test-visible"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        
        color: "#FF0000"
        
        Rectangle {
            anchors.fill: parent
            color: "#FF0000"
            border.color: "#FFFFFF"
            border.width: 2
            
            Text {
                anchors.centerIn: parent
                text: "CAELESTIA SHELL TEST - VISIBLE!"
                color: "#FFFFFF"
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}
