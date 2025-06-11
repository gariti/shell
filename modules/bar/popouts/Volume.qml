import "root:/widgets"  
import "root:/services-niri"
import "root:/config"
import QtQuick

Column {
    id: root
    width: 120
    height: implicitHeight

    spacing: 8

    Text {
        width: parent.width
        text: "Volume"
        font.pointSize: 12
        font.bold: true
        color: "#E5E1E9"
    }

    Text {
        width: parent.width
        text: Audio ? 
              (Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%") :
              "No audio"
        font.pointSize: 10
        color: Audio && Audio.muted ? "#F2B8B5" : "#C9C5D0"
    }

    Rectangle {
        width: 80
        height: 4
        radius: 2
        color: "#48454E"
        
        Rectangle {
            width: Audio ? parent.width * Audio.volume : 0
            height: parent.height
            radius: parent.radius
            color: Audio && Audio.muted ? "#F2B8B5" : "#C8BFFF"
            
            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Text {
        width: parent.width
        text: "Click to toggle mute"
        font.pointSize: 8
        color: "#A8A3AD"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (Audio) {
                    Audio.muted = !Audio.muted
                }
            }
        }
    }
}
