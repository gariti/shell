import "../../widgets"
import "../../services-niri"
import "../../config"
import QtQuick

Item {
    id: root

    required property Brightness.Monitor monitor
    property bool mouseInContent: false  // Track if mouse is in the OSD content

    // MouseArea to keep OSD open when hovering over child elements
    MouseArea {
        anchors.fill: parent
        anchors.margins: -20 // Extend beyond the content area
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Don't handle any clicks
        
        // Keep the OSD open while hovering anywhere in this area
        onContainsMouseChanged: {
            root.mouseInContent = containsMouse;
            console.log("OSD content mouse changed:", containsMouse);
        }
    }

    Column {
        id: column
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        
        padding: Appearance.padding.large
        spacing: Appearance.spacing.normal

        VerticalSlider {
            icon: {
                if (Audio.muted)
                    return "no_sound";
                if (value >= 0.5)
                    return "volume_up";
                if (value > 0)
                    return "volume_down";
                return "volume_mute";
            }
            value: Audio.volume
            onMoved: Audio.setVolume(value)

            implicitWidth: OsdConfig.sizes.sliderWidth
            implicitHeight: OsdConfig.sizes.sliderHeight
        }

        VerticalSlider {
            icon: `brightness_${(Math.round(value * 6) + 1)}`
            value: root.monitor?.brightness ?? 0
            onMoved: root.monitor?.setBrightness(value)

            implicitWidth: OsdConfig.sizes.sliderWidth
            implicitHeight: OsdConfig.sizes.sliderHeight
        }
    }

    // Set the size based on the column content
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight
}
