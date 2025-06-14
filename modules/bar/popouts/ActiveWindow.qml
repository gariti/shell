import "root:/widgets"
import                IconImage {
                    id: icon
                    visible: source !== ""
                    source: {
                        const wmClass = Hyprland.activeClient?.wmClass ?? "";
                        return wmClass ? Icons.getAppIcon(wmClass, "") : "";
                    }
                    implicitSize: iconContainer.implicitSize
                    anchors.centerIn: parent
                }rvices-niri"
import "root:/utils"
import "root:/config"
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick

Item {
    id: root

    implicitWidth: Hyprland.activeClient ? child.implicitWidth : -Appearance.padding.large * 2
    implicitHeight: child.implicitHeight

    Column {
        id: child

        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        Row {
            id: detailsRow

            spacing: Appearance.spacing.normal

            Item {
                id: iconContainer
                implicitSize: details.implicitHeight

                IconImage {
                    id: icon
                    visible: source !== ""
                    source: {
                        const wmClass = Hyprland.activeClient?.wmClass ?? "";
                        return wmClass ? Icons.getAppIcon(wmClass, "") : "";
                    }
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

            Column {
                id: details

                StyledText {
                    text: Hyprland.activeClient?.title ?? ""
                    font.pointSize: Appearance.font.size.normal

                    elide: Text.ElideRight
                    width: preview.implicitWidth - icon.implicitWidth - detailsRow.spacing
                }

                StyledText {
                    text: Hyprland.activeClient?.wmClass ?? ""
                    color: Colours.palette.m3onSurfaceVariant

                    elide: Text.ElideRight
                    width: preview.implicitWidth - icon.implicitWidth - detailsRow.spacing
                }
            }
        }

        ClippingWrapperRectangle {
            color: "transparent"
            radius: Appearance.rounding.small

            ScreencopyView {
                id: preview

                captureSource: NiriToplevelManager.findToplevelByNiriWindow(NiriToplevelManager.focusedWindow) ?? null
                live: visible

                constraintSize.width: BarConfig.sizes.windowPreviewSize
                constraintSize.height: BarConfig.sizes.windowPreviewSize
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.emphasized
    }
}
