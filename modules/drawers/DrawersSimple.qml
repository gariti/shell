pragma ComponentBehavior: Bound

import "../../widgets"
import "../../services-niri"
import "../../config"
import "../bar"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Simplified Drawers module without complex interactions
Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            mask: Region {
                x: 100  // Simple fixed bar width
                y: 15   // BorderConfig.thickness equivalent
                width: win.width - 100 - 15
                height: win.height - 30
                intersection: Intersection.Xor
            }

            anchors.left: true
            anchors.right: true
            anchors.top: true
            anchors.bottom: true

            color: "transparent"

            // Simple background without complex effects
            Rectangle {
                anchors.fill: parent
                color: "#141318"
                opacity: 0.8
                visible: false  // Start hidden
            }

            // Basic Bar component
            Bar {
                id: bar

                screen: scope.modelData
                popouts: QtObject {
                    property bool hasCurrent: false
                    property var currentPopout: null
                }
            }
        }
    }
}
