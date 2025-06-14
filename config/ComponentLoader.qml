// Modular Component Loader
// Handles dynamic loading of shell components based on configuration

pragma Singleton

import QtQuick
import Quickshell
import "../config"

Singleton {
    id: root

    // Component registry
    property var loadedComponents: ({})
    property var componentStates: ({})
    property bool allComponentsLoaded: false
    property int loadedCount: 0
    property int totalComponents: 0

    // Component loading signals
    signal componentLoaded(string componentName)
    signal componentUnloaded(string componentName)
    signal allComponentsReady()
    signal componentError(string componentName, string error)

    // Core components that are always loaded
    readonly property var coreComponents: [
        { name: "Background", path: "modules/background/Background.qml" },
        { name: "Drawers", path: "modules/drawers/Drawers.qml" }
    ]

    // Optional components based on configuration
    readonly property var optionalComponents: [
        { 
            name: "Shortcuts", 
            path: "modules/Shortcuts.qml",
            condition: () => ConfigManager.isModuleEnabled("loadShortcuts")
        },
        { 
            name: "Border", 
            path: "config/BorderConfig.qml",
            condition: () => ConfigManager.isModuleEnabled("loadBorder")
        },
        { 
            name: "OSD", 
            path: "modules/osd/OSD.qml",
            condition: () => ConfigManager.isModuleEnabled("loadOSD")
        },
        { 
            name: "Dashboard", 
            path: "modules/dashboard/Dashboard.qml",
            condition: () => ConfigManager.isModuleEnabled("loadDashboard")
        },
        { 
            name: "Launcher", 
            path: "modules/launcher/Launcher.qml",
            condition: () => ConfigManager.isModuleEnabled("loadLauncher")
        },
        { 
            name: "Session", 
            path: "modules/session/Session.qml",
            condition: () => ConfigManager.isModuleEnabled("loadSession")
        },
        { 
            name: "Notifications", 
            path: "modules/notifications/Notifications.qml",
            condition: () => ConfigManager.isModuleEnabled("loadNotifications")
        }
    ]

    // Initialize component loading
    function initializeComponents(): void {
        console.log("ComponentLoader: Initializing modular components");
        
        // Count total components to load
        totalComponents = coreComponents.length;
        optionalComponents.forEach(comp => {
            if (comp.condition && comp.condition()) {
                totalComponents++;
            }
        });

        console.log("ComponentLoader: Loading", totalComponents, "components");

        // Load core components first
        coreComponents.forEach(comp => {
            loadComponent(comp.name, comp.path, true);
        });

        // Load optional components
        optionalComponents.forEach(comp => {
            if (comp.condition && comp.condition()) {
                loadComponent(comp.name, comp.path, false);
            } else {
                console.log("ComponentLoader: Skipping", comp.name, "(condition not met)");
            }
        });

        checkAllComponentsReady();
    }

    // Load a specific component
    function loadComponent(componentName: string, componentPath: string, required: bool): void {
        try {
            if (loadedComponents[componentName]) {
                console.warn("ComponentLoader: Component", componentName, "already loaded");
                return;
            }

            console.log("ComponentLoader: Loading component", componentName, "from", componentPath);
            
            componentStates[componentName] = "loading";
            
            // Create component metadata
            loadedComponents[componentName] = {
                name: componentName,
                path: componentPath,
                required: required,
                loaded: true,
                loadTime: Date.now()
            };

            componentStates[componentName] = "loaded";
            loadedCount++;

            componentLoaded(componentName);

            if (ConfigManager.debug.enableConsoleLogging) {
                console.log("ComponentLoader: Successfully loaded", componentName);
            }

        } catch (error) {
            console.error("ComponentLoader: Failed to load component", componentName, ":", error);
            componentStates[componentName] = "error";
            componentError(componentName, error.toString());
            
            // If it's a required component, this is a critical error
            if (required) {
                console.error("ComponentLoader: Critical component", componentName, "failed to load");
            }
        }
    }

    // Unload a component
    function unloadComponent(componentName: string): void {
        if (!loadedComponents[componentName]) {
            console.warn("ComponentLoader: Cannot unload", componentName, "(not loaded)");
            return;
        }

        const component = loadedComponents[componentName];
        if (component.required) {
            console.warn("ComponentLoader: Cannot unload required component", componentName);
            return;
        }

        console.log("ComponentLoader: Unloading component", componentName);
        
        delete loadedComponents[componentName];
        delete componentStates[componentName];
        loadedCount--;

        componentUnloaded(componentName);
    }

    // Check if all components are ready
    function checkAllComponentsReady(): void {
        if (loadedCount >= totalComponents && !allComponentsLoaded) {
            allComponentsLoaded = true;
            console.log("ComponentLoader: All", totalComponents, "components loaded successfully");
            allComponentsReady();
        }
    }

    // Get component status
    function getComponentStatus(componentName: string): string {
        return componentStates[componentName] || "not_loaded";
    }

    // Check if component is loaded
    function isComponentLoaded(componentName: string): bool {
        return loadedComponents[componentName] !== undefined;
    }

    // Get all loaded components
    function getLoadedComponents(): var {
        return Object.keys(loadedComponents);
    }

    // Get component statistics
    function getComponentStats(): var {
        const stats = {
            total: totalComponents,
            loaded: loadedCount,
            required: coreComponents.length,
            optional: 0,
            errors: 0
        };

        Object.values(componentStates).forEach(state => {
            if (state === "error") stats.errors++;
        });

        optionalComponents.forEach(comp => {
            if (comp.condition && comp.condition()) stats.optional++;
        });

        return stats;
    }

    // Reload components with new configuration
    function reloadComponents(): void {
        console.log("ComponentLoader: Reloading components with new configuration");
        
        // Reset counters
        loadedCount = 0;
        totalComponents = 0;
        allComponentsLoaded = false;
        
        // Clear optional components
        Object.keys(loadedComponents).forEach(componentName => {
            const component = loadedComponents[componentName];
            if (!component.required) {
                unloadComponent(componentName);
            }
        });

        // Reinitialize
        initializeComponents();
    }

    // Component health check
    function healthCheck(): bool {
        const stats = getComponentStats();
        const healthy = stats.errors === 0 && stats.loaded === stats.total;
        
        if (ConfigManager.debug.enableConsoleLogging) {
            console.log("ComponentLoader: Health check -", 
                       "Loaded:", stats.loaded, "/", stats.total,
                       "Errors:", stats.errors,
                       "Healthy:", healthy);
        }

        return healthy;
    }

    // Get component info
    function getComponentInfo(componentName: string): var {
        return loadedComponents[componentName] || null;
    }

    // Check if all required components are loaded
    function allRequiredComponentsLoaded(): bool {
        return coreComponents.every(comp => isComponentLoaded(comp.name));
    }

    // Get loading progress
    function getLoadingProgress(): real {
        return totalComponents > 0 ? loadedCount / totalComponents : 0;
    }

    // Auto-initialize when ready
    Component.onCompleted: {
        // Wait for ServiceManager to initialize first
        if (typeof ServiceManager !== "undefined") {
            ServiceManager.allServicesReady.connect(() => {
                console.log("ComponentLoader: Services ready, initializing components");
                Qt.callLater(() => initializeComponents());
            });
        } else {
            // Fallback if ServiceManager not available
            Qt.callLater(() => initializeComponents());
        }
    }

    // Periodic health check
    Timer {
        interval: 45000 // 45 seconds
        running: ConfigManager.debug.enablePerformanceMetrics
        repeat: true
        onTriggered: healthCheck()
    }
}
