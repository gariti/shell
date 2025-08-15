import QtQuick
import "../../../widgets"
import "../../../services-niri"
import "../../../config"

Column {
    id: root
    
    spacing: 0
    anchors.left: parent.left
    anchors.right: parent.right
    
    Component.onCompleted: {
        console.log("ColorPalette component loaded and visible")
        console.log("ColorPalette size:", width, "x", height)
    }
    
    // All 16 terminal colors from wallust theme
    ColorDot { dotColor: Colours.palette.color0 }
    ColorDot { dotColor: Colours.palette.color1 }
    ColorDot { dotColor: Colours.palette.color2 }
    ColorDot { dotColor: Colours.palette.color3 }
    ColorDot { dotColor: Colours.palette.color4 }
    ColorDot { dotColor: Colours.palette.color5 }
    ColorDot { dotColor: Colours.palette.color6 }
    ColorDot { dotColor: Colours.palette.color7 }
    ColorDot { dotColor: Colours.palette.color8 }
    ColorDot { dotColor: Colours.palette.color9 }
    ColorDot { dotColor: Colours.palette.color10 }
    ColorDot { dotColor: Colours.palette.color11 }
    ColorDot { dotColor: Colours.palette.color12 }
    ColorDot { dotColor: Colours.palette.color13 }
    ColorDot { dotColor: Colours.palette.color14 }
    ColorDot { dotColor: Colours.palette.color15 }
    
    component ColorDot: Rectangle {
        property color dotColor
        
        width: 12  // Make it square so radius can make it perfectly round
        height: 12
        radius: 6  // Half of width/height for perfect circle
        color: dotColor
        anchors.horizontalCenter: parent.horizontalCenter  // Center the dots
        
        
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                // Copy color to clipboard
                const colorHex = parent.dotColor.toString()
                const process = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["wl-copy", "${colorHex}"]
                    }
                `, parent)
                process.startDetached()
            }
        }
        
        // Hover effect
        scale: mouseArea.containsMouse ? 1.2 : 1.0
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}