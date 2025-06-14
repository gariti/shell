import "../../widgets"
import "../../services-niri"
// import "../../config"  // Temporarily disabled
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

        // Wallpaper {}  // Temporarily disabled
        Rectangle {
            anchors.fill: parent
            color: "#141318"  // Caelestia background color
        }
    }
}
