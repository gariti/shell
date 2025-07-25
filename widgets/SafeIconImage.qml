import QtQuick
import QtQuick.Controls
import Quickshell.Widgets

// SafeIconImage - A wrapper around IconImage that handles missing icons gracefully
Item {
    id: root

    property string source: ""
    property real implicitSize: 16
    property alias asynchronous: iconImage.asynchronous

    readonly property bool hasIcon: iconImage.status === Image.Ready

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    function shouldFilterIcon(iconSource) {
        const problematicIcons = [
            ""
        ];
        
        return problematicIcons.some(problematic => 
            String(iconSource).includes(problematic)
        );
    }

    IconImage {
        id: iconImage
        
        anchors.fill: parent
        visible: !shouldFilterIcon(root.source) && root.source !== ""
        
        source: {
            if (shouldFilterIcon(root.source)) {
                console.log("SafeIconImage: Filtering problematic icon:", root.source);
                return "";
            }
            
            // Handle specific bluetooth and network icons with direct paths
            const iconStr = String(root.source);
            if (iconStr.includes("bluetooth") || iconStr.includes("blueman")) {
                // Try direct path to bluetooth icon from devices directory
                return "file:///run/current-system/sw/share/icons/Papirus/48x48/devices/bluetooth.svg";
            }
            if (iconStr.includes("preferences-system-network")) {
                return "file:///run/current-system/sw/share/icons/Papirus/64x64/apps/preferences-system-network.svg";
            }
            
            return root.source;
        }
        
        asynchronous: true
        
        // Ensure minimum size to prevent tiny icon warnings
        implicitWidth: Math.max(root.implicitSize, 32)
        implicitHeight: Math.max(root.implicitSize, 32)
        
        onStatusChanged: {
            if (status === Image.Error) {
                console.log("SafeIconImage: Failed to load icon:", root.source);
            }
        }
    }
    
    // Fallback icon for network-related missing icons
    Text {
        anchors.centerIn: parent
        visible: !iconImage.visible && shouldShowFallback()
        text: getFallbackIcon()
        font.family: "Material Symbols Rounded"
        font.pointSize: Math.max(root.implicitSize * 0.6, 12)
        color: "#E5E1E9"
        
        function shouldShowFallback() {
            return String(root.source).includes("network") || 
                   String(root.source).includes("bluetooth") ||
                   String(root.source).includes("preferences-system");
        }
        
        function getFallbackIcon() {
            const src = String(root.source);
            if (src.includes("network") || src.includes("preferences-system-network")) {
                return "wifi";
            }
            if (src.includes("bluetooth") || src.includes("blueman")) {
                return "bluetooth";
            }
            return "settings";
        }
    }
}
