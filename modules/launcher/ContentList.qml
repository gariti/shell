pragma ComponentBehavior: Bound

import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property PersistentProperties visibilities
    required property TextField search
    required property int padding
    required property int rounding

    property bool showWallpapers: search.text.startsWith(`${LauncherConfig.actionPrefix}wallpaper `)
    property bool showSchemes: search.text.startsWith(`${LauncherConfig.actionPrefix}scheme `)
    property bool showVariants: search.text.startsWith(`${LauncherConfig.actionPrefix}variant `)
    property bool showTransparency: search.text.startsWith(`${LauncherConfig.actionPrefix}transparency `)
    
    property var currentList: (showWallpapers ? wallpaperList : appList).item

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    clip: true
    state: showWallpapers ? "wallpapers" : "apps"

    states: [
        State {
            name: "apps"

            PropertyChanges {
                root.implicitWidth: LauncherConfig.sizes.itemWidth
                root.implicitHeight: Math.max(empty.height, appList.height)
                appList.active: true
            }

            AnchorChanges {
                anchors.left: root.parent.left
                anchors.right: root.parent.right
            }
        },
        State {
            name: "wallpapers"

            PropertyChanges {
                root.implicitWidth: Math.max(LauncherConfig.sizes.itemWidth, wallpaperList.width)
                root.implicitHeight: LauncherConfig.sizes.wallpaperHeight
                wallpaperList.active: true
            }
        },
        State {
            name: "schemes"

            PropertyChanges {
                root.implicitWidth: LauncherConfig.sizes.itemWidth
                root.implicitHeight: Math.max(empty.height, schemeList.height)
                schemeList.active: true
            }

            AnchorChanges {
                anchors.left: root.parent.left
                anchors.right: root.parent.right
            }
        },
        State {
            name: "variants"

            PropertyChanges {
                root.implicitWidth: LauncherConfig.sizes.itemWidth
                root.implicitHeight: Math.max(empty.height, variantList.height)
                variantList.active: true
            }

            AnchorChanges {
                anchors.left: root.parent.left
                anchors.right: root.parent.right
            }
        },
        State {
            name: "transparency"

            PropertyChanges {
                root.implicitWidth: LauncherConfig.sizes.itemWidth
                root.implicitHeight: Math.max(empty.height, transparencyList.height)
                transparencyList.active: true
            }

            AnchorChanges {
                anchors.left: root.parent.left
                anchors.right: root.parent.right
            }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                from: 1
                to: 0
                duration: Appearance.anim.durations.small
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
            PropertyAction {
                targets: [appList, wallpaperList]
                properties: "active"
            }
            ParallelAnimation {
                NumberAnimation {
                    target: root
                    properties: "implicitWidth,implicitHeight"
                    duration: Appearance.anim.durations.large
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
                NumberAnimation {
                    target: root
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Appearance.anim.durations.large
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }
    }

    Loader {
        id: appList

        active: false
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: AppList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Loader {
        id: wallpaperList

        active: false
        asynchronous: true

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        sourceComponent: WallpaperList {
            search: root.search
            visibilities: root.visibilities
        }
    }

    Loader {
        id: schemeList

        active: false
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: SchemeList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Loader {
        id: variantList

        active: false
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: VariantList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Loader {
        id: transparencyList

        active: false
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: TransparencyList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Item {
        id: empty

        opacity: root.currentList?.count === 0 ? 1 : 0
        scale: root.currentList?.count === 0 ? 1 : 0.5

        implicitWidth: icon.width + text.width + Appearance.spacing.small
        implicitHeight: icon.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        MaterialIcon {
            id: icon

            text: "manage_search"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.extraLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: text

            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("No results")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }
}
