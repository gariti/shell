import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import QtQuick

Item {
    id: root
    required property Item bar

    // Create a simple, visible border frame around the entire screen
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: BorderConfig.thickness
        border.color: BorderConfig.colour
        radius: BorderConfig.rounding
        
        // Make sure this is visible
        opacity: 1.0
    }
}
