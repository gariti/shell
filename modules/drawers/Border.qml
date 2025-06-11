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
        color: Colours.alpha(BorderConfig.colour, false)
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
            radius: BorderConfig.rounding
        }

        // Square section behind the panel to remove rounding there
        Rectangle {
            x: BorderConfig.thickness
            y: BorderConfig.thickness
            width: root.bar.implicitWidth - BorderConfig.thickness
            height: parent.height - BorderConfig.thickness * 2
            color: "white"
        }
    }

    MultiEffect {
        anchors.fill: parent
        maskEnabled: true
        maskInverted: true
        maskSource: mask
        source: rect
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1
    }
}
