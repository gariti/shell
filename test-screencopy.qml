import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            screen: modelData
            anchors {
                left: true
                top: true
            }
            
            width: 600
            height: 400
            
            Rectangle {
                anchors.fill: parent
                color: "#2d2d2d"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ScreencopyView Test"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 24
                    }
                    
                    Rectangle {
                        width: 400
                        height: 300
                        color: "black"
                        border.color: "white"
                        border.width: 2
                        
                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: "Initializing ScreencopyView..."
                            color: "yellow"
                            font.bold: true
                        }
                        
                        ScreencopyView {
                            id: screencopyView
                            anchors.fill: parent
                            
                            Component.onCompleted: {
                                console.log("ScreencopyView component created successfully");
                                statusText.text = "ScreencopyView created!";
                                statusText.color = "green";
                            }
                        }
                    }
                }
            }
        }
    }
}
