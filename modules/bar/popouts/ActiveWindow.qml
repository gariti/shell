import "../../../widgets"
import "../../../services-niri"
import "../../../utils"
import "../../../config"
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

            IconImage {
                id: icon

                implicitSize: details.implicitHeight
                source: Icons.getAppIcon(Hyprland.activeClient?.wmClass ?? "", "image-missing")
            }

            Column {
                id: details

                StyledText {
                    text: Hyprland.activeClient?.title ?? ""
                    font.pointSize: Appearance.font.size.normal

                    elide: Text.ElideRight
                    width: 300  // Fixed width instead of dynamic calculation
                }

                StyledText {
                    text: Hyprland.activeClient?.wmClass ?? ""
                    color: Colours.palette.m3onSurfaceVariant

                    elide: Text.ElideRight
                    width: 300  // Fixed width instead of dynamic calculation
                }
            }
        }

        StyledClippingRect {
            color: "transparent"
            radius: Appearance.rounding.small

            ScreencopyView {
                id: preview

                captureSource: NiriToplevelManager.findToplevelByNiriWindow(Hyprland.activeClient) ?? null
                live: visible

                constraintSize.width: BarConfig.sizes.windowPreviewSize
                constraintSize.height: BarConfig.sizes.windowPreviewSize

                // Fallback content when screencopy fails or no window is active
                Rectangle {
                    anchors.fill: parent
                    color: Colours.palette.m3surfaceContainer
                    radius: Appearance.rounding.small
                    visible: !preview.hasValidCapture || !Hyprland.activeClient

                    Column {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.normal
                        
                        MaterialIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Icons.getAppCategoryIcon(Hyprland.activeClient?.wmClass ?? "unknown", "apps")
                            color: Colours.palette.m3primary
                            size: 48
                        }
                        
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Window Preview"
                            color: Colours.palette.m3onSurfaceContainer
                            font.pointSize: Appearance.font.size.normal
                            font.bold: true
                        }
                        
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Hyprland.activeClient?.title ?? "No active window"
                            color: Colours.palette.m3onSurfaceContainer
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                            width: BarConfig.sizes.windowPreviewSize - 20
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Hyprland.activeClient?.wmClass ?? "unknown"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }
            }
        }
    }
}
