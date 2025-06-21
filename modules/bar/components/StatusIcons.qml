import "root:/widgets"
import "root:/services-niri"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colours.palette.m3secondary

    // readonly property Item network: network
    readonly property real bs: battery.y
    readonly property real be: battery.y + battery.implicitHeight
    readonly property Item battery: battery

    clip: true
    implicitWidth: battery.implicitWidth
    implicitHeight: battery.implicitHeight

    // MaterialIcon {
    //     id: network

    //     animate: true
    //     text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
    //     color: root.colour

    //     anchors.horizontalCenter: parent.horizontalCenter
    // }

    // MaterialIcon {
    //     id: bluetooth

    //     anchors.horizontalCenter: network.horizontalCenter
    //     anchors.top: network.bottom
    //     anchors.topMargin: Appearance.spacing.small

    //     animate: true
    //     text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
    //     color: root.colour
    // }

    // Column {
    //     id: devices

    //     anchors.horizontalCenter: bluetooth.horizontalCenter
    //     anchors.top: bluetooth.bottom
    //     anchors.topMargin: Appearance.spacing.small

    //     Repeater {
    //         id: repeater

    //         model: ScriptModel {
    //             values: Bluetooth.devices.filter(d => d.connected)
    //         }

    //         MaterialIcon {
    //             required property Bluetooth.Device modelData

    //             animate: true
    //             text: Icons.getBluetoothIcon(modelData.icon)
    //             color: root.colour
    //         }
    //     }
    // }

    MaterialIcon {
        id: battery

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
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
