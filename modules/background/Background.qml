import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "background"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        color: "black"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        Wallpaper {}
        Rectangle {
            anchors.fill: parent
            color: "#000000"  // OLED black background color
            opacity: 0.0  // Keep as fallback but transparent when wallpaper loads
        }
    }
}
