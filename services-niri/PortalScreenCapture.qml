pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // Screen capture session state
    property bool sessionActive: false
    property bool permissionGranted: false
    property string sessionHandle: ""
    property string pipeWireNodeId: ""
    property string lastError: ""
    
    // Captured frame data
    property string captureData: ""
    property bool frameAvailable: false
    property int frameWidth: 0
    property int frameHeight: 0
    
    // Configuration
    readonly property int captureTypes: 3 // Both windows and monitors (WINDOW=1, MONITOR=2)
    readonly property int cursorMode: 2 // Embedded cursor
    
    // Portal check state
    property bool portalChecked: false
    
    // Signals for state changes
    signal sessionStarted()
    signal sessionEnded()
    signal frameUpdated()
    signal errorOccurred(var error)
    
    function startScreenCapture(windowTitle) {
        if (windowTitle === undefined) windowTitle = "";
        
        if (sessionActive) {
            console.log("PortalScreenCapture: Session already active");
            return;
        }
        
        // Try fallback first while portal integration is being perfected
        if (useFallback) {
            startFallbackCapture(windowTitle);
            return;
        }
        
        console.log("PortalScreenCapture: Starting screen capture session for:", windowTitle || "full screen");
        lastError = "";
        
        // Create D-Bus session via busctl
        var handleToken = "caelestia_" + Date.now();
        createSessionProc.command = [
            "busctl", "--user", "call",
            "org.freedesktop.portal.Desktop",
            "/org/freedesktop/portal/desktop",
            "org.freedesktop.portal.ScreenCast",
            "CreateSession",
            "a{sv}",
            "1", "handle_token", "s", handleToken
        ];
        createSessionProc.running = true;
    }
    
    function stopScreenCapture() {
        if (!sessionActive) {
            return;
        }
        
        console.log("PortalScreenCapture: Stopping screen capture session");
        
        // Stop continuous capture timer
        continuousCaptureTimer.stop();
        
        // Stop PipeWire stream if running
        if (pipeWireStreamProc.running) {
            pipeWireStreamProc.terminate();
        }
        
        // Stop fallback process if running
        if (fallbackProc.running) {
            fallbackProc.terminate();
        }
        
        resetSession();
    }
    
    function resetSession() {
        sessionActive = false;
        permissionGranted = false;
        sessionHandle = "";
        pipeWireNodeId = "";
        captureData = "";
        frameAvailable = false;
        frameWidth = 0;
        frameHeight = 0;
        sessionEnded();
    }
    
    function startPipeWireCapture() {
        if (!pipeWireNodeId) {
            root.lastError = "No PipeWire node ID available";
            root.errorOccurred(root.lastError);
            return;
        }
        
        console.log("PortalScreenCapture: Starting PipeWire capture for node:", pipeWireNodeId);
        
        // Use gstreamer for video capture (more appropriate than pw-cat for video)
        pipeWireStreamProc.command = [
            "gst-launch-1.0", "-q",
            "pipewiresrc", "target-object=" + pipeWireNodeId,
            "!", "videoconvert",
            "!", "jpegenc", "quality=60",
            "!", "fdsink", "fd=1"
        ];
        
        pipeWireStreamProc.running = true;
    }
    
    function checkPortalAvailability() {
        if (portalChecked) return; // Don't check repeatedly
        portalChecked = true;
        portalCheckProc.running = true;
    }
    
    // Process for creating portal session
    property Process createSessionProc: Process {
        id: createSessionProc
        
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    console.log("PortalScreenCapture: CreateSession response:", data);
                    root.lastError = "Response received: " + data.substring(0, 100);
                } catch (e) {
                    root.lastError = "Error creating session: " + e.toString();
                    root.errorOccurred(root.lastError);
                }
            }
        }
        
        stderr: SplitParser {
            onRead: function(data) {
                root.lastError = "CreateSession error: " + data;
                root.errorOccurred(root.lastError);
            }
        }
    }
    
    property Process portalCheckProc: Process {
        id: portalCheckProc
        
        command: [
            "busctl", "--user", "introspect",
            "org.freedesktop.portal.Desktop",
            "/org/freedesktop/portal/desktop"
        ]
        
        stdout: SplitParser {
            onRead: function(data) {
                if (data.includes("ScreenCast")) {
                    console.log("PortalScreenCapture: Portal is available");
                    root.lastError = "Portal available: ScreenCast found";
                } else {
                    console.log("PortalScreenCapture: ScreenCast portal not found");
                    root.lastError = "Portal check: ScreenCast not found";
                }
            }
        }
        
        stderr: SplitParser {
            onRead: function(data) {
                console.log("PortalScreenCapture: Portal check failed:", data);
                root.lastError = "Portal check failed: " + data;
            }
        }
    }
    
    // Simplified PipeWire process for initial testing
    property Process pipeWireStreamProc: Process {
        id: pipeWireStreamProc
        
        stdout: SplitParser {
            onRead: function(data) {
                root.captureData = data;
                root.frameAvailable = true;
                root.frameUpdated();
            }
        }
        
        stderr: SplitParser {
            onRead: function(data) {
                console.log("PortalScreenCapture PipeWire:", data);
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0 && sessionActive) {
                root.lastError = "PipeWire stream ended unexpectedly (exit code: " + exitCode + ")";
                root.errorOccurred(root.lastError);
            }
        }
    }
    
    // Fallback screen capture using grim (wlr-screencopy)
    property bool useFallback: true
    
    function startFallbackCapture(windowTitle) {
        if (!useFallback) return;
        
        console.log("PortalScreenCapture: Starting continuous screen capture for:", windowTitle);
        
        // Perform initial capture immediately
        performCapture();
        
        // Start continuous capture using a timer
        continuousCaptureTimer.restart();
    }
    
    // Timer for continuous screen capture
    property Timer continuousCaptureTimer: Timer {
        id: continuousCaptureTimer
        interval: 2000  // Capture every 2 seconds
        running: false
        repeat: true
        
        onTriggered: {
            // Continue capturing while the component is active
            performCapture();
        }
    }
    
    function performCapture() {
        console.log("PortalScreenCapture: Performing screen capture");
        
        // Use grim for reliable screen capture
        fallbackProc.command = [
            "grim", "-t", "jpeg", "-q", "70", "/tmp/caelestia-capture-live.jpg"
        ];
        fallbackProc.running = true;
    }
    
    // Process for fallback screen capture using grim
    property Process fallbackProc: Process {
        id: fallbackProc
        
        stdout: SplitParser {
            onRead: function(data) {
                console.log("PortalScreenCapture: Fallback capture output:", data);
            }
        }
        
        stderr: SplitParser {
            onRead: function(data) {
                console.log("PortalScreenCapture: Fallback capture error:", data);
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                console.log("PortalScreenCapture: Screen capture completed successfully");
                
                // Update capture data with timestamp to force refresh
                var timestamp = Date.now();
                root.captureData = "file:///tmp/caelestia-capture-live.jpg?t=" + timestamp;
                root.frameAvailable = true;
                root.frameUpdated();
                
                // Mark session as active on first successful capture
                if (!root.sessionActive) {
                    root.sessionActive = true;
                    root.sessionStarted();
                }
            } else {
                root.lastError = "Screen capture failed with exit code: " + exitCode;
                root.errorOccurred(root.lastError);
            }
        }
    }
    
    Component.onCompleted: {
        checkPortalAvailability();
    }
    
    Component.onDestruction: {
        if (sessionActive) {
            stopScreenCapture();
        }
    }
}
