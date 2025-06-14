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
    implicitWidth: Math.max(Appearance.font.size.normal * 2, 24) // Ensure minimum tray icon size
    implicitHeight: Math.max(Appearance.font.size.normal * 2, 24) // Ensure minimum tray icon size

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
                return iconStr !== "" && 
                       !iconStr.includes("preferences-system-network") && 
                       !iconStr.includes("bluetooth") &&
                       !iconStr.includes("blueman") &&
                       !iconStr.includes("network-manager") &&
                       !iconStr.includes("nm-") &&
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
            implicitWidth: Math.max(parent.width, 16) // Ensure minimum icon size
            implicitHeight: Math.max(parent.height, 16) // Ensure minimum icon size
        }

        MaterialIcon {
            visible: !icon.visible || String(icon.source) === ""
            text: {
                const iconSource = String(root.modelData.icon);
                if (iconSource.includes("bluetooth") || iconSource.includes("blueman")) {
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
            font.pointSize: Math.max(parent.width * 0.6, 8)
            anchors.centerIn: parent
        }
    }
}
