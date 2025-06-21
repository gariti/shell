import "root:/widgets"
import "root:/services-niri"
import "root:/config"
import Quickshell.Services.UPower
import QtQuick

Column {
    id: root

    spacing: 8

    Text {
        text: "Battery"
        font.pointSize: 12
        font.bold: true
        color: "#E5E1E9"
    }

    Text {
        text: UPower.displayDevice ? 
              Math.round(UPower.displayDevice.percentage * 100) + "%" +
              (UPower.displayDevice.charging ? " (Charging)" : "") :
              "No battery info"
        font.pointSize: 10
        color: UPower.displayDevice && UPower.displayDevice.percentage <= 0.2 ? "#F2B8B5" : "#C9C5D0"
    }

    Rectangle {
        width: 80
        height: 4
        radius: 2
        color: "#48454E"
        
        Rectangle {
            width: UPower.displayDevice ? parent.width * UPower.displayDevice.percentage : 0
            height: parent.height
            radius: parent.radius
            color: UPower.displayDevice && UPower.displayDevice.percentage <= 0.2 ? "#F2B8B5" : "#C8BFFF"
            
            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Text {
        visible: UPower.displayDevice && UPower.displayDevice.charging
        text: "⚡ Charging"
        font.pointSize: 8
        color: "#C8BFFF"
    }
}
