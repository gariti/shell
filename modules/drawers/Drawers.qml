pragma ComponentBehavior: Bound

import "../../widgets"
import "../../services-niri"
import "../../config"
import "../../utils"
import "../bar" as BarModule
import "." // Import components from current directory
import Quickshell
import Quickshell.Wayland
// import Quickshell.Hyprland  // Disabled for Niri compatibility
import QtQuick
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            mask: Region {
                x: bar.implicitWidth
                y: BorderConfig.thickness
                width: win.width - bar.implicitWidth - BorderConfig.thickness
                height: win.height - BorderConfig.thickness * 2
                intersection: Intersection.Xor

                regions: regions.instances
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: regions
                model: [panels.osd, panels.notifications, panels.session, panels.launcher, panels.dashboard, panels.popouts]

                Region {
                    required property Item modelData

                    x: modelData.x + bar.implicitWidth
                    y: modelData.y + BorderConfig.thickness
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

            // HyprlandFocusGrab disabled for Niri compatibility
            // HyprlandFocusGrab {
            //     active: visibilities.launcher || visibilities.session
            //     windows: [win]
            //     onCleared: {
            //         visibilities.launcher = false;
            //         visibilities.session = false;
            //     }
            // }

            StyledRect {
                anchors.fill: parent
                opacity: visibilities.session ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.standard
                    }
                }
            }

            Item {
                id: background

                anchors.fill: parent
                visible: true

                Border {
                    bar: bar
                }

                Backgrounds {
                    panels: panels
                    bar: bar
                }
            }

            // MultiEffect with conservative settings to prevent system freezing
            MultiEffect {
                anchors.fill: source
                source: background
                shadowEnabled: true
                blurMax: 8  // Reduced from 15 to prevent performance issues
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)  // Reduced opacity
                blurEnabled: Colours.transparency.enabled  // Only enable if transparency is enabled
            }

            PersistentProperties {
                id: visibilities

                property bool osd
                property bool session
                property bool launcher
                property bool dashboard

                Component.onCompleted: Visibilities.screens[scope.modelData] = this
            }

            Interactions {
                screen: scope.modelData
                popouts: panels.popouts
                visibilities: visibilities
                panels: panels
                bar: bar
            }

            Panels {
                id: panels

                screen: scope.modelData
                visibilities: visibilities
                bar: bar
            }

            BarModule.Bar {
                id: bar

                screen: scope.modelData
                popouts: panels.popouts
            }
        }
    }
}
