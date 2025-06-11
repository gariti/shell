pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services-niri"
import "root:/config"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property list<Workspace> workspaces: layout.children.filter(c => c.isWorkspace).sort((w1, w2) => w1.ws - w2.ws)
    readonly property var occupied: ({}) // Niri compatibility: empty occupied object
    readonly property int groupOffset: 0 // Niri compatibility: always start from 0

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

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
        active: BarConfig.workspaces.occupiedBg
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
            if (1 !== ws)
                Hyprland.dispatch(`workspace ${ws}`);
        }
    }
}
