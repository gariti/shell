import "../config"
import "../services-niri"
import Quickshell
import QtQuick

Rectangle {
    id: root
    
    anchors.fill: parent
    color: Colours.palette.m3background
    
    Image {
        id: wallpaperImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: Wallpapers.current || ""
        asynchronous: true
        cache: false
        
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: wallpaperImage.status === Image.Ready ? 0 : 1
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
