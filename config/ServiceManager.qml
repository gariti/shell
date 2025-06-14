// Modular Service Manager
// Handles dynamic loading and management of services

pragma Singleton

import QtQuick
import Quickshell
import "../services-niri"
import "../config"

Singleton {
    id: root

    // Service registry
    property var loadedServices: ({})
    property var serviceStates: ({})
    property bool allServicesLoaded: false
    property int loadedCount: 0
    property int totalServices: 0

    // Service loading signals
    signal serviceLoaded(string serviceName)
    signal serviceUnloaded(string serviceName)
    signal allServicesReady()
    signal serviceError(string serviceName, string error)

    // Essential services that must always be loaded
    readonly property var essentialServices: [
        "Time",
        "Colours",
        "Visibilities"
    ]

    // Conditional services based on configuration
    readonly property var conditionalServices: [
        { name: "Audio", condition: () => ConfigManager.isServiceEnabled("audioService") },
        { name: "Network", condition: () => ConfigManager.isServiceEnabled("networkService") },
        { name: "Bluetooth", condition: () => ConfigManager.isServiceEnabled("bluetoothService") },
        { name: "Brightness", condition: () => ConfigManager.isServiceEnabled("brightnessService") },
        { name: "Wallpapers", condition: () => ConfigManager.isServiceEnabled("wallpaperService") },
        { name: "Notifs", condition: () => ConfigManager.isServiceEnabled("notificationService") },
        { name: "SystemUsage", condition: () => ConfigManager.isServiceEnabled("systemUsageService") },
        { name: "Players", condition: () => ConfigManager.isServiceEnabled("mediaService") },
        { name: "Apps", condition: () => ConfigManager.isFeatureEnabled("applicationLauncher") },
        { name: "NiriService", condition: () => ConfigManager.niri.useCompatibilityLayer },
        { name: "NiriEventManager", condition: () => ConfigManager.niri.enableEventStream },
        { name: "AdvancedWindowManager", condition: () => ConfigManager.enableAdvancedWindowManagement },
        { name: "NiriToplevelManager", condition: () => ConfigManager.enableAdvancedWindowManagement }
    ]

    // Niri-specific services
    readonly property var niriServices: [
        "Hyprland", // Compatibility layer
        "NiriService",
        "NiriEventManager",
        "NiriToplevelManager"
    ]

    // Initialize service manager
    function initializeServices(): void {
        console.log("ServiceManager: Initializing modular services");
        
        // Count total services to load
        totalServices = essentialServices.length;
        conditionalServices.forEach(service => {
            if (service.condition()) {
                totalServices++;
            }
        });

        console.log("ServiceManager: Loading", totalServices, "services");

        // Load essential services first
        essentialServices.forEach(serviceName => {
            loadService(serviceName, true);
        });

        // Load conditional services
        conditionalServices.forEach(service => {
            if (service.condition()) {
                loadService(service.name, false);
            } else {
                console.log("ServiceManager: Skipping", service.name, "(condition not met)");
            }
        });

        // Check if all services are ready
        checkAllServicesReady();
    }

    // Load a specific service
    function loadService(serviceName: string, essential: bool): void {
        try {
            if (loadedServices[serviceName]) {
                console.warn("ServiceManager: Service", serviceName, "already loaded");
                return;
            }

            console.log("ServiceManager: Loading service", serviceName);
            
            // Mark service as loading
            serviceStates[serviceName] = "loading";
            
            // Service is loaded via QML import system, so we just track it
            loadedServices[serviceName] = {
                name: serviceName,
                essential: essential,
                loaded: true,
                loadTime: Date.now()
            };

            serviceStates[serviceName] = "loaded";
            loadedCount++;

            serviceLoaded(serviceName);

            if (ConfigManager.debug.enableServiceLogging) {
                console.log("ServiceManager: Successfully loaded", serviceName);
            }

        } catch (error) {
            console.error("ServiceManager: Failed to load service", serviceName, ":", error);
            serviceStates[serviceName] = "error";
            serviceError(serviceName, error.toString());
        }
    }

    // Unload a service (for dynamic reconfiguration)
    function unloadService(serviceName: string): void {
        if (!loadedServices[serviceName]) {
            console.warn("ServiceManager: Cannot unload", serviceName, "(not loaded)");
            return;
        }

        if (essentialServices.includes(serviceName)) {
            console.warn("ServiceManager: Cannot unload essential service", serviceName);
            return;
        }

        console.log("ServiceManager: Unloading service", serviceName);
        
        delete loadedServices[serviceName];
        delete serviceStates[serviceName];
        loadedCount--;

        serviceUnloaded(serviceName);
    }

    // Check if all services are ready
    function checkAllServicesReady(): void {
        if (loadedCount >= totalServices && !allServicesLoaded) {
            allServicesLoaded = true;
            console.log("ServiceManager: All", totalServices, "services loaded successfully");
            allServicesReady();
        }
    }

    // Get service status
    function getServiceStatus(serviceName: string): string {
        return serviceStates[serviceName] || "not_loaded";
    }

    // Check if service is loaded
    function isServiceLoaded(serviceName: string): bool {
        return loadedServices[serviceName] !== undefined;
    }

    // Get all loaded services
    function getLoadedServices(): var {
        return Object.keys(loadedServices);
    }

    // Get service statistics
    function getServiceStats(): var {
        const stats = {
            total: totalServices,
            loaded: loadedCount,
            essential: essentialServices.length,
            conditional: 0,
            errors: 0
        };

        Object.values(serviceStates).forEach(state => {
            if (state === "error") stats.errors++;
        });

        conditionalServices.forEach(service => {
            if (service.condition()) stats.conditional++;
        });

        return stats;
    }

    // Reload configuration and restart services
    function reloadServices(): void {
        console.log("ServiceManager: Reloading services with new configuration");
        
        // Reset counters
        loadedCount = 0;
        totalServices = 0;
        allServicesLoaded = false;
        
        // Clear non-essential services
        Object.keys(loadedServices).forEach(serviceName => {
            if (!essentialServices.includes(serviceName)) {
                unloadService(serviceName);
            }
        });

        // Reinitialize
        initializeServices();
    }

    // Service health check
    function healthCheck(): bool {
        const stats = getServiceStats();
        const healthy = stats.errors === 0 && stats.loaded === stats.total;
        
        if (ConfigManager.debug.enableServiceLogging) {
            console.log("ServiceManager: Health check -", 
                       "Loaded:", stats.loaded, "/", stats.total,
                       "Errors:", stats.errors,
                       "Healthy:", healthy);
        }

        return healthy;
    }

    // Connect to configuration changes
    Connections {
        target: ConfigManager
        // If ConfigManager had configuration change signals, we'd reconnect here
    }

    // Auto-initialize on component creation
    Component.onCompleted: {
        // Small delay to ensure ConfigManager is ready
        Qt.callLater(() => initializeServices());
    }

    // Periodic health check
    Timer {
        interval: 30000 // 30 seconds
        running: ConfigManager.debug.enablePerformanceMetrics
        repeat: true
        onTriggered: healthCheck()
    }
}
