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

    // Debug: Print activeClient status
    Component.onCompleted: {
        console.log("ActiveWindow popout: Component loaded");
        console.log("ActiveWindow popout: Hyprland.activeClient:", Hyprland.activeClient);
        console.log("ActiveWindow popout: Active client title:", Hyprland.activeClient?.title);
        console.log("ActiveWindow popout: Active client wmClass:", Hyprland.activeClient?.wmClass);
    }

    Connections {
        target: Hyprland
        function onActiveClientChanged() {
            console.log("ActiveWindow popout: Active client changed to:", Hyprland.activeClient?.title);
        }
    }

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
            width: 400  // Use hardcoded size temporarily to fix BarConfig issue
            height: 400
            color: "transparent"
            radius: Appearance.rounding.small

            // Alternative window preview since ScreencopyView doesn't work with Niri
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                radius: Appearance.rounding.small
                border.color: "#444444"
                border.width: 2

                // Window preview placeholder with rich content
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    // Large window icon
                    IconImage {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: Icons.getAppIcon(Hyprland.activeClient?.wmClass ?? "", "image-missing")
                        implicitWidth: 64
                        implicitHeight: 64
                    }
                    
                    // Window info card
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.parent.width - 40
                        height: 120
                        color: "#1a1a1a"
                        radius: 8
                        border.color: "#555555"
                        border.width: 1
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            width: parent.width - 20
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Window Preview"
                                color: "#ffffff"
                                font.pointSize: Appearance.font.size.small
                                font.bold: true
                            }
                            
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 20
                                height: 1
                                color: "#444444"
                            }
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Hyprland.activeClient?.title ?? "No active window"
                                color: "#cccccc"
                                font.pointSize: Appearance.font.size.smaller
                                elide: Text.ElideRight
                                width: parent.width - 10
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                            
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: (Hyprland.activeClient?.wmClass ?? "unknown").toUpperCase()
                                color: "#888888"
                                font.pointSize: Appearance.font.size.tiny
                                font.bold: true
                            }
                        }
                    }
                    
                    // Note about preview limitation
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Live preview not available in Niri"
                        color: "#666666"
                        font.pointSize: Appearance.font.size.tiny
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Component.onCompleted: {
                    console.log("Alternative window preview: Loaded for", Hyprland.activeClient?.title);
                }
            }
        }
    }
}
