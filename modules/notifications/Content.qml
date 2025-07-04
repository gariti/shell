import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    readonly property int padding: Appearance.padding.large

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.topMargin: BorderConfig.thickness
    anchors.bottomMargin: BorderConfig.thickness
    anchors.rightMargin: BorderConfig.thickness

    implicitWidth: NotifsConfig.sizes.width + padding * 2
    implicitHeight: {
        const count = list.count;
        if (count === 0)
            return 0;

        let height = (count - 1) * Appearance.spacing.smaller;
        for (let i = 0; i < count; i++)
            height += list.itemAtIndex(i)?.nonAnimHeight ?? 0;

        const screen = QsWindow.window?.screen;
        const visibilities = Visibilities.screens[screen];
        const panel = Visibilities.panels[screen];
        if (visibilities && panel) {
            if (visibilities.osd) {
                const h = panel.osd.y - BorderConfig.rounding * 2;
                if (height > h)
                    height = h;
            }

            if (visibilities.session) {
                const h = panel.session.y - BorderConfig.rounding * 2;
                if (height > h)
                    height = h;
            }
        }

        // Add a substantial padding to ensure the last notification is fully visible
        // Use a much more generous bottom margin calculation
        return Math.min((screen?.height ?? 0) - BorderConfig.thickness * 4, height + padding * 2 + BorderConfig.thickness * 2);
    }

    ClippingWrapperRectangle {
        anchors.fill: parent
        anchors.margins: root.padding
        
        color: "transparent"
        radius: Appearance.rounding.normal

        ListView {
            id: list

            model: ScriptModel {
                values: [...Notifs.popups].reverse()
            }

            anchors.fill: parent
            anchors.bottomMargin: 10 // Increased margin to prevent cutoff

            orientation: Qt.Vertical
            spacing: 0
            cacheBuffer: QsWindow.window?.screen.height ?? 0

            delegate: Item {
                id: wrapper

                required property Notifs.Notif modelData
                required property int index
                readonly property alias nonAnimHeight: notif.nonAnimHeight
                property int idx

                onIndexChanged: {
                    if (index !== -1)
                        idx = index;
                }

                implicitWidth: notif.implicitWidth
                implicitHeight: notif.implicitHeight + (idx === 0 ? 0 : Appearance.spacing.smaller) +
                                (index === list.count-1 ? 8 : 0) // Add moderate padding to the last item

                ListView.onRemove: removeAnim.start()

                // Modified to handle different removal cases
                SequentialAnimation {
                    id: removeAnim

                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: true
                    }
                    PropertyAction {
                        target: wrapper
                        property: "enabled"
                        value: false
                    }
                    PropertyAction {
                        target: wrapper
                        property: "implicitHeight"
                        value: 0
                    }
                    
                    // We can detect dismissal via click by checking if wrapper.modelData.popup is false
                    ScriptAction {
                        script: {
                            // Skip animation when explicitly dismissed via click
                            if (!wrapper.modelData.popup) {
                                wrapper.ListView.delayRemove = false;
                            }
                        }
                    }
                    
                    // This animation will only run for automatic timeouts, not clicks
                    Anim {
                        target: notif
                        property: "opacity"
                        to: 0
                        duration: 50 // Very short duration
                    }
                    
                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: false
                    }
                }

                ClippingRectangle {
                    anchors.top: parent.top
                    anchors.topMargin: wrapper.idx === 0 ? 0 : Appearance.spacing.smaller

                    color: "transparent"
                    radius: notif.radius
                    implicitWidth: notif.implicitWidth
                    implicitHeight: notif.implicitHeight

                    Notification {
                        id: notif

                        modelData: wrapper.modelData
                    }
                }
            }

            // Allow animations for moves when notifications slide in
            move: Transition {
                Anim {
                    property: "y"
                }
            }

            displaced: Transition {
                Anim {
                    property: "y"
                }
            }
        }
    }

    // Restore animation behavior for height changes during slide-in
    Behavior on implicitHeight {
        Anim {}
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.expressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
    }
}
