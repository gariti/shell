import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick

Scope {
    id: root

    required property ShellScreen screen
    readonly property Item content: content
    readonly property Brightness.Monitor monitor: Brightness.getMonitorForScreen(screen)
    property int winHeight
    property bool osdVisible: true
    property bool hovered

    function show(): void {
        root.osdVisible = true;
    // timer.restart();
    }

    Connections {
        target: Audio

        function onMutedChanged(): void {
            root.show();
        }

        function onVolumeChanged(): void {
            root.show();
        }
    }

    Connections {
        target: root.monitor

        function onBrightnessChanged(): void {
            root.show();
        }
    }

    Timer {
        id: timer

        interval: OsdConfig.hideDelay
        onTriggered: {
            if (!root.hovered)
                root.osdVisible = false;
        }
    }

    Connections {
        target: Drawers

        function onPosChanged(screen: ShellScreen, x: int, y: int): void {
            if (screen === root.screen && x > screen.width / 2 && y > (screen.height - root.winHeight) / 2 && y < (screen.height + root.winHeight) / 2)
                root.show();
        }
    }

    // LazyLoader {
    //     loading: true

    Content {
        id: content

        monitor: root.monitor
    }

    // HoverHandler {
    //     id: hoverHandler

    //     onHoveredChanged: {
    //         root.hovered = hovered;
    //         if (hovered)
    //             timer.stop();
    //         else
    //             root.osdVisible = false;
    //     }
    // }
    // }
}
