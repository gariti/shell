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
    property bool inPopoutArea: false
    
    // Timer to delay popout closing 
    Timer {
        id: popoutCloseTimer
        interval: 1000 // 1 second delay - very generous
        onTriggered: {
            // Only close if we're still not in the popout area AND not hovering over content
            if (!inPopoutArea && !popouts.mouseInContent) {
                popouts.hasCurrent = false;
            }
        }
    }

    // Timer to delay OSD closing
    Timer {
        id: osdCloseTimer
        interval: 1000 // 1 second delay
        onTriggered: {
            // Only close if not hovering over OSD content
            if (!panels.osd.mouseInContent) {
                visibilities.osd = false;
                osdHovered = false;
            }
        }
    }

    // Timer to delay Dashboard closing  
    Timer {
        id: dashboardCloseTimer
        interval: 1000 // 1 second delay
        onTriggered: {
            // Only close if not hovering over Dashboard content
            if (!panels.dashboard.mouseInContent) {
                visibilities.dashboard = false;
            }
        }
    }

    // Timer to detect when user has moved away from shell entirely
    Timer {
        id: focusLossTimer
        interval: 2000 // 2 second delay for focus loss detection
        onTriggered: {
            if (!containsMouse && !popouts.mouseInContent && !panels.osd.mouseInContent && !panels.dashboard.mouseInContent) {
                console.log("User appears to have moved away from shell - closing all popouts and drawers");
                popouts.hasCurrent = false;
                visibilities.osd = false;
                osdHovered = false;
                visibilities.dashboard = false;
            }
        }
    }

    Component.onCompleted: {
        console.log("🚀 INTERACTIONS.QML LOADED - this should appear in logs");
    }

    // Watch for window focus changes and close all popouts/drawers
    Connections {
        target: EventStream
        function onWindowChanged(eventData) {
            // Check if this is a window focus change
            if (eventData && Object.keys(eventData)[0] === "WindowsChanged") {
                // Parse the windows to see if focus changed
                const windowsData = eventData["WindowsChanged"];
                if (Array.isArray(windowsData)) {
                    // Look for focused window changes
                    const hasFocusedWindow = windowsData.some(window => window.is_focused === true);
                    if (hasFocusedWindow) {
                        console.log("Window focus changed to another application - closing all popouts and drawers");
                        // Close all popouts and drawers when focus moves to another window
                        popouts.hasCurrent = false;
                        visibilities.osd = false;
                        osdHovered = false;
                        visibilities.dashboard = false;
                        
                        // Stop all timers to prevent them from interfering
                        popoutCloseTimer.stop();
                        osdCloseTimer.stop();
                        dashboardCloseTimer.stop();
                    }
                }
            }
        }
    }

    // Watch for changes in mouseInContent and stop timer if mouse is over content
    Connections {
        target: popouts
        function onMouseInContentChanged() {
            if (popouts.mouseInContent) {
                console.log("Mouse in content - stopping close timer");
                popoutCloseTimer.stop();
                focusLossTimer.stop();
            }
        }
    }

    // Watch for changes in OSD mouseInContent
    Connections {
        target: panels.osd
        function onMouseInContentChanged() {
            if (panels.osd.mouseInContent) {
                console.log("Mouse in OSD content - stopping close timer");
                osdCloseTimer.stop();
                focusLossTimer.stop();
            }
        }
    }

    // Watch for changes in Dashboard mouseInContent
    Connections {
        target: panels.dashboard
        function onMouseInContentChanged() {
            if (panels.dashboard.mouseInContent) {
                console.log("Mouse in Dashboard content - stopping close timer");
                dashboardCloseTimer.stop();
                focusLossTimer.stop();
            }
        }
    }

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = BorderConfig.thickness + panel.y;
        return y >= panelY - BorderConfig.rounding && y <= panelY + panel.height + BorderConfig.rounding;
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > bar.implicitWidth + panel.x && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const panelX = bar.implicitWidth + panel.x;
        const margin = BorderConfig.rounding * 2; // Reduced from 4x to 2x for more precise control
        
        // Primary trigger zone at the very top of the screen
        const topTriggerHeight = BorderConfig.thickness + BorderConfig.rounding;
        const inTopTrigger = y <= topTriggerHeight && 
                            x >= panelX - margin && 
                            x <= panelX + panel.width + margin;
        
        // Extended hover zone when dashboard is already visible
        // Use a fixed large area instead of dynamic panel dimensions to avoid feedback loops
        const extendedHeight = 300; // Fixed height that covers typical dashboard content
        const inExtendedZone = visibilities.dashboard && 
                              y <= BorderConfig.thickness + extendedHeight && 
                              x >= panelX - margin && 
                              x <= panelX + panel.width + margin;
        
        return inTopTrigger || inExtendedZone;
    }

    property real mouseX: 0
    property real mouseY: 0

    anchors.fill: parent
    hoverEnabled: true
    
    // Close all popouts when the window loses focus
    onActiveFocusChanged: {
        if (!activeFocus) {
            console.log("Shell lost focus - closing all popouts and drawers");
            popouts.hasCurrent = false;
            visibilities.osd = false;
            osdHovered = false;
            visibilities.dashboard = false;
            
            // Stop all timers
            popoutCloseTimer.stop();
            osdCloseTimer.stop();
            dashboardCloseTimer.stop();
        }
    }

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            // Start the focus loss timer to detect if user has moved away
            focusLossTimer.start();
            
            // Start timers for OSD and Dashboard instead of immediately closing
            if (visibilities.osd && !panels.osd.mouseInContent) {
                osdCloseTimer.start();
            }
            if (visibilities.dashboard && !panels.dashboard.mouseInContent) {
                dashboardCloseTimer.start();
            }
            // Only start the timer if there's a popout AND we're not in the generous hover area AND not over content
            if (popouts.hasCurrent) {
                // Check if we're in the generous popout area before starting timer
                const popoutLeft = bar.implicitWidth;
                const popoutRight = bar.implicitWidth + 500;
                const popoutTop = -50;
                const popoutBottom = height + 50;
                
                const inGenerousArea = mouseX >= popoutLeft && mouseX <= popoutRight && 
                                     mouseY >= popoutTop && mouseY <= popoutBottom;
                
                if (!inGenerousArea && !popouts.mouseInContent) {
                    popoutCloseTimer.start();
                }
            }
        } else {
            // Mouse is back in the main interaction area, cancel all close timers
            focusLossTimer.stop();
            popoutCloseTimer.stop();
            osdCloseTimer.stop();
            dashboardCloseTimer.stop();
        }
    }

    onPositionChanged: ({x, y}) => {
        mouseX = x;
        mouseY = y;
        
        // Show osd on hover
        const showOsd = inRightPanel(panels.osd, x, y);
        visibilities.osd = showOsd;
        osdHovered = showOsd;
        
        // Stop OSD close timer if hovering over OSD area
        if (showOsd) {
            osdCloseTimer.stop();
        }

        // Show/hide session on drag
        if (pressed && withinPanelHeight(panels.session, x, y)) {
            const dragX = x - dragStart.x;
            if (dragX < -SessionConfig.dragThreshold)
                visibilities.session = true;
            else if (dragX > SessionConfig.dragThreshold)
                visibilities.session = false;
        }

        // Show dashboard on hover with comprehensive bounds checking
        const showDashboard = inTopPanel(panels.dashboard, x, y);
        visibilities.dashboard = showDashboard;
        
        // Stop Dashboard close timer if hovering over Dashboard area
        if (showDashboard) {
            dashboardCloseTimer.stop();
        }

        // Show popouts on hover - very generous bounds to prevent closing
        const popout = panels.popouts;
        
        if (x < bar.implicitWidth) {
            // Handle like part of bar
            bar.checkPopout(y);
            popoutCloseTimer.stop();
        } else if (popouts.hasCurrent) {
            // If a popout is active, be extremely generous about the hover area
            const popoutLeft = bar.implicitWidth;
            const popoutRight = bar.implicitWidth + 500; // Very wide area
            const popoutTop = -50; // Extend above
            const popoutBottom = parent.height + 50; // Extend below
            
            const inGenerousArea = x >= popoutLeft && x <= popoutRight && 
                                 y >= popoutTop && y <= popoutBottom;
            
            if (inGenerousArea || popouts.mouseInContent) {
                // Mouse is in the generous area OR over the content, keep popout open
                popoutCloseTimer.stop();
            } else {
                // Mouse is outside the generous area AND not over content, start close timer if not already running
                if (!popoutCloseTimer.running) {
                    popoutCloseTimer.start();
                }
            }
        }
    }

    Osd.Interactions {
        screen: root.screen
        visibilities: root.visibilities
        hovered: root.osdHovered
    }
}
