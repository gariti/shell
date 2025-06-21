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

    readonly property string query: search.text.slice(LauncherConfig.actionPrefix.length + "transparency ".length)
    readonly property int availableWidth: width - 2 * padding
    readonly property int cellWidth: Math.floor(availableWidth / Math.floor(availableWidth / LauncherConfig.sizes.itemWidth))

    // Create a model with transparency levels
    readonly property var transparencyLevels: [
        { name: "Opaque", value: 1.0, desc: "No transparency" },
        { name: "Light", value: 0.95, desc: "Slightly transparent" },
        { name: "Medium", value: 0.85, desc: "Moderately transparent" },
        { name: "Heavy", value: 0.75, desc: "Very transparent" }
    ]

    model: transparencyLevels.filter(item => 
        query === "" || 
        item.name.toLowerCase().includes(query.toLowerCase()) ||
        item.desc.toLowerCase().includes(query.toLowerCase())
    )
    clip: true

    topMargin: padding
    bottomMargin: padding
    leftMargin: padding
    rightMargin: padding

    delegate: ItemDelegate {
        id: delegate

        required property var modelData
        readonly property bool isCurrent: Math.abs(modelData.value - Transparency.current) < 0.01

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

        contentItem: Column {
            spacing: Appearance.spacing.tiny
            anchors.centerIn: parent

            Row {
                spacing: Appearance.spacing.small
                anchors.horizontalCenter: parent.horizontalCenter

                MaterialIcon {
                    text: "opacity"
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

            StyledText {
                text: delegate.modelData.desc
                color: {
                    if (delegate.isCurrent) return Colours.palette.m3onPrimary;
                    return Colours.palette.m3onSurfaceVariant;
                }
                font.pointSize: Appearance.font.size.tiny
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        onClicked: {
            root.visibilities.launcher = false;
            Transparency.setTransparency(modelData.value);
        }
    }
}
