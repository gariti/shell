// Modular Widget Manager
// Handles dynamic widget loading and state management

pragma Singleton

import QtQuick
import Quickshell
import "../config"

Singleton {
    id: root

    // Widget registry
    property var loadedWidgets: ({})
    property var widgetStates: ({})
    property var widgetInstances: ({})

    // Widget categories
    readonly property var barWidgets: [
        "Clock", "SystemTray", "WorkspaceIndicator", "VolumeSlider", 
        "BrightnessSlider", "NetworkIndicator", "BluetoothIndicator",
        "BatteryIndicator", "PowerButton", "OsIcon"
    ]

    readonly property var dashboardWidgets: [
        "WeatherWidget", "SystemMonitor", "MediaControls", "CalendarWidget",
        "QuickSettings", "AppGrid", "RecentFiles"
    ]

    readonly property var osdWidgets: [
        "VolumeOSD", "BrightnessOSD", "NotificationOSD"
    ]

    // Widget loading signals
    signal widgetLoaded(string widgetName, string category)
    signal widgetUnloaded(string widgetName)
    signal widgetError(string widgetName, string error)

    // Load widgets for a specific category
    function loadWidgetCategory(category: string): void {
        console.log("WidgetManager: Loading", category, "widgets");
        
        let widgets = [];
        switch (category) {
            case "bar":
                widgets = barWidgets;
                break;
            case "dashboard":
                widgets = dashboardWidgets;
                break;
            case "osd":
                widgets = osdWidgets;
                break;
            default:
                console.warn("WidgetManager: Unknown widget category:", category);
                return;
        }

        widgets.forEach(widgetName => {
            if (shouldLoadWidget(widgetName)) {
                loadWidget(widgetName, category);
            }
        });
    }

    // Check if widget should be loaded based on configuration
    function shouldLoadWidget(widgetName: string): bool {
        switch (widgetName) {
            case "BatteryIndicator":
                return ConfigManager.isFeatureEnabled("batteryIndicator");
            case "NetworkIndicator":
                return ConfigManager.isFeatureEnabled("networkIndicator");
            case "BluetoothIndicator":
                return ConfigManager.isFeatureEnabled("bluetoothIndicator");
            case "VolumeSlider":
            case "VolumeOSD":
                return ConfigManager.isFeatureEnabled("volumeControl");
            case "BrightnessSlider":
            case "BrightnessOSD":
                return ConfigManager.isFeatureEnabled("brightnessControl");
            case "MediaControls":
                return ConfigManager.isFeatureEnabled("mediaControls");
            case "SystemTray":
                return ConfigManager.isFeatureEnabled("systemTray");
            case "NotificationOSD":
                return ConfigManager.isFeatureEnabled("notifications");
            case "WeatherWidget":
                return ConfigManager.isServiceEnabled("weatherService");
            default:
                return true; // Load by default
        }
    }

    // Load a specific widget
    function loadWidget(widgetName: string, category: string): void {
        if (loadedWidgets[widgetName]) {
            console.warn("WidgetManager: Widget", widgetName, "already loaded");
            return;
        }

        try {
            console.log("WidgetManager: Loading widget", widgetName, "in category", category);
            
            widgetStates[widgetName] = "loading";
            
            // Widget metadata
            loadedWidgets[widgetName] = {
                name: widgetName,
                category: category,
                loaded: true,
                loadTime: Date.now(),
                enabled: true
            };

            widgetStates[widgetName] = "loaded";
            widgetLoaded(widgetName, category);

            if (ConfigManager.debug.enableConsoleLogging) {
                console.log("WidgetManager: Successfully loaded widget", widgetName);
            }

        } catch (error) {
            console.error("WidgetManager: Failed to load widget", widgetName, ":", error);
            widgetStates[widgetName] = "error";
            widgetError(widgetName, error.toString());
        }
    }

    // Unload a widget
    function unloadWidget(widgetName: string): void {
        if (!loadedWidgets[widgetName]) {
            console.warn("WidgetManager: Cannot unload", widgetName, "(not loaded)");
            return;
        }

        console.log("WidgetManager: Unloading widget", widgetName);
        
        // Clean up widget instance if it exists
        if (widgetInstances[widgetName]) {
            delete widgetInstances[widgetName];
        }

        delete loadedWidgets[widgetName];
        delete widgetStates[widgetName];

        widgetUnloaded(widgetName);
    }

    // Enable/disable a widget
    function setWidgetEnabled(widgetName: string, enabled: bool): void {
        if (!loadedWidgets[widgetName]) {
            console.warn("WidgetManager: Cannot modify", widgetName, "(not loaded)");
            return;
        }

        loadedWidgets[widgetName].enabled = enabled;
        console.log("WidgetManager: Widget", widgetName, enabled ? "enabled" : "disabled");
    }

    // Check if widget is loaded and enabled
    function isWidgetEnabled(widgetName: string): bool {
        const widget = loadedWidgets[widgetName];
        return widget ? widget.enabled : false;
    }

    // Get widget status
    function getWidgetStatus(widgetName: string): string {
        return widgetStates[widgetName] || "not_loaded";
    }

    // Get widgets by category
    function getWidgetsByCategory(category: string): var {
        return Object.values(loadedWidgets).filter(widget => widget.category === category);
    }

    // Get all loaded widgets
    function getAllLoadedWidgets(): var {
        return Object.keys(loadedWidgets);
    }

    // Widget statistics
    function getWidgetStats(): var {
        const stats = {
            total: 0,
            loaded: Object.keys(loadedWidgets).length,
            enabled: 0,
            errors: 0,
            byCategory: {
                bar: 0,
                dashboard: 0,
                osd: 0
            }
        };

        Object.values(loadedWidgets).forEach(widget => {
            if (widget.enabled) stats.enabled++;
            if (stats.byCategory[widget.category] !== undefined) {
                stats.byCategory[widget.category]++;
            }
        });

        Object.values(widgetStates).forEach(state => {
            if (state === "error") stats.errors++;
        });

        stats.total = barWidgets.length + dashboardWidgets.length + osdWidgets.length;

        return stats;
    }

    // Initialize all widget categories
    function initializeAllWidgets(): void {
        console.log("WidgetManager: Initializing all widget categories");
        loadWidgetCategory("bar");
        loadWidgetCategory("dashboard");
        loadWidgetCategory("osd");
    }

    // Reload widgets based on current configuration
    function reloadWidgets(): void {
        console.log("WidgetManager: Reloading widgets with new configuration");
        
        // Clear all widgets
        Object.keys(loadedWidgets).forEach(widgetName => {
            unloadWidget(widgetName);
        });

        // Reload all categories
        initializeAllWidgets();
    }

    // Widget health check
    function healthCheck(): bool {
        const stats = getWidgetStats();
        const healthy = stats.errors === 0;
        
        if (ConfigManager.debug.enableConsoleLogging) {
            console.log("WidgetManager: Health check -", 
                       "Loaded:", stats.loaded,
                       "Enabled:", stats.enabled,
                       "Errors:", stats.errors,
                       "Healthy:", healthy);
        }

        return healthy;
    }

    // Auto-initialize when component loader is ready
    Component.onCompleted: {
        if (typeof ComponentLoader !== "undefined") {
            ComponentLoader.allComponentsReady.connect(() => {
                console.log("WidgetManager: Components ready, initializing widgets");
                Qt.callLater(() => initializeAllWidgets());
            });
        } else {
            Qt.callLater(() => initializeAllWidgets());
        }
    }

    // Periodic health check
    Timer {
        interval: 60000 // 60 seconds
        running: ConfigManager.debug.enablePerformanceMetrics
        repeat: true
        onTriggered: healthCheck()
    }
}
