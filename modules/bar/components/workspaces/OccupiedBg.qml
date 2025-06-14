pragma ComponentBehavior: Bound

import "../../../../widgets"
import "../../../../services-niri"
import "../../../../config"
import Quickshell
import QtQuick

Item {
    id: root

    required property list<Workspace> workspaces
    required property var occupied
    required property int groupOffset

    property list<var> pills: []

    onOccupiedChanged: {
        // Early exit if occupiedBg is disabled
        if (BarConfig && BarConfig.workspaces && BarConfig.workspaces.occupiedBg === false) {
            return;
        }
        
        if (!BarConfig || !BarConfig.workspaces || typeof BarConfig.workspaces.shown === 'undefined') {
            console.warn("BarConfig.workspaces.shown is not available yet - skipping OccupiedBg update");
            return;
        }
        
        // Additional safety: only proceed if occupiedBg is enabled
        if (!BarConfig.workspaces.occupiedBg) {
            return;
        }
        
        let count = 0;
        const start = groupOffset;
        const end = start + BarConfig.workspaces.shown;
        for (const [ws, occ] of Object.entries(occupied)) {
            if (ws > start && ws <= end && occ) {
                if (!occupied[ws - 1]) {
                    if (pills[count])
                        pills[count].start = ws;
                    else
                        pills.push(pillComp.createObject(root, {
                            start: ws
                        }));
                    count++;
                }
                if (!occupied[ws + 1])
                    pills[count - 1].end = ws;
            }
        }
        if (pills.length > count)
            pills.splice(count, pills.length - count).forEach(p => p.destroy());
    }

    Repeater {
        model: ScriptModel {
            values: root.pills.filter(p => p)
        }

        StyledRect {
            id: rect

            required property var modelData

            readonly property Workspace start: root.workspaces[modelData.start - 1 - root.groupOffset] ?? null
            readonly property Workspace end: root.workspaces[modelData.end - 1 - root.groupOffset] ?? null

            color: Colours.alpha(Colours.palette.m3surfaceContainerHigh, true)
            radius: BarConfig.workspaces.rounded ? Appearance.rounding.full : 0

            x: start?.x ?? 0
            y: start?.y ?? 0
            implicitWidth: BarConfig.sizes.innerHeight
            implicitHeight: end?.y + end?.height - start?.y

            anchors.horizontalCenter: parent.horizontalCenter

            scale: 0
            Component.onCompleted: scale = 1

            Behavior on scale {
                Anim {
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            Behavior on x {
                Anim {}
            }

            Behavior on y {
                Anim {}
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }

    component Pill: QtObject {
        property int start
        property int end
    }

    Component {
        id: pillComp

        Pill {}
    }
    
    Component.onCompleted: {
        // Log when this component loads (it shouldn't if occupiedBg is false)
        console.warn("OccupiedBg component loaded - occupiedBg setting:", BarConfig?.workspaces?.occupiedBg);
        
        // If this component loaded but shouldn't have, disable it
        if (BarConfig && BarConfig.workspaces && BarConfig.workspaces.occupiedBg === false) {
            root.visible = false;
            console.warn("OccupiedBg component disabled - occupiedBg is set to false");
        }
    }
}
