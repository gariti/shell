import "../config"
import "../services-niri"
import Quickshell
import QtQuick

Rectangle {
    id: root
    
    anchors.fill: parent
    color: Colours.palette.m3background
    
    property string currentSource: Wallpapers.current || ""
    property string nextSource: ""
    
    onCurrentSourceChanged: {
        if (currentSource !== "") {
            console.log("Wallpaper: Starting transition to", currentSource)
            nextSource = currentSource
            nextImage.source = nextSource
        }
    }
    
    // Current wallpaper (visible)
    Image {
        id: currentImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: 1
    }
    
    // Next wallpaper (for transition)
    Image {
        id: nextImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: 0
        
        onStatusChanged: {
            if (status === Image.Ready && source !== "") {
                console.log("Wallpaper: New image ready, starting fade transition")
                crossFadeAnimation.start()
            }
        }
    }
    
    // Cross-fade animation
    ParallelAnimation {
        id: crossFadeAnimation
        
        NumberAnimation {
            target: currentImage
            property: "opacity"
            to: 0
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        
        NumberAnimation {
            target: nextImage
            property: "opacity"
            to: 1
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        
        onFinished: {
            console.log("Wallpaper: Transition complete, swapping images")
            // Swap the images
            currentImage.source = nextImage.source
            currentImage.opacity = 1
            nextImage.opacity = 0
            nextImage.source = ""
        }
    }
    
    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: (currentImage.status !== Image.Ready && nextImage.status !== Image.Ready) ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
}
