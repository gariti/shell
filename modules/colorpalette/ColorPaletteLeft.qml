import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    StyledWindow {
        id: root

        required property ShellScreen modelData
        screen: modelData
        name: "color-palette-left"

        // Position at left side of screen
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        
        implicitWidth: colorContainer.implicitWidth
        implicitHeight: colorContainer.implicitHeight
        
        // Make it an overlay
        WlrLayershell.namespace: "caelestia-color-palette-left"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        
        // Vertical column of color rectangles
        Column {
            id: colorContainer
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            
            spacing: 0
            
            Component.onCompleted: {
                console.log("ColorPaletteLeft component loaded and visible")
                console.log("ColorPaletteLeft size:", width, "x", height)
            }
            
            // Primary colors (most important ones)
            ColorDot { dotColor: Colours.palette.m3primary }
            ColorDot { dotColor: Colours.palette.m3secondary }
            ColorDot { dotColor: Colours.palette.m3tertiary }
            
            // Dynamic wallpaper colors (selection)
            ColorDot { dotColor: Colours.palette.pink }
            ColorDot { dotColor: Colours.palette.blue }
            ColorDot { dotColor: Colours.palette.green }
            ColorDot { dotColor: Colours.palette.yellow }
            ColorDot { dotColor: Colours.palette.red }
        }
        
        component ColorDot: Rectangle {
            property color dotColor
            
            width: 8
            height: 4
            radius: 1
            color: dotColor
            
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
}