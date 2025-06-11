import "root:/widgets"
import "root:/services-niri"
import "root:/config"
import "root:/modules/bar/popouts" as BarPopouts
import "components"
import "components/workspaces"
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts

    function checkPopout(y: real): void {
        // Niri compatibility: add null checks to prevent errors
        if (!activeWindow || !statusIcons || !statusIconsInner || !tray) {
            popouts.hasCurrent = false;
            return;
        }

        const spacing = Appearance.spacing.small;
        const aw = activeWindow.child;
        const awy = activeWindow.y + (aw ? aw.y : 0);

        const ty = tray.y;
        const th = tray.implicitHeight;
        const trayItems = tray.items;

        const n = statusIconsInner ? statusIconsInner.network : null;
        const ny = (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (n ? n.y : 0) - spacing / 2;

        const bls = (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (statusIconsInner ? statusIconsInner.bs : 0) - spacing / 2;
        const ble = (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (statusIconsInner ? statusIconsInner.be : 0) + spacing / 2;

        const b = statusIconsInner ? statusIconsInner.battery : null;
        const by = (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (b ? b.y : 0) - spacing / 2;

        if (aw && y >= awy && y <= awy + aw.implicitHeight) {
            popouts.currentName = "activewindow";
            popouts.currentCenter = Qt.binding(() => (activeWindow ? activeWindow.y : 0) + (aw ? aw.y : 0) + (aw ? aw.implicitHeight : 0) / 2);
            if (popouts) popouts.hasCurrent = true;
        } else if (trayItems && y > ty && y < ty + th) {
            const index = Math.floor(((y - ty) / th) * trayItems.count);
            const item = trayItems.itemAt(index);

            if (item) {
                popouts.currentName = `traymenu${index}`;
                popouts.currentCenter = Qt.binding(() => (tray ? tray.y : 0) + (item ? item.y : 0) + (item ? item.implicitHeight : 0) / 2);
                if (popouts) popouts.hasCurrent = true;
            } else {
                if (popouts) popouts.hasCurrent = false;
            }
        } else if (n && y >= ny && y <= ny + n.implicitHeight + spacing) {
            popouts.currentName = "network";
            popouts.currentCenter = Qt.binding(() => (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (n ? n.y : 0) + (n ? n.implicitHeight : 0) / 2);
            if (popouts) popouts.hasCurrent = true;
        } else if (y >= bls && y <= ble) {
            popouts.currentName = "bluetooth";
            popouts.currentCenter = Qt.binding(() => (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (statusIconsInner ? statusIconsInner.bs : 0) + ((statusIconsInner && statusIconsInner.be && statusIconsInner.bs) ? (statusIconsInner.be - statusIconsInner.bs) : 0) / 2);
            if (popouts) popouts.hasCurrent = true;
        } else if (b && y >= by && y <= by + b.implicitHeight + spacing) {
            popouts.currentName = "battery";
            popouts.currentCenter = Qt.binding(() => (statusIcons ? statusIcons.y : 0) + (statusIconsInner ? statusIconsInner.y : 0) + (b ? b.y : 0) + (b ? b.implicitHeight : 0) / 2);
            if (popouts) popouts.hasCurrent = true;
        } else {
            if (popouts) popouts.hasCurrent = false;
        }
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
            workspaces.implicitWidth || 0,
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
            anchors.topMargin: Appearance.padding.large
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
                    const activeWs = Hyprland.activeClient?.workspace?.name;
                    if (activeWs?.startsWith("special:"))
                        Hyprland.dispatch(`togglespecialworkspace ${activeWs.slice(8)}`);
                    else if (event.angleDelta.y < 0 || Hyprland.activeWsId > 1)
                        Hyprland.dispatch(`workspace r${event.angleDelta.y > 0 ? "-" : "+"}1`);
                }
            }

            Workspaces {
                id: workspacesInner

                anchors.centerIn: parent
            }
        }

        ActiveWindow {
            id: activeWindow

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: workspaces.bottom
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

        StyledRect {
            id: statusIcons

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: power.top
            anchors.bottomMargin: Appearance.spacing.normal

            radius: Appearance.rounding.full
            color: Colours.palette.m3surfaceContainer

            implicitHeight: statusIconsInner.implicitHeight + Appearance.padding.normal * 2

            StatusIcons {
                id: statusIconsInner

                anchors.centerIn: parent
            }
        }

        Power {
            id: power

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Appearance.padding.large
        }
    }
}
