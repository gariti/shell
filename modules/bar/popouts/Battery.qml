import "root:/widgets"
import "root:/services-niri"
import "root:/config"
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
        text: SystemUsage ? 
              Math.round(SystemUsage.batteryLevel) + "%" +
              (SystemUsage.isCharging ? " (Charging)" : "") :
              "No battery info"
        font.pointSize: 10
        color: SystemUsage && SystemUsage.batteryLevel <= 20 ? "#F2B8B5" : "#C9C5D0"
    }

    Rectangle {
        width: 80
        height: 4
        radius: 2
        color: "#48454E"
        
        Rectangle {
            width: SystemUsage ? parent.width * (SystemUsage.batteryLevel / 100) : 0
            height: parent.height
            radius: parent.radius
            color: SystemUsage && SystemUsage.batteryLevel <= 20 ? "#F2B8B5" : "#C8BFFF"
            
            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Text {
        visible: SystemUsage && SystemUsage.isCharging
        text: "⚡ Charging"
        font.pointSize: 8
        color: "#C8BFFF"
    }
}
