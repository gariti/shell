import "../../../widgets"
import "../../../services-niri"
import "../../../utils"
import "../../../config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colours.palette.m3secondary

    readonly property Item network: network
    readonly property real bs: bluetooth.y
    readonly property real be: bluetooth.y + bluetooth.implicitHeight
    readonly property Item battery: battery

    clip: true
    implicitWidth: Math.max(network.implicitWidth, bluetooth.implicitWidth, battery.implicitWidth)
    implicitHeight: network.implicitHeight + bluetooth.implicitHeight + bluetooth.anchors.topMargin + battery.implicitHeight + battery.anchors.topMargin

    // Simple text-based icons to test if MaterialIcon is the issue
    StyledText {
        id: network

        anchors.horizontalCenter: parent.horizontalCenter
        
        text: Network.active ? "📶" : "📵"
        color: root.colour
        font.pointSize: Appearance.font.size.normal
    }

    StyledText {
        id: bluetooth

        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
        anchors.topMargin: Appearance.spacing.small

        text: Bluetooth.powered ? "🔵" : "⚫"
        color: root.colour
        font.pointSize: Appearance.font.size.normal
    }

    StyledText {
        id: battery

        anchors.horizontalCenter: bluetooth.horizontalCenter
        anchors.top: bluetooth.bottom
        anchors.topMargin: Appearance.spacing.small

        text: {
            if (!UPower.displayDevice.isLaptopBattery) {
                return "🔌";
            }
            const perc = UPower.displayDevice.percentage;
            const charging = !UPower.onBattery;
            if (perc > 0.8) return charging ? "🔋" : "🔋";
            if (perc > 0.5) return charging ? "🔋" : "🔋";
            if (perc > 0.2) return charging ? "🔋" : "🔋";
            return charging ? "🔋" : "🪫";
        }
        color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colours.palette.m3error
        font.pointSize: Appearance.font.size.normal
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }
}
