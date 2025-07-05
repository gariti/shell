pragma ComponentBehavior: Bound

import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Io
import QtQuick

Column {
    id: root

    required property PersistentProperties visibilities

    padding: Appearance.padding.large

    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left

    spacing: Appearance.spacing.large

    SessionButton {
        id: logout

        icon: "logout"
        command: ["sh", "-c", "(uwsm stop | grep -q 'Compositor is not running' && loginctl terminate-user $USER) || uwsm stop"]

        KeyNavigation.down: shutdown

        Connections {
            target: root.visibilities

            function onSessionChanged(): void {
                if (root.visibilities.session)
                    logout.focus = true;
            }
        }
    }

    SessionButton {
        id: shutdown

        icon: "power_settings_new"
        command: ["systemctl", "poweroff"]

        KeyNavigation.up: logout
        KeyNavigation.down: hibernate
    }

    AnimatedImage {
        width: SessionConfig.sizes.button
        height: SessionConfig.sizes.button
        sourceSize.width: width
        sourceSize.height: height

        playing: visible
        asynchronous: true
        speed: 0.7
        source: "../../assets/kurukuru.gif"
    }

    SessionButton {
        id: hibernate

        icon: "bedtime"
        command: ["/run/wrappers/bin/sudo", "sh", "-c", "echo freeze > /sys/power/state"]

        KeyNavigation.up: shutdown
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot

        icon: "restart_alt"
        command: ["systemctl", "reboot"]

        KeyNavigation.up: hibernate
    }

    component SessionButton: StyledRect {
        id: button

        required property string icon
        required property list<string> command

        implicitWidth: SessionConfig.sizes.button
        implicitHeight: SessionConfig.sizes.button

        radius: Appearance.rounding.large
        color: button.activeFocus ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainer

        Keys.onEnterPressed: proc.startDetached()
        Keys.onReturnPressed: proc.startDetached()
        Keys.onEscapePressed: root.visibilities.session = false

        Process {
            id: proc

            command: button.command
        }

        StateLayer {
            radius: parent.radius

            function onClicked(): void {
                proc.startDetached();
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.extraLarge
        }
    }
}
