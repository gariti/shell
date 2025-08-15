import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property Item bar

    anchors.fill: parent

    StyledRect {
        id: rect

        anchors.fill: parent
        color: Colours.palette.m3surfaceContainer
        opacity: 1.0  // Keep source opaque
        visible: false
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        // Main content area with rounded corners, excluding bar area
        Rectangle {
            anchors.fill: parent
            anchors.margins: BorderConfig.thickness
            anchors.leftMargin: root.bar.implicitWidth
            radius: BorderConfig.rounding  // Use full rounding to match other elements
        }

        // Square section behind the panel to remove ALL border around panel
        Rectangle {
            x: 0
            y: 0
            width: root.bar.implicitWidth
            height: parent.height
            color: "white"
        }
    }

    MultiEffect {
        anchors.fill: parent
        maskEnabled: true
        maskInverted: true
        maskSource: mask
        source: rect
        maskThresholdMin: 0.6  // Slightly higher threshold to reduce edge artifacts
        maskSpreadAtMin: 0.8   // Tighter spread
        
        // Apply exact same transparency calculation as panel
        opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
        
        // Ensure no color processing that might affect transparency
        brightness: 0.0
        contrast: 0.0
        saturation: 0.0
        colorization: 0.0
        
        // Add slight antialiasing to smooth edges
        autoPaddingEnabled: true
    }
}
