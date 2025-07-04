pragma ComponentBehavior: Bound

import "../../../widgets"
import "../../../config"
import "../../../services-niri"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Math.max(Appearance.font.size.normal * 2, 32) // Ensure minimum tray icon size to prevent warnings
    implicitHeight: Math.max(Appearance.font.size.normal * 2, 32) // Ensure minimum tray icon size to prevent warnings

    onClicked: event => {
        if (event.button === Qt.LeftButton)
            modelData.activate();
        else if (modelData.hasMenu)
            menu.open();
    }

    // TODO custom menu
    QsMenuAnchor {
        id: menu

        menu: root.modelData.menu
        anchor.window: this.QsWindow.window
    }

    Item {
        id: iconContainer
        anchors.fill: parent

        IconImage {
            id: icon
            visible: {
                const iconStr = String(root.modelData.icon);
                // Filter out duplicate network icons that are already shown in StatusIcons
                // Allow bluetooth applets to show since custom bluetooth icon is now hidden
                return iconStr !== "" && 
                       !iconStr.includes("preferences-system-network") && 
                       !iconStr.includes("network-manager") &&
                       !iconStr.includes("nm-") &&
                       !iconStr.includes("wifi") &&
                       !iconStr.toLowerCase().includes("alacritty");
            }
            source: {
                let iconSource = String(root.modelData.icon);
                
                // Debug logging for all icons to see what we're dealing with
                console.log("Icon source:", iconSource);
                
                // Early filter to prevent loading problematic icons entirely
                if (iconSource.includes("preferences-system-network") || 
                    iconSource.includes("bluetooth") ||
                    iconSource.includes("blueman") ||
                    iconSource.includes("bluetoothctl") ||
                    iconSource.includes("bluetooth-symbolic") ||
                    iconSource.includes("bluetooth-active") ||
                    iconSource.includes("bluetooth-disabled") ||
                    iconSource.includes("wifi") ||
                    iconSource === "image-missing" ||
                    iconSource === "" ||
                    iconSource.includes("network-manager") ||
                    iconSource.includes("nm-") ||
                    iconSource.toLowerCase().includes("alacritty")) {
                    console.log("Filtering out problematic icon:", iconSource);
                    return ""; // Don't load the icon at all
                }
                
                if (iconSource.includes("?path=")) {
                    const [name, path] = iconSource.split("?path=");
                    iconSource = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                }
                
                return iconSource;
            }
            asynchronous: true
            anchors.fill: parent
            implicitWidth: Math.max(parent.width, 32) // Ensure minimum icon size to prevent warnings
            implicitHeight: Math.max(parent.height, 32) // Ensure minimum icon size to prevent warnings
        }

        MaterialIcon {
            visible: !icon.visible || String(icon.source) === ""
            text: {
                const iconSource = String(root.modelData.icon);
                if (iconSource.includes("bluetooth") || 
                    iconSource.includes("blueman") ||
                    iconSource.includes("bluetoothctl") ||
                    iconSource.includes("bluetooth-symbolic") ||
                    iconSource.includes("bluetooth-active") ||
                    iconSource.includes("bluetooth-disabled")) {
                    return "bluetooth_connected";
                } else if (iconSource.includes("network") || 
                          iconSource.includes("wifi") || 
                          iconSource.includes("nm-") ||
                          iconSource.includes("preferences-system-network")) {
                    return "wifi";
                } else if (iconSource.includes("Alacritty") || iconSource.includes("alacritty")) {
                    return "terminal";
                } else {
                    return "apps";
                }
            }
            color: Colours.palette.m3onSurface
            font.pointSize: Math.max(parent.width * 0.6, 16) // Increased minimum size to prevent warnings
            anchors.centerIn: parent
        }
    }
}
