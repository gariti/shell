import "../../services-niri"
import "../../config"
import "../bar/popouts" as BarPopouts
import "../osd" as Osd
import Quickshell
import QtQuick

MouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property PersistentProperties visibilities
    required property Panels panels
    required property Item bar

    property bool osdHovered
    property point dragStart

    Component.onCompleted: {
        console.log("🚀 INTERACTIONS.QML LOADED - this should appear in logs");
    }

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = BorderConfig.thickness + panel.y;
        return y >= panelY - BorderConfig.rounding && y <= panelY + panel.height + BorderConfig.rounding;
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > bar.implicitWidth + panel.x && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        // Prevent activation when mouse is at the very top edge (y < 10)
        if (y < 10) return false;
        
        const panelX = bar.implicitWidth + panel.x;
        const panelY = BorderConfig.thickness + panel.y;
        
        // Only trigger if we're actually over the dashboard panel area
        // AND the panel is already visible (has some height)
        if (panel.height <= 0) return false;
        
        const inYRange = y >= panelY && y <= panelY + panel.height + 50; // Add buffer zone
        const inXRange = x >= panelX - BorderConfig.rounding && x <= panelX + panel.width + BorderConfig.rounding;
        
        // Also require that we're not at the very edges of the screen
        const screenMargin = 100; // Don't trigger within 100px of screen edges
        if (x < screenMargin || x > (root.width - screenMargin)) return false;
        
        return inYRange && inXRange;
    }

    // Debounce timer to prevent stuttering
    Timer {
        id: dashboardDebounceTimer
        interval: 150  // Increased from 50ms to 150ms for more stability
        onTriggered: {
            const shouldShow = inTopPanel(panels.dashboard, mouseX, mouseY);
            
            // Apply hysteresis: once shown, require more movement to hide
            const hysteresisThreshold = visibilities.dashboard ? 80 : 40;
            const distanceFromTop = mouseY;
            
            let finalShow = shouldShow;
            if (visibilities.dashboard && distanceFromTop > hysteresisThreshold) {
                finalShow = false;
            } else if (!visibilities.dashboard && distanceFromTop < hysteresisThreshold && shouldShow) {
                finalShow = true;
            }
            
            if (visibilities.dashboard !== finalShow) {
                console.log("Dashboard visibility change:", finalShow, "at", mouseX, mouseY, "distance from top:", distanceFromTop);
                visibilities.dashboard = finalShow;
            }
        }
    }

    // Timer for delayed dashboard hiding
    Timer {
        id: dashboardHideTimer
        interval: 200
        onTriggered: visibilities.dashboard = false
    }

    // Add hysteresis to prevent rapid on/off switching
    property bool dashboardHysteresis: false

    property real mouseX: 0
    property real mouseY: 0

    anchors.fill: parent
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            visibilities.osd = false;
            osdHovered = false;
            dashboardDebounceTimer.stop();
            
            // Use a delayed hide for dashboard to prevent stuttering
            dashboardHideTimer.start();
            
            popouts.hasCurrent = false;
        }
    }

    onPositionChanged: ({x, y}) => {
        mouseX = x;
        mouseY = y;
        
        // Show osd on hover
        const showOsd = inRightPanel(panels.osd, x, y);
        visibilities.osd = showOsd;
        osdHovered = showOsd;

        // Show/hide session on drag
        if (pressed && withinPanelHeight(panels.session, x, y)) {
            const dragX = x - dragStart.x;
            if (dragX < -SessionConfig.dragThreshold)
                visibilities.session = true;
            else if (dragX > SessionConfig.dragThreshold)
                visibilities.session = false;
        }

        // Show dashboard on hover with debouncing to prevent stuttering
        dashboardDebounceTimer.restart();

        // Show popouts on hover
        const popout = panels.popouts;
        if (x < bar.implicitWidth + popout.width) {
            if (x < bar.implicitWidth) {
                // Handle like part of bar
                bar.checkPopout(y);
            } else {
                // Keep on hover - but only if we're actually within the popout bounds
                const withinPopout = withinPanelHeight(popout, x, y);
                popouts.hasCurrent = withinPopout;
            }
        } else {
            popouts.hasCurrent = false;
        }
    }

    Osd.Interactions {
        screen: root.screen
        visibilities: root.visibilities
        hovered: root.osdHovered
    }
}
