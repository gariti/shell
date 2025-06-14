// Modular Configuration Manager
// Centralizes all configuration management for the shell

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Module configuration flags
    readonly property bool enableAdvancedWindowManagement: true
    readonly property bool enableNiriEventStream: true
    readonly property bool enableGlobalShortcuts: false // Disabled for Niri compatibility
    readonly property bool enableWorkspacePreviews: false // Simplified for Niri
    readonly property bool enableBorderMasking: true
    readonly property bool enableAnimations: true
    readonly property bool enableDebugLogging: false

    // Performance configuration
    readonly property int updateInterval: 2000 // milliseconds
    readonly property int animationDuration: 300 // milliseconds
    readonly property int debounceDelay: 100 // milliseconds

    // UI Layout configuration
    readonly property var layout: QtObject {
        readonly property int barWidth: 70
        readonly property int cornerRadius: 12
        readonly property int spacing: 8
        readonly property int margin: 16
        readonly property int iconSize: 24
        readonly property int largeIconSize: 32
    }

    // Modular feature toggles
    readonly property var features: QtObject {
        readonly property bool wallpaperSupport: true
        readonly property bool systemTray: true
        readonly property bool notifications: true
        readonly property bool mediaControls: true
        readonly property bool batteryIndicator: true
        readonly property bool networkIndicator: true
        readonly property bool bluetoothIndicator: true
        readonly property bool volumeControl: true
        readonly property bool brightnessControl: true
        readonly property bool sessionManagement: true
        readonly property bool workspaceManagement: true
        readonly property bool applicationLauncher: true
    }

    // Niri-specific configuration
    readonly property var niri: QtObject {
        readonly property bool useCompatibilityLayer: true
        readonly property bool simulateHyprlandAPI: true
        readonly property bool enableEventStream: root.enableNiriEventStream
        readonly property int workspaceCount: 5
        readonly property bool autoCreateWorkspaces: true
        readonly property string defaultTerminal: "alacritty"
        readonly property string defaultLauncher: "rofi-wayland"
    }

    // Service configuration
    readonly property var services: QtObject {
        readonly property bool timeService: true
        readonly property bool audioService: true
        readonly property bool networkService: true
        readonly property bool bluetoothService: true
        readonly property bool wallpaperService: root.features.wallpaperSupport
        readonly property bool notificationService: root.features.notifications
        readonly property bool brightnessService: root.features.brightnessControl
        readonly property bool batteryService: root.features.batteryIndicator
        readonly property bool systemUsageService: true
        readonly property bool mediaService: root.features.mediaControls
    }

    // Theme and styling configuration
    readonly property var theme: QtObject {
        readonly property bool useMaterialDesign3: true
        readonly property bool enableTransparency: true
        readonly property bool enableBlur: false // Disabled for performance
        readonly property bool enableShadows: true
        readonly property real opacity: 0.95
        readonly property string fontFamily: "IBM Plex Sans"
        readonly property string monospaceFontFamily: "JetBrains Mono NF"
        readonly property string iconTheme: "Material Symbols Rounded"
    }

    // Debug and development configuration
    readonly property var debug: QtObject {
        readonly property bool enableConsoleLogging: root.enableDebugLogging
        readonly property bool enableServiceLogging: root.enableDebugLogging
        readonly property bool enableIpcLogging: root.enableDebugLogging
        readonly property bool enablePerformanceMetrics: false
        readonly property bool showBoundingBoxes: false
    }

    // Module loading configuration
    readonly property var modules: QtObject {
        readonly property bool loadBackground: true
        readonly property bool loadDrawers: true
        readonly property bool loadShortcuts: !root.enableGlobalShortcuts // Use built-in shortcuts instead
        readonly property bool loadBorder: root.enableBorderMasking
        readonly property bool loadOSD: true
        readonly property bool loadNotifications: root.features.notifications
        readonly property bool loadDashboard: true
        readonly property bool loadLauncher: root.features.applicationLauncher
        readonly property bool loadSession: root.features.sessionManagement
    }

    // Validation and runtime checks
    function validateConfiguration(): bool {
        let valid = true;
        let warnings = [];

        // Check for conflicting configurations
        if (enableGlobalShortcuts && niri.useCompatibilityLayer) {
            warnings.push("Global shortcuts are not supported with Niri compatibility layer");
            valid = false;
        }

        if (enableWorkspacePreviews && !features.workspaceManagement) {
            warnings.push("Workspace previews require workspace management to be enabled");
        }

        if (theme.enableBlur && !theme.enableTransparency) {
            warnings.push("Blur effects require transparency to be enabled");
        }

        // Log warnings
        for (const warning of warnings) {
            console.warn("ConfigManager:", warning);
        }

        return valid;
    }

    // Get feature flag
    function isFeatureEnabled(featureName: string): bool {
        const feature = features[featureName];
        return feature !== undefined ? feature : false;
    }

    // Get service flag
    function isServiceEnabled(serviceName: string): bool {
        const service = services[serviceName];
        return service !== undefined ? service : false;
    }

    // Get module flag
    function isModuleEnabled(moduleName: string): bool {
        const module = modules[moduleName];
        return module !== undefined ? module : false;
    }

    // Get theme property
    function getThemeProperty(propertyName: string): var {
        return theme[propertyName];
    }

    // Get layout property
    function getLayoutProperty(propertyName: string): var {
        return layout[propertyName];
    }

    // Initialize configuration
    Component.onCompleted: {
        console.log("ConfigManager: Initializing modular configuration");
        
        if (!validateConfiguration()) {
            console.warn("ConfigManager: Configuration validation failed, some features may not work correctly");
        }

        if (debug.enableConsoleLogging) {
            console.log("ConfigManager: Debug logging enabled");
            console.log("ConfigManager: Niri compatibility mode:", niri.useCompatibilityLayer);
            console.log("ConfigManager: Event stream enabled:", niri.enableEventStream);
            console.log("ConfigManager: Border masking enabled:", enableBorderMasking);
        }
    }
}
