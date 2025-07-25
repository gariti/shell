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

    property color colour: Colours.palette.m3secondary

    readonly property Item network: network
    readonly property real bs: network.y
    readonly property real be: battery.y + battery.implicitHeight
    readonly property Item battery: battery

    clip: true
    implicitWidth: Math.max(network.implicitWidth, battery.implicitWidth)
    implicitHeight: network.implicitHeight + battery.implicitHeight + battery.anchors.topMargin

    MaterialIcon {
        id: network

        animate: true
        text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
        color: root.colour

        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: wifiManager.startDetached()
        }
    }

    Process {
        id: wifiManager
        // Try common WiFi management applications in order of preference
        command: ["sh", "-c", "which nm-connection-editor >/dev/null 2>&1 && nm-connection-editor || which nmtui >/dev/null 2>&1 && alacritty -e nmtui || which iwgtk >/dev/null 2>&1 && iwgtk || which gnome-control-center >/dev/null 2>&1 && gnome-control-center wifi || which systemsettings5 >/dev/null 2>&1 && systemsettings5 kcm_networkmanagement || notify-send 'WiFi Manager' 'No WiFi management application found'"]
    }

    // MaterialIcon {
    //     id: bluetooth

    //     anchors.horizontalCenter: network.horizontalCenter
    //     anchors.top: network.bottom
    //     anchors.topMargin: Appearance.spacing.small

    //     animate: true
    //     text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
    //     color: root.colour

    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: bluetoothManager.startDetached()
    //     }
    // }

    // Process {
    //     id: bluetoothManager
    //     command: ["sh", "-c", "which blueman-manager >/dev/null 2>&1 && blueman-manager || which gnome-control-center >/dev/null 2>&1 && gnome-control-center bluetooth || which systemsettings5 >/dev/null 2>&1 && systemsettings5 kcm_bluetooth || notify-send 'Bluetooth Manager' 'No Bluetooth management application found'"]
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

        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
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

        MouseArea {
            anchors.fill: parent
            onClicked: batteryManager.startDetached()
        }
    }

    Process {
        id: batteryManager
        command: ["sh", "-c", `
            if which gnome-power-manager >/dev/null 2>&1; then
                gnome-power-manager
            elif which gnome-control-center >/dev/null 2>&1; then
                gnome-control-center power
            elif which xfce4-power-manager-settings >/dev/null 2>&1; then
                xfce4-power-manager-settings
            elif which powertop >/dev/null 2>&1; then
                alacritty -e sudo powertop
            else
                # Show battery information in terminal as fallback
                alacritty -e sh -c '
                    echo "=== Battery Information ==="
                    echo
                    if command -v upower >/dev/null 2>&1; then
                        upower -i \$(upower -e | grep "BAT")
                    elif [ -f /sys/class/power_supply/BAT0/capacity ]; then
                        echo "Battery Level: \$(cat /sys/class/power_supply/BAT0/capacity)%"
                        echo "Status: \$(cat /sys/class/power_supply/BAT0/status)"
                        echo "Health: \$(cat /sys/class/power_supply/BAT0/health 2>/dev/null || echo Unknown)"
                    else
                        echo "No battery information available"
                    fi
                    echo
                    echo "=== Power Profile ==="
                    if [ -f /sys/firmware/acpi/platform_profile ]; then
                        echo "Current: \$(cat /sys/firmware/acpi/platform_profile)"
                        echo "Available: \$(cat /sys/firmware/acpi/platform_profile_choices)"
                    else
                        echo "No power profile controls available"
                    fi
                    echo
                    echo "Press Enter to close..."
                    read
                '
            fi
        `]
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
