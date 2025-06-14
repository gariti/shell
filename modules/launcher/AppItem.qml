import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property DesktopEntry modelData
    required property PersistentProperties visibilities

    implicitHeight: LauncherConfig.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.full

        function onClicked(): void {
            Apps.launch(root.modelData);
            root.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        Item {
            id: iconContainer

            implicitWidth: parent.height * 0.8
            implicitHeight: parent.height * 0.8
            anchors.verticalCenter: parent.verticalCenter

            IconImage {
                id: icon
                visible: source !== ""
                source: root.modelData?.icon ? Quickshell.iconPath(root.modelData.icon, "") : ""
                implicitSize: parent.width
                anchors.centerIn: parent
            }

            MaterialIcon {
                visible: !icon.visible
                text: "apps"
                color: Colours.palette.m3onSurface
                font.pointSize: Math.max(parent.width * 0.6, 8)
                anchors.centerIn: parent
            }
        }

        Item {
            anchors.left: iconContainer.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: iconContainer.verticalCenter

            implicitWidth: parent.width - iconContainer.width
            implicitHeight: name.implicitHeight + comment.implicitHeight

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                id: comment

                text: (root.modelData?.comment || root.modelData?.genericName || root.modelData?.name) ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.alpha(Colours.palette.m3outline, true)

                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
