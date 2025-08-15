import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens

    StyledWindow {
        id: root

        required property ShellScreen modelData
        screen: modelData
        name: "color-palette"

        // Position on right edge of screen
        anchors.right: true
        anchors.top: true
        anchors.bottom: true
        
        implicitWidth: 30
        
        // Make it an overlay
        WlrLayershell.namespace: "caelestia-color-palette"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
    
    Column {
        id: paletteColumn
        anchors.centerIn: parent
        spacing: 2
        
        // Primary theme colors (most important)
        ColorDot { color: Colours.palette.m3primary; name: "Primary" }
        ColorDot { color: Colours.palette.m3secondary; name: "Secondary" }
        ColorDot { color: Colours.palette.m3tertiary; name: "Tertiary" }
        
        // Separator
        Rectangle {
            width: 12
            height: 1
            color: Colours.palette.m3outline
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Dynamic wallpaper colors (selection of most vibrant)
        ColorDot { color: Colours.palette.pink; name: "Pink" }
        ColorDot { color: Colours.palette.mauve; name: "Mauve" }
        ColorDot { color: Colours.palette.blue; name: "Blue" }
        ColorDot { color: Colours.palette.green; name: "Green" }
        ColorDot { color: Colours.palette.yellow; name: "Yellow" }
        ColorDot { color: Colours.palette.red; name: "Red" }
        ColorDot { color: Colours.palette.teal; name: "Teal" }
        ColorDot { color: Colours.palette.lavender; name: "Lavender" }
        
        // Separator
        Rectangle {
            width: 12
            height: 1
            color: Colours.palette.m3outline
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Surface colors
        ColorDot { color: Colours.palette.m3surface; name: "Surface" }
        ColorDot { color: Colours.palette.m3surfaceVariant; name: "Surface Variant" }
    }
    
    component ColorDot: Rectangle {
        property color color
        property string name
        
        width: 18
        height: 18
        radius: 9
        color: parent.color
        
        // Subtle border for visibility
        border.width: 1
        border.color: Colours.palette.m3outline
        
        // Tooltip on hover
        Rectangle {
            id: tooltip
            visible: false
            color: Colours.palette.m3inverseSurface
            radius: 4
            width: tooltipText.width + 12
            height: tooltipText.height + 8
            anchors.right: parent.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            z: 100
            
            StyledText {
                id: tooltipText
                anchors.centerIn: parent
                text: `${name}\n${parent.parent.color.toString()}`
                font.pixelSize: 10
                color: Colours.palette.m3inverseOnSurface
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onEntered: tooltip.visible = true
            onExited: tooltip.visible = false
            
            onClicked: {
                // Copy color to clipboard
                const colorHex = parent.color.toString()
                const process = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["wl-copy", "${colorHex}"]
                    }
                `, parent)
                process.startDetached()
            }
        }
    }
    
    // Auto-hide/show on hover
    property bool isHovered: false
    
    MouseArea {
        anchors.fill: parent
        anchors.margins: -5  // Expand hover area slightly
        hoverEnabled: true
        
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
    }
    
    // Control visibility through the background rectangle
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Colours.palette.m3surfaceContainer
        radius: 6
        opacity: root.isHovered ? 0.95 : 0.7
        
        // Subtle border
        border.width: 1
        border.color: Colours.palette.m3outline
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
    }
}