import "../../widgets"
import "../../services-niri"
import "../../config"
// import "popouts" as BarPopouts
import "components"
import "components/workspaces"
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    // required property BarPopouts.Wrapper popouts

    // Add background rectangle for the bar
    Rectangle {
        anchors.fill: parent
        color: "#000000"  // OLED black background
        opacity: Colours.transparency.enabled ? Colours.transparency.base : 1  // Apply transparency directly since Bar is not inside Backgrounds
        z: -1  // Ensure it's behind other elements
    }

    function checkPopout(y: real): void {
        // Popouts functionality has been disabled
        return;
        
        // Original code commented out:
        // // Niri compatibility: add null checks to prevent errors
        // if (!activeWindow || !statusIcons || !tray) {
        //     if (popouts) popouts.hasCurrent = false;
        //     return;
        // }

        // const spacing = Appearance.spacing.small;
        // const aw = activeWindow.child;
        // const awy = activeWindow.y + (aw ? aw.y : 0);

        // const ty = tray.y;
        // const th = tray.implicitHeight;
        // const trayItems = tray.items;

        // const n = statusIcons ? statusIcons.network : null;
        // const ny = (statusIcons ? statusIcons.y : 0) + (n ? n.y : 0) - spacing / 2;

        // const b = statusIcons ? statusIcons.battery : null;
        // const by = (statusIcons ? statusIcons.y : 0) + (b ? b.y : 0) - spacing / 2;

        // if (aw && y >= awy && y <= awy + aw.implicitHeight) {
        //     popouts.currentName = "activewindow";
        //     popouts.currentCenter = Qt.binding(() => (activeWindow ? activeWindow.y : 0) + (aw ? aw.y : 0) + (aw ? aw.implicitHeight : 0) / 2);
        //     if (popouts) popouts.hasCurrent = true;
        // } else if (trayItems && y > ty && y < ty + th) {
        //     const index = Math.floor(((y - ty) / th) * trayItems.count);
        //     const item = trayItems.itemAt(index);

        //     if (item) {
        //         popouts.currentName = `traymenu${index}`;
        //         popouts.currentCenter = Qt.binding(() => (tray ? tray.y : 0) + (item ? item.y : 0) + (item ? item.implicitHeight : 0) / 2);
        //         if (popouts) popouts.hasCurrent = true;
        //     } else {
        //         if (popouts) popouts.hasCurrent = false;
        //     }
        // } else if (n && y >= ny && y <= ny + n.implicitHeight + spacing) {
        //     popouts.currentName = "network";
        //     popouts.currentCenter = Qt.binding(() => (statusIcons ? statusIcons.y : 0) + (n ? n.y : 0) + (n ? n.implicitHeight : 0) / 2);
        //     if (popouts) popouts.hasCurrent = true;
        // } else if (b && y >= by && y <= by + b.implicitHeight + spacing) {
        //     popouts.currentName = "battery";
        //     popouts.currentCenter = Qt.binding(() => (statusIcons ? statusIcons.y : 0) + (b ? b.y : 0) + (b ? b.implicitHeight : 0) / 2);
        //     if (popouts) popouts.hasCurrent = true;
        // } else {
        //     if (popouts) popouts.hasCurrent = false;
        // }
    }

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left

    implicitWidth: (child ? child.implicitWidth : 0) + BorderConfig.thickness * 2

    Item {
        id: child

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: Math.max(
            osIcon.implicitWidth || 0,
            workspaces.implicitWidth || 0,  // Re-enabled workspaces
            activeWindow.implicitWidth || 0,
            tray.implicitWidth || 0,
            clock.implicitWidth || 0,
            statusIcons.implicitWidth || 0,
            power.implicitWidth || 0
        )

        OsIcon {
            id: osIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Appearance.padding.small  // Changed from 'large' to 'small' for less margin
        }

        StyledRect {
            id: workspaces

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: osIcon.bottom
            anchors.topMargin: Appearance.spacing.normal

            radius: Appearance.rounding.full
            color: Colours.palette.m3surfaceContainer

            implicitWidth: workspacesInner.implicitWidth + Appearance.padding.small * 2
            implicitHeight: workspacesInner.implicitHeight + Appearance.padding.small * 2

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: -BorderConfig.thickness
                anchors.rightMargin: -BorderConfig.thickness

                onWheel: event => {
                    // Niri workspace navigation using niri msg
                    if (event.angleDelta.y > 0) {
                        NiriService.dispatch("focus-workspace-up");
                    } else {
                        NiriService.dispatch("focus-workspace-down"); 
                    }
                }
            }

            // Niri workspace indicator - shows name or position in vertical stack
            // Removed workspace name/index display since icon provides better visual indication
            /*
            StyledText {
                id: workspacesInner
                anchors.centerIn: parent
                text: getWorkspaceDisplayText()
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.smaller
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                
                function getWorkspaceDisplayText() {
                    if (NiriService.currentWorkspaceIsNamed && NiriService.currentWorkspaceName !== "") {
                        return NiriService.currentWorkspaceName;
                    } else {
                        return `${NiriService.currentMonitorWorkspaceIndex}/${NiriService.currentMonitorWorkspaceCount}`;
                    }
                }
                
                // Add a connection to ensure updates
                Connections {
                    target: NiriService
                    function onCurrentMonitorWorkspaceIndexChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                    function onCurrentMonitorWorkspaceCountChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                    function onCurrentWorkspaceNameChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                    function onCurrentWorkspaceIsNamedChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                    function onWorkspaceChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                    function onActiveWorkspaceChanged() {
                        workspacesInner.text = workspacesInner.getWorkspaceDisplayText();
                    }
                }
            }
            */
        }

        ActiveWindow {
            id: activeWindow

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: workspaces.bottom  // Changed back to workspaces.bottom
            anchors.bottom: tray.top
            anchors.margins: Appearance.spacing.large

            monitor: Brightness.getMonitorForScreen(root.screen)
        }

        Tray {
            id: tray

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: clock.top
            anchors.bottomMargin: Appearance.spacing.larger
        }

        Clock {
            id: clock

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: statusIcons.top
            anchors.bottomMargin: Appearance.spacing.normal
        }

        StatusIcons {
            id: statusIcons

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: power.top
            anchors.bottomMargin: Appearance.spacing.normal

            colour: Colours.palette.m3secondary
        }

        Power {
            id: power

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Appearance.padding.large
        }
    }
}
