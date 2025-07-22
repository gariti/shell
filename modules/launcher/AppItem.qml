import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property DesktopEntry modelData
    required property PersistentProperties visibilities

    implicitHeight: LauncherConfig.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.full

        function onClicked(): void {
            console.log("AppItem clicked:", root.modelData?.name, "id:", root.modelData?.id);
            Apps.launch(root.modelData);
            root.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        Item {
            id: iconContainer

            implicitWidth: parent.height * 0.8
            implicitHeight: parent.height * 0.8
            anchors.verticalCenter: parent.verticalCenter

            IconImage {
                id: icon
                visible: source !== ""
                source: {
                    if (!root.modelData?.icon) return "";
                    
                    const iconName = root.modelData.icon;
                    
                    // Direct path fallback for specific problematic icons
                    if (iconName === "preferences-system-network") {
                        // Try different icon sizes and formats
                        const iconPaths = [
                            "file:///run/current-system/sw/share/icons/Papirus/64x64/apps/preferences-system-network.svg",
                            "file:///run/current-system/sw/share/icons/Papirus/48x48/apps/preferences-system-network.svg",
                            "file:///run/current-system/sw/share/icons/Papirus/32x32/apps/preferences-system-network.svg",
                            "/run/current-system/sw/share/icons/hicolor/48x48/apps/preferences-system-network.png"
                        ];
                        
                        // Return the first available path
                        for (const path of iconPaths) {
                            // For now, just try the first file:// URL
                            return iconPaths[0];
                        }
                    }
                    
                    const iconPath = Quickshell.iconPath(root.modelData.icon, "");
                    if (iconPath !== "") {
                        return iconPath;
                    }
                    
                    // Fallback: try common alternative icon names for specific cases
                    if (iconName === "preferences-system-network") {
                        // Try alternative names for network settings
                        const alternatives = ["network-manager", "network-wired", "network", "preferences-network", "system-network"];
                        for (const alt of alternatives) {
                            const altPath = Quickshell.iconPath(alt, "");
                            if (altPath !== "") return altPath;
                        }
                    }
                    
                    return "";
                }
                implicitSize: parent.width
                anchors.centerIn: parent
            }

            MaterialIcon {
                visible: !icon.visible
                text: "apps"
                color: Colours.palette.m3onSurface
                font.pointSize: Math.max(parent.width * 0.6, 8)
                anchors.centerIn: parent
            }
        }

        Item {
            anchors.left: iconContainer.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: iconContainer.verticalCenter

            implicitWidth: parent.width - iconContainer.width
            implicitHeight: name.implicitHeight + comment.implicitHeight

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                id: comment

                text: (root.modelData?.comment || root.modelData?.genericName || root.modelData?.name) ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.alpha(Colours.palette.m3outline, true)

                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
