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
        
        height: 48
        color: "#141318"
        
        Text {
            anchors.centerIn: parent
            text: "Caelestia Shell for Niri - " + Qt.formatTime(new Date(), "hh:mm")
            color: "#E6E0E9"
            font.family: "IBM Plex Sans"
            font.pixelSize: 16
        }
        
        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: parent.update()
        }
    }
}
