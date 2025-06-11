import "root:/services-niri"
import QtQuick

Rectangle {
    color: "red"
    width: 100
    height: 100
    
    Component.onCompleted: {
        console.log("Services test loaded")
        console.log("Hyprland available:", typeof Hyprland)
    }
}
