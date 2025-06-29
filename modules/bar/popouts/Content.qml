pragma ComponentBehavior: Bound

import "root:/services-niri"
import "root:/config"
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    required property ShellScreen screen

    property string currentName
    property real currentCenter
    property bool hasCurrent
    property bool mouseInContent: false  // Track if mouse is in the popout content

    anchors.centerIn: parent

    implicitWidth: hasCurrent ? (content.children.find(c => c.shouldBeActive)?.implicitWidth ?? 0) + Appearance.padding.large * 2 : 0
    implicitHeight: (content.children.find(c => c.shouldBeActive)?.implicitHeight ?? 0) + Appearance.padding.large * 2

    // MouseArea to keep popout open when hovering over child elements
    MouseArea {
        anchors.fill: parent
        anchors.margins: -20 // Extend beyond the content area
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Don't handle any clicks
        
        // Keep the popout open while hovering anywhere in this area
        onContainsMouseChanged: {
            root.mouseInContent = containsMouse;
            console.log("Content mouse changed:", containsMouse);
        }
    }

    Item {
        id: content

        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        clip: true

        Popout {
            name: "activewindow"
            source: "PortalActiveWindow.qml"  // Use portal-based implementation
        }
        
        // Keep the old implementation available as fallback
        Popout {
            name: "activewindow-legacy"
            source: "ActiveWindow.qml"
        }

        Popout {
            name: "volume"
            source: "Volume.qml"
        }

        Popout {
            name: "network"
            source: "Network.qml"
        }

        Popout {
            name: "bluetooth"
            source: "Bluetooth.qml"
        }

        Popout {
            name: "battery"
            source: "Battery.qml"
        }

        Repeater {
            model: ScriptModel {
                values: [...SystemTray.items.values]
            }

            Popout {
                id: trayMenu

                required property SystemTrayItem modelData
                required property int index

                name: `traymenu${index}`
                sourceComponent: trayMenuComp

                Connections {
                    target: root

                    function onHasCurrentChanged(): void {
                        if (root.hasCurrent && trayMenu.shouldBeActive) {
                            trayMenu.sourceComponent = null;
                            trayMenu.sourceComponent = trayMenuComp;
                        }
                    }
                }

                Component {
                    id: trayMenuComp

                    TrayMenu {
                        popouts: root
                        trayItem: trayMenu.modelData.menu
                    }
                }
            }
        }
    }

    Behavior on implicitWidth {
        Anim {
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        enabled: root.implicitWidth > 0

        Anim {
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on currentCenter {
        enabled: root.implicitWidth > 0

        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    component Popout: Loader {
        id: popout

        required property string name
        property bool shouldBeActive: root.currentName === name

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        opacity: 0
        scale: 0.8
        active: false
        asynchronous: true

        states: State {
            name: "active"
            when: popout.shouldBeActive

            PropertyChanges {
                popout.active: true
                popout.opacity: 1
                popout.scale: 1
            }
        }

        transitions: [
            Transition {
                from: "active"
                to: ""

                SequentialAnimation {
                    Anim {
                        properties: "opacity,scale"
                        duration: Appearance.anim.durations.small
                    }
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                }
            },
            Transition {
                from: ""
                to: "active"

                SequentialAnimation {
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                    Anim {
                        properties: "opacity,scale"
                    }
                }
            }
        ]
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
