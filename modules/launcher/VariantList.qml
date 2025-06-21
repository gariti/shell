pragma ComponentBehavior: Bound

import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import QtQuick
import QtQuick.Controls

ListView {
    id: root

    required property int padding
    required property TextField search
    required property PersistentProperties visibilities

    readonly property string query: search.text.slice(LauncherConfig.actionPrefix.length + "variant ".length)
    readonly property int availableWidth: width - 2 * padding
    readonly property int cellWidth: Math.floor(availableWidth / Math.floor(availableWidth / LauncherConfig.sizes.itemWidth))

    model: Variants.fuzzyQuery(query)
    clip: true

    topMargin: padding
    bottomMargin: padding
    leftMargin: padding
    rightMargin: padding

    delegate: ItemDelegate {
        id: delegate

        required property var modelData
        readonly property bool isCurrent: modelData.name === Variants.current

        width: root.cellWidth
        height: LauncherConfig.sizes.itemHeight

        hoverEnabled: true

        background: Rectangle {
            color: {
                if (delegate.isCurrent) return Colours.palette.m3primary;
                if (delegate.hovered) return Colours.palette.m3surfaceContainerHigh;
                return "transparent";
            }
            radius: root.padding

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }

        contentItem: Row {
            spacing: Appearance.spacing.small
            anchors.centerIn: parent

            MaterialIcon {
                text: "colors"
                color: {
                    if (delegate.isCurrent) return Colours.palette.m3onPrimary;
                    return Colours.palette.m3onSurface;
                }
                font.pointSize: Appearance.font.size.large
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: delegate.modelData.name
                color: {
                    if (delegate.isCurrent) return Colours.palette.m3onPrimary;
                    return Colours.palette.m3onSurface;
                }
                font.pointSize: Appearance.font.size.normal
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        onClicked: {
            root.visibilities.launcher = false;
            Variants.setVariant(modelData.name);
        }
    }
}
