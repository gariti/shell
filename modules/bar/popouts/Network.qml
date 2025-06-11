import "root:/widgets"
import "root:/services-niri"
import "root:/config"
import QtQuick

Column {
    id: root

    spacing: 8

    Text {
        text: "Network"
        font.pointSize: 12
        font.bold: true
        color: "#E5E1E9"
    }

    Text {
        text: Network && Network.active ? 
              "Connected to: " + (Network.active.ssid || "Unknown") :
              "Not connected"
        font.pointSize: 10
        color: "#C9C5D0"
        wrapMode: Text.WordWrap
        width: parent.width
    }

    Text {
        visible: Network && Network.active
        text: Network && Network.active ? 
              "Signal: " + (Network.active.strength || 0) + "%" :
              ""
        font.pointSize: 9
        color: "#A8A3AD"
    }
}
