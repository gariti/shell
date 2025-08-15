import "root:/widgets"
import "root:/services-niri"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

Item {
    id: root

    property color colour: Colours.palette.sapphire  // Base color, but individual icons override this

    readonly property Item network: network
    readonly property real bs: network.y
    readonly property real be: battery.y + battery.implicitHeight
    readonly property Item battery: battery

    clip: true
    implicitWidth: Math.max(network.implicitWidth, bluetooth.implicitWidth, battery.implicitWidth)
    implicitHeight: network.implicitHeight + bluetooth.implicitHeight + bluetooth.anchors.topMargin + battery.implicitHeight + battery.anchors.topMargin

    MaterialIcon {
        id: network

        animate: true
        text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
        color: Network.active ? Colours.palette.blue : Colours.palette.red

        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: wifiManager.startDetached()
        }
    }

    Process {
        id: wifiManager
        command: ["/etc/nixos/scripts/rofi-wifi-menu.sh"]
    }

    MaterialIcon {
        id: bluetooth

        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
        anchors.topMargin: Appearance.spacing.small

        animate: true
        text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
        color: Bluetooth.powered ? Colours.palette.teal : Colours.palette.maroon

        MouseArea {
            anchors.fill: parent
            onClicked: bluetoothManager.startDetached()
        }
    }

    Process {
        id: bluetoothManager
        command: ["rofi-bluetooth"]
    }

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

        anchors.horizontalCenter: bluetooth.horizontalCenter
        anchors.top: bluetooth.bottom
        anchors.topMargin: Appearance.spacing.small

        animate: true
        
        text: {
            // Ensure icon updates when power profile changes
            const currentProfile = PowerProfiles.profile;
            if (!UPower.displayDevice.isLaptopBattery) {
                if (PowerProfiles.profile === PowerProfile.PowerSaver)
                    return "energy_savings_leaf";
                if (PowerProfiles.profile === PowerProfile.Performance)
                    return "rocket_launch";
                return "balance";
            }

            const perc = UPower.displayDevice.percentage;
            const charging = !UPower.onBattery;
            
            // Power mode specific battery icon sets
            if (PowerProfiles.profile === PowerProfile.PowerSaver) {
                // ECO MODE: Green energy focused icons
                if (charging) {
                    // Eco-charging: show leaf for high battery, plus for charging
                    if (perc >= 0.8) return "energy_savings_leaf";  // High charge = eco leaf
                    if (perc >= 0.6) return "battery_plus";         // Mid charge = battery plus
                    if (perc >= 0.4) return "battery_charging_50";  // Lower levels show charging
                    return "battery_charging_30";
                } else {
                    // Not charging: always show eco leaf to emphasize power saving
                    return "energy_savings_leaf";
                }
            }
            
            if (PowerProfiles.profile === PowerProfile.Performance) {
                // PERFORMANCE MODE: High-power themed icons
                if (charging) {
                    // Performance charging: show power symbols for high performance
                    if (perc >= 0.8) return "flash_on";             // High charge = flash/power
                    if (perc >= 0.6) return "rocket_launch";        // Mid charge = rocket
                    return "battery_charging_full";                 // Low charge = full charging
                } else {
                    // Not charging: show performance symbols based on battery level
                    if (perc >= 0.7) return "rocket_launch";        // High battery = rocket
                    if (perc >= 0.4) return "flash_on";             // Mid battery = flash
                    return "power";                                 // Low battery = power symbol
                }
            }
            
            // BALANCED MODE: Standard battery icons with actual levels
            if (perc === 1)
                return charging ? "battery_charging_full" : "battery_full";
            let level = Math.floor(perc * 7);
            if (charging && (level === 4 || level === 1))
                level--;
            return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
        }
        color: {
            // Color coding for power profiles using wallpaper colors
            if (PowerProfiles.profile === PowerProfile.PowerSaver)
                return Colours.palette.green;       // Green for eco/power saving
            if (PowerProfiles.profile === PowerProfile.Performance)
                return Colours.palette.red;         // Red for high performance
            
            // Dynamic battery level colors
            const perc = UPower.displayDevice.percentage;
            if (perc > 0.8) return Colours.palette.green;      // High battery - green
            if (perc > 0.6) return Colours.palette.yellow;     // Mid-high battery - yellow
            if (perc > 0.4) return Colours.palette.peach;      // Mid battery - peach
            if (perc > 0.2) return Colours.palette.maroon;     // Low battery - maroon
            return Colours.palette.red;                        // Critical battery - red
        }
        fill: 1

        MouseArea {
            anchors.fill: parent
            onClicked: batteryManager.startDetached()
        }
    }

    Process {
        id: batteryManager
        command: ["/etc/nixos/scripts/power-profile-toggle.sh"]
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
