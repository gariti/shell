// Enhanced Niri Event Stream Manager
// Provides real-time event streaming for better responsiveness

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Event stream properties
    property bool connected: false
    property bool active: false
    property var lastEvent: null
    property string lastEventType: ""
    
    // Event handlers that other components can connect to
    signal workspaceChanged(var workspaceData)
    signal windowFocusChanged(var windowData)
    signal windowCreated(var windowData)
    signal windowClosed(var windowData)
    signal outputChanged(var outputData)
    signal compositorEvent(var eventData)

    // Start the event stream
    function startEventStream(): void {
        console.log("NiriEventManager: Starting event stream");
        eventProcess.running = true;
        active = true;
    }

    // Stop the event stream 
    function stopEventStream(): void {
        console.log("NiriEventManager: Stopping event stream");
        eventProcess.running = false;
        active = false;
        connected = false;
    }

    // Restart the event stream (useful for reconnection)
    function restartEventStream(): void {
        stopEventStream();
        Qt.callLater(() => startEventStream());
    }

    // Main event stream process
    Process {
        id: eventProcess
        command: ["niri", "msg", "-j", "event-stream"]
        
        stdout: SplitParser {
            onRead: data => {
                if (!connected) {
                    connected = true;
                    console.log("NiriEventManager: Connected to event stream");
                }
                
                try {
                    const event = JSON.parse(data);
                    root.lastEvent = event;
                    
                    // Parse different event types
                    if (event.WorkspacesChanged) {
                        root.lastEventType = "WorkspacesChanged";
                        root.workspaceChanged(event.WorkspacesChanged);
                    } else if (event.WorkspaceActivated) {
                        root.lastEventType = "WorkspaceActivated";
                        root.workspaceChanged(event.WorkspaceActivated);
                    } else if (event.WindowOpenedOrChanged) {
                        root.lastEventType = "WindowOpenedOrChanged";
                        root.windowCreated(event.WindowOpenedOrChanged);
                    } else if (event.WindowClosed) {
                        root.lastEventType = "WindowClosed";
                        root.windowClosed(event.WindowClosed);
                    } else if (event.WindowFocusChanged) {
                        root.lastEventType = "WindowFocusChanged";
                        root.windowFocusChanged(event.WindowFocusChanged);
                    } else if (event.Output) {
                        root.lastEventType = "Output";
                        root.outputChanged(event.Output);
                    } else {
                        root.lastEventType = "Other";
                        root.compositorEvent(event);
                    }
                } catch (e) {
                    console.warn("NiriEventManager: Failed to parse event:", e, "Data:", data);
                }
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                console.warn("NiriEventManager stderr:", data);
                connected = false;
            }
        }
        
        onExited: {
            connected = false;
            if (active && exitCode !== 0) {
                console.warn("NiriEventManager: Event stream disconnected, attempting restart in 3 seconds");
                reconnectTimer.start();
            }
        }
    }

    // Reconnection timer
    Timer {
        id: reconnectTimer
        interval: 3000
        onTriggered: {
            if (active) {
                console.log("NiriEventManager: Attempting to reconnect");
                startEventStream();
            }
        }
    }

    // Auto-start event stream
    Component.onCompleted: {
        // Small delay to ensure other services are ready
        Qt.callLater(() => startEventStream());
    }

    Component.onDestruction: {
        stopEventStream();
    }
}
