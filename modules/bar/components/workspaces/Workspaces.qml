pragma ComponentBehavior: Bound

import "../../../../widgets"
import "../../../../services-niri"
import "../../../../config"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property list<Workspace> workspaces: layout.children.filter(c => c.isWorkspace).sort((w1, w2) => w1.ws - w2.ws)
    readonly property var occupied: Hyprland.occupied // Use enhanced occupancy data from Hyprland service
    readonly property int groupOffset: Math.floor((Hyprland.activeWsId - 1) / BarConfig.workspaces.shown) * BarConfig.workspaces.shown

    // Debug component dimensions
    onImplicitWidthChanged: console.log("Workspaces implicitWidth:", implicitWidth)
    onImplicitHeightChanged: console.log("Workspaces implicitHeight:", implicitHeight)
    
    Component.onCompleted: {
        console.log("Workspaces component completed - Width:", implicitWidth, "Height:", implicitHeight)
        console.log("Workspaces occupied data:", JSON.stringify(occupied))
        console.log("Workspaces activeWsId:", Hyprland.activeWsId)
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Connections {
        target: Hyprland
        function onOccupiedChanged() {
            console.log("Workspaces: occupied changed:", JSON.stringify(Hyprland.occupied));
        }
        function onActiveWsIdChanged() {
            console.log("Workspaces: activeWsId changed:", Hyprland.activeWsId);
        }
    }

    ColumnLayout {
        id: layout

        spacing: 0
        layer.enabled: true
        layer.smooth: true

        Repeater {
            model: BarConfig.workspaces.shown

            Workspace {
                occupied: root.occupied
                groupOffset: root.groupOffset
            }
        }
    }

    Loader {
        active: BarConfig && BarConfig.workspaces && BarConfig.workspaces.occupiedBg
        asynchronous: true

        z: -1
        anchors.fill: parent

        sourceComponent: OccupiedBg {
            workspaces: root.workspaces
            occupied: root.occupied
            groupOffset: root.groupOffset
        }
    }

    Loader {
        active: BarConfig.workspaces.activeIndicator
        asynchronous: true

        sourceComponent: ActiveIndicator {
            workspaces: root.workspaces
            mask: layout
            maskWidth: root.width
            maskHeight: root.height
            groupOffset: root.groupOffset
        }
    }

    MouseArea {
        anchors.fill: parent

        onPressed: event => {
            const ws = layout.childAt(event.x, event.y).index + root.groupOffset + 1;
            if (Hyprland.activeWsId !== ws)
                Hyprland.dispatch(`workspace ${ws}`);
        }
    }
}
