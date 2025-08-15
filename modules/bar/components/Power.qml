import "../../../widgets"
import "../../../services-niri"
import "../../../config"
import Quickshell
import QtQuick

MaterialIcon {
    text: "power_settings_new"
    property color dynamicColor: getPowerColor()
    color: dynamicColor
    font.bold: true
    font.pointSize: Appearance.font.size.normal
    
    // Function to get power button color based on session state
    function getPowerColor() {
        // Check if session menu is visible and use different colors
        const v = Visibilities.screens[QsWindow.window.screen];
        if (v && v.session) {
            return Colours.palette.m3error;     // Error color when session menu is open
        }
        
        // Use tertiary color (yellow/gold tones) for power button
        // This gives it a distinct color from other components
        return Colours.palette.m3tertiary;
    }

    StateLayer {
        anchors.fill: undefined
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1

        implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
        implicitHeight: implicitWidth

        radius: Appearance.rounding.full

        function onClicked(): void {
            const v = Visibilities.screens[QsWindow.window.screen];
            v.session = !v.session;
        }
    }
    
    // Update color when colors are loaded (theme refresh)
    Connections {
        target: Colours
        function onColorsLoaded() {
            dynamicColor = getPowerColor();
        }
    }
}
