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
    
    // Set minimum dimensions to prevent tiny icon rendering warnings
    implicitWidth: Math.max(
        Math.max(network.implicitWidth, bluetooth.implicitWidth, battery.implicitWidth),
        32  // Minimum panel width
    )
    implicitHeight: Math.max(
        network.implicitHeight + bluetooth.implicitHeight + bluetooth.anchors.topMargin + 
        battery.implicitHeight + battery.anchors.topMargin,
        80  // Minimum panel height
    )

    MaterialIcon {
        id: network

        animate: true
        text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
        color: root.colour

        anchors.horizontalCenter: parent.horizontalCenter
    }

    MaterialIcon {
        id: bluetooth

        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
        anchors.topMargin: Appearance.spacing.small

        animate: true
        text: {
            if (!Bluetooth.powered) return "bluetooth_disabled";
            const connectedDevices = Bluetooth.devices.filter(d => d.connected);
            if (connectedDevices.length === 0) return "bluetooth";
            if (connectedDevices.length === 1) return Icons.getBluetoothIcon(connectedDevices[0].icon);
            return "bluetooth_connected"; // Multiple devices connected
        }
        color: root.colour
    }

    // Remove the separate devices column to prevent duplicate icons
    Item {
        id: devices
        // Empty item to maintain layout references but not show duplicate icons
    }

    MaterialIcon {
        id: battery

        anchors.horizontalCenter: bluetooth.horizontalCenter
        anchors.top: bluetooth.bottom
        anchors.topMargin: Appearance.spacing.small

        animate: true
        text: {
            if (!UPower.displayDevice.isLaptopBattery) {
                if (PowerProfiles.profile === PowerProfile.PowerSaver)
                    return "energy_savings_leaf";
                if (PowerProfiles.profile === PowerProfile.Performance)
                    return "rocket_launch";
                return "balance";
            }

            const perc = UPower.displayDevice.percentage;
            const charging = !UPower.onBattery;
            if (perc === 1)
                return charging ? "battery_charging_full" : "battery_full";
            let level = Math.floor(perc * 7);
            if (charging && (level === 4 || level === 1))
                level--;
            return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
        }
        color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colours.palette.m3error
        fill: 1
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
