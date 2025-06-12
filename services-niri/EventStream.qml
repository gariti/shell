pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Event stream properties
    property bool eventStreamActive: false
    property var lastEvent: null
    property string lastEventType: ""
    property var eventHistory: []
    
    // Real-time state properties
    property var workspaceEvents: []
    property var windowEvents: []
    property var outputEvents: []
    
    // Signals for real-time updates
    signal workspaceChanged(var eventData)
    signal windowChanged(var eventData) 
    signal outputChanged(var eventData)
    signal eventReceived(var eventData, string eventType)
    
    // Event stream management functions
    function startEventStream(): void {
        if (!eventStreamActive) {
            console.log("Starting Niri event stream...");
            eventStreamProc.running = true;
            eventStreamActive = true;
        }
    }
    
    function stopEventStream(): void {
        if (eventStreamActive) {
            console.log("Stopping Niri event stream...");
            eventStreamProc.running = false;
            eventStreamActive = false;
        }
    }
    
    function restartEventStream(): void {
        stopEventStream();
        Qt.callLater(() => startEventStream());
    }
    
    // Event processing functions
    function processEvent(eventJson: string): void {
        try {
            const eventData = JSON.parse(eventJson);
            
            // Add to history (keep last 50 events)
            eventHistory.unshift({
                timestamp: new Date(),
                data: eventData,
                raw: eventJson
            });
            
            if (eventHistory.length > 50) {
                eventHistory.pop();
            }
            
            // Determine event type
            const eventType = Object.keys(eventData)[0];
            lastEvent = eventData;
            lastEventType = eventType;
            
            // Emit general event signal
            eventReceived(eventData, eventType);
            
            // Process specific event types
            if (eventType.includes("Workspace")) {
                workspaceEvents.unshift(eventData);
                if (workspaceEvents.length > 10) workspaceEvents.pop();
                workspaceChanged(eventData);
                
            } else if (eventType.includes("Window")) {
                windowEvents.unshift(eventData);
                if (windowEvents.length > 20) windowEvents.pop();
                windowChanged(eventData);
                
            } else if (eventType.includes("Output")) {
                outputEvents.unshift(eventData);
                if (outputEvents.length > 5) outputEvents.pop();
                outputChanged(eventData);
            }
            
        } catch (e) {
            console.warn("Failed to parse event JSON:", e, eventJson);
        }
    }
    
    // Utility functions
    function getEventsByType(type: string): var {
        return eventHistory.filter(event => {
            const eventType = Object.keys(event.data)[0];
            return eventType.includes(type);
        });
    }
    
    function getRecentEvents(count: int): var {
        return eventHistory.slice(0, Math.min(count, eventHistory.length));
    }
    
    function clearEventHistory(): void {
        eventHistory = [];
        workspaceEvents = [];
        windowEvents = [];
        outputEvents = [];
    }
    
    // Event stream process
    Process {
        id: eventStreamProc
        command: ["niri", "msg", "event-stream"]
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split('\n');
                for (const line of lines) {
                    if (line.length > 0) {
                        root.processEvent(line);
                    }
                }
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                console.warn("Niri event stream error:", data);
            }
        }
        
        onExited: {
            if (exitCode !== 0) {
                console.error("Niri event stream exited with code:", exitCode);
                eventStreamActive = false;
                
                // Attempt restart after 5 seconds if it wasn't intentionally stopped
                if (exitCode !== 143) { // 143 = SIGTERM (intentional stop)
                    console.log("Attempting to restart event stream in 5 seconds...");
                    restartTimer.start();
                }
            }
        }
        
        onStarted: {
            console.log("Niri event stream started successfully");
            eventStreamActive = true;
        }
    }
    
    // Restart timer for automatic recovery
    Timer {
        id: restartTimer
        interval: 5000
        repeat: false
        onTriggered: {
            console.log("Restarting Niri event stream...");
            startEventStream();
        }
    }
    
    // Health check timer - verify event stream is working
    Timer {
        id: healthCheckTimer
        interval: 30000 // Check every 30 seconds
        repeat: true
        running: eventStreamActive
        
        onTriggered: {
            // Check if we've received events recently
            if (eventHistory.length > 0) {
                const lastEventTime = eventHistory[0].timestamp;
                const timeDiff = new Date() - lastEventTime;
                
                // If no events for 2 minutes, restart stream
                if (timeDiff > 120000) {
                    console.warn("No events received for 2 minutes, restarting stream...");
                    restartEventStream();
                }
            }
        }
    }
    
    // Component initialization
    Component.onCompleted: {
        // Check if Niri is available before starting
        checkAvailabilityProc.running = true;
    }
    
    // Check Niri availability before starting event stream
    Process {
        id: checkAvailabilityProc
        command: ["niri", "msg", "version"]
        
        onExited: {
            if (exitCode === 0) {
                console.log("Niri is available, starting event stream...");
                Qt.callLater(() => startEventStream());
            } else {
                console.warn("Niri is not available, event stream disabled");
            }
        }
    }
    
    // Cleanup on destruction
    Component.onDestruction: {
        if (eventStreamActive) {
            stopEventStream();
        }
    }
}
