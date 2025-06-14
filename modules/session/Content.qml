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

        icon: "🚪"
        command: ["sh", "-c", "(uwsm stop | grep -q 'Compositor is not running' && loginctl terminate-user $USER) || uwsm stop"]

        KeyNavigation.down: lock

        Connections {
            target: root.visibilities

            function onSessionChanged(): void {
                if (root.visibilities.session)
                    logout.focus = true;
            }
        }
    }

    SessionButton {
        id: lock

        icon: "🔒"
        command: ["loginctl", "lock-session"]

        KeyNavigation.up: logout
        KeyNavigation.down: shutdown
    }

    SessionButton {
        id: shutdown

        icon: "⚡"
        command: ["systemctl", "poweroff"]

        KeyNavigation.up: lock
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

        icon: "😴"
        command: ["systemctl", "hibernate"]

        KeyNavigation.up: shutdown
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot

        icon: "🔄"
        command: ["systemctl", "reboot"]

        KeyNavigation.up: hibernate
    }

    component SessionButton: Rectangle {
        id: button

        required property string icon
        required property list<string> command

        implicitWidth: SessionConfig.sizes.button
        implicitHeight: SessionConfig.sizes.button

        // Use transparent background with subtle border
        color: button.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.3)
        border.width: 1
        radius: Appearance.rounding.large

        // Hover effect
        property bool hovered: false
        
        Keys.onEnterPressed: proc.startDetached()
        Keys.onReturnPressed: proc.startDetached()
        Keys.onEscapePressed: root.visibilities.session = false

        Process {
            id: proc

            command: button.command
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            
            onEntered: button.hovered = true
            onExited: button.hovered = false
            onClicked: proc.startDetached()
        }

        Text {
            anchors.centerIn: parent

            text: button.icon
            color: "white"
            font.pointSize: Appearance.font.size.extraLarge
        }
    }
}
