// Active window panel with niri resize controls
import "../../../widgets"
import "../../../services-niri"
import "../../../utils"
import "../../../config"
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth: Hyprland.activeClient ? child.implicitWidth : -Appearance.padding.large * 2
    implicitHeight: child.implicitHeight

    // Debug: Print activeClient status
    Component.onCompleted: {
        console.log("ActiveWindow: Component loaded and ready");
        console.log("ActiveWindow: Hyprland.activeClient:", Hyprland.activeClient);
        console.log("ActiveWindow: Active client title:", Hyprland.activeClient?.title);
        console.log("ActiveWindow: Active client wmClass:", Hyprland.activeClient?.wmClass);
    }

    // Process for executing niri commands
    property Process niriActionProc: Process {
        id: niriActionProc
        
        stdout: SplitParser {
            onRead: function(data) {
                console.log("ActiveWindow: Niri action output:", data);
            }
        }
        
        stderr: SplitParser {
            onRead: function(data) {
                console.log("ActiveWindow: Niri action error:", data);
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                console.log("ActiveWindow: Niri action completed successfully");
            } else {
                console.log("ActiveWindow: Niri action failed with exit code:", exitCode);
            }
        }
    }

    function executeNiriAction(action, parameters) {
        console.log("ActiveWindow: Executing niri action:", action, "with parameters:", parameters || "none");
        
        var command = ["niri", "msg", "action", action];
        if (parameters) {
            command = command.concat(parameters);
        }
        
        niriActionProc.command = command;
        niriActionProc.running = true;
    }

    Column {
        id: child

        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        // Window title and details
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
                    text: Hyprland.activeClient?.title ?? "No active window"
                    font.pointSize: Appearance.font.size.normal
                    elide: Text.ElideRight
                    width: 350
                }

                StyledText {
                    text: Hyprland.activeClient?.wmClass ?? ""
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                    width: 350
                }
            }
        }

        // Window controls panel
        StyledClippingRect {
            width: 380
            height: 300
            color: "transparent"
            radius: Appearance.rounding.small

            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                radius: Appearance.rounding.small
                border.color: "#444444"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width - 40
                    
                    // Size controls
                    Column {
                        width: parent.width
                        spacing: 12
                        
                        // Width controls
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "Width:"
                                color: "#aaaaaa"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 50
                            }
                            
                            IconActionButton {
                                iconText: "remove"
                                width: 30
                                onClicked: executeNiriAction("set-window-width", ["-50"])
                            }
                            
                            ActionButton {
                                text: "25%"
                                width: 45
                                onClicked: executeNiriAction("set-window-width", ["25%"])
                            }
                            
                            ActionButton {
                                text: "50%"
                                width: 45
                                onClicked: executeNiriAction("set-window-width", ["50%"])
                            }
                            
                            ActionButton {
                                text: "75%"
                                width: 45
                                onClicked: executeNiriAction("set-window-width", ["75%"])
                            }

                            ActionButton {
                                text: "100%"
                                onClicked: executeNiriAction("maximize-column")
                            }
                            
                            IconActionButton {
                                iconText: "add"
                                width: 30
                                onClicked: executeNiriAction("set-window-width", ["+50"])
                            }
                        }
                        
                        // Height controls
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "Height:"
                                color: "#aaaaaa"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 50
                            }
                            
                            IconActionButton {
                                iconText: "unfold_less"
                                width: 30
                                onClicked: executeNiriAction("set-window-height", ["-50"])
                            }
                            
                            IconActionButton {
                                iconText: "restart_alt"
                                width: 32
                                onClicked: executeNiriAction("reset-window-height")
                            }
                            
                            IconActionButton {
                                iconText: "unfold_more"
                                width: 30
                                onClicked: executeNiriAction("set-window-height", ["+50"])
                            }
                        }
                        
                        // Movement controls
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "Shift:"
                                color: "#aaaaaa"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 50
                            }
                            
                            IconActionButton {
                                iconText: "keyboard_arrow_left"
                                onClicked: executeNiriAction("move-column-left")
                            }
                            
                            IconActionButton {
                                iconText: "keyboard_arrow_right"
                                onClicked: executeNiriAction("move-column-right")
                            }
                        }
                    }
                    
                    // Layout controls
                    Column {
                        width: parent.width
                        spacing: 12
    
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            ActionButton {
                                text: "Float/Tile"
                                onClicked: executeNiriAction("toggle-window-floating")
                            }
                            
                            ActionButton {
                                text: "Fullscreen"
                                onClicked: executeNiriAction("fullscreen-window")
                            }
                        }
                        
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            

                        
                        }
                    }
                }
            }
        }
    }
    
    // Simple action button component
    component ActionButton: Rectangle {
        property string text: ""
        property string buttonColor: "#2a2a2a"
        signal clicked()
        
        width: text.length > 8 ? 90 : 70
        height: 32
        radius: Appearance.rounding.small
        color: mouseArea.pressed ? Qt.lighter(buttonColor, 1.3) : buttonColor
        border.color: Colours.palette.m3outline
        border.width: 1
        
        StyledText {
            anchors.centerIn: parent
            text: parent.text
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
            font.weight: 500
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: parent.clicked()
            cursorShape: Qt.PointingHandCursor
        }
        
        // Hover effect
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3onSurface
            opacity: mouseArea.containsMouse ? 0.08 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
        
        // Press effect
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3onSurface
            opacity: mouseArea.pressed ? 0.16 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }
    
    // Icon-based action button component
    component IconActionButton: Rectangle {
        property string iconText: ""
        property string buttonColor: "#2a2a2a"
        signal clicked()
        
        width: 32
        height: 32
        radius: Appearance.rounding.small
        color: mouseArea.pressed ? Qt.lighter(buttonColor, 1.3) : buttonColor
        border.color: Colours.palette.m3outline
        border.width: 1
        
        MaterialIcon {
            anchors.centerIn: parent
            text: parent.iconText
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.normal
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: parent.clicked()
            cursorShape: Qt.PointingHandCursor
        }
        
        // Hover effect
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3onSurface
            opacity: mouseArea.containsMouse ? 0.08 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
        
        // Press effect
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3onSurface
            opacity: mouseArea.pressed ? 0.16 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }
}
