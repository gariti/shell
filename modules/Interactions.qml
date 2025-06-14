import "../services-niri"
import "../modules/bar/popouts" as BarPopouts
import Quickshell
import QtQuick

MouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property Item bar

    property point dragStart

    function checkPopout(y: real): void {
        const spacing = 8; // Appearance.spacing.small equivalent
        
        // Status icons area - based on your shell layout
        const statusStart = 300; // Approximate start of status area
        const statusHeight = 120; // Height of status rectangle
        const statusEnd = statusStart + statusHeight;
        
        // Individual status icon areas within the status rectangle
        const iconSpacing = 8;
        const iconHeight = 16;
        
        // Volume icon area (first in row)
        const volumeY = statusStart + 50; // Approximate position
        const volumeStart = volumeY - iconSpacing / 2;
        const volumeEnd = volumeY + iconHeight + iconSpacing / 2;
        
        // Network icon area (second in row) 
        const networkY = volumeY + iconHeight + iconSpacing;
        const networkStart = networkY - iconSpacing / 2;
        const networkEnd = networkY + iconHeight + iconSpacing / 2;
        
        // Battery icon area (third in row)
        const batteryY = networkY + iconHeight + iconSpacing;
        const batteryStart = batteryY - iconSpacing / 2;
        const batteryEnd = batteryY + iconHeight + iconSpacing / 2;

        if (y >= volumeStart && y <= volumeEnd) {
            popouts.currentName = "volume";
            popouts.currentCenter = Qt.binding(() => volumeY + iconHeight / 2);
            popouts.hasCurrent = true;
        } else if (y >= networkStart && y <= networkEnd) {
            popouts.currentName = "network";
            popouts.currentCenter = Qt.binding(() => networkY + iconHeight / 2);
            popouts.hasCurrent = true;
        } else if (y >= batteryStart && y <= batteryEnd) {
            popouts.currentName = "battery";
            popouts.currentCenter = Qt.binding(() => batteryY + iconHeight / 2);
            popouts.hasCurrent = true;
        } else {
            popouts.hasCurrent = false;
        }
    }

    anchors.fill: parent
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            popouts.hasCurrent = false;
        }
    }

    onPositionChanged: ({x, y}) => {
        // Show popouts on hover
        const popout = popouts;
        if (x < bar.implicitWidth + popout.width) {
            if (x < bar.implicitWidth)
                // Handle like part of bar
                bar.checkPopout(y);
            else
                // Keep on hover within popout area
                popouts.hasCurrent = true;
        } else {
            popouts.hasCurrent = false;
        }
    }
}
