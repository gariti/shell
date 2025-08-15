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
        name: "color-palette-top"

        // Position at top center of screen
        anchors.top: true
        anchors.left: true
        anchors.right: true
        
        implicitWidth: colorContainer.implicitWidth
        implicitHeight: colorContainer.implicitHeight
        
        // Make it an overlay
        WlrLayershell.namespace: "caelestia-color-palette-top"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        
        // Single container with border that contains the dots
        Rectangle {
            id: colorContainer
            anchors.centerIn: parent
            
            width: colorRow.width + 20
            height: colorRow.height + 16
            
            color: Colours.palette.m3surfaceContainer
            radius: 10
            opacity: 0.95
            
            // Border
            border.width: 2
            border.color: Colours.palette.m3outline
            
            // Row of color dots inside the bordered container
            Row {
                id: colorRow
                anchors.centerIn: parent
                spacing: 3
                
                // Primary colors
                ColorDot { dotColor: Colours.palette.m3primary }
                ColorDot { dotColor: Colours.palette.m3secondary }
                ColorDot { dotColor: Colours.palette.m3tertiary }
                
                // Separator
                Rectangle {
                    width: 2
                    height: 10
                    color: Colours.palette.m3outline
                    opacity: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 1
                }
                
                // Dynamic colors
                ColorDot { dotColor: Colours.palette.pink }
                ColorDot { dotColor: Colours.palette.blue }
                ColorDot { dotColor: Colours.palette.green }
                ColorDot { dotColor: Colours.palette.yellow }
                ColorDot { dotColor: Colours.palette.red }
            }
        }
        
        component ColorDot: Rectangle {
            property color dotColor
            
            width: 12
            height: 12
            radius: 6
            color: dotColor
            
            // Border for visibility
            border.width: 0.5
            border.color: Colours.palette.m3outline
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
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
            scale: mouseArea.containsMouse ? 1.3 : 1.0
            
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