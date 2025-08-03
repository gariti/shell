import "../../config"
import "../../utils"
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    required property ShellScreen screen

    // Only show launcher on preferred display
    readonly property bool shouldShowLauncher: DisplayManager.getPreferredLauncherScreen() === screen

    // DEBUG: Force launcher to show on all screens for testing
    visible: height > 0 // && shouldShowLauncher
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    states: State {
        name: "visible"
        when: root.visibilities.launcher

        PropertyChanges {
            root.implicitHeight: content.implicitHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Content {
        id: content

        visibilities: root.visibilities
    }
    
    // Monitor launcher visibility and ensure focus
    Connections {
        target: root.visibilities
        
        function onLauncherChanged(): void {
            if (root.visibilities.launcher && root.shouldShowLauncher) {
                // Try to activate the window
                Qt.callLater(() => {
                    const window = root.parent;
                    if (window && window.requestActivate) {
                        window.requestActivate();
                    }
                    // Also ensure content focus
                    content.search.forceActiveFocus();
                });
            }
        }
    }
}
