pragma Singleton
pragma ComponentBehavior: Bound

import "../widgets"
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    readonly property list<Notif> list: []
    readonly property list<Notif> popups: list.filter(n => n.popup)
    readonly property int count: list.length // Add count property for the UI

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        // Only try to register if no other notification server is running
        Component.onCompleted: {
            if (!server.running) {
                console.log("Notifs: No existing notification server found, starting our own")
            } else {
                console.log("Notifs: Another notification server is already running, using fallback mode")
            }
        }

        onNotification: notif => {
            console.log("Notifs: Received notification from app:", notif.appName, "summary:", notif.summary, "body:", notif.body)
            
            // Filter out Bluetooth notifications - check for mouse/keyboard connection messages
            const appNameLower = notif.appName.toLowerCase();
            const summaryLower = notif.summary.toLowerCase();
            const bodyLower = notif.body.toLowerCase();
            
            // Log all details to help debug
            console.log("Notifs: App name:", notif.appName);
            console.log("Notifs: Summary:", notif.summary);
            console.log("Notifs: Body:", notif.body);
            
            if (appNameLower === "blueman" || 
                appNameLower === "blueman-applet" ||
                appNameLower === "org.blueman.applet" ||
                appNameLower.includes("bluetooth") ||
                summaryLower.includes("bluetooth") ||
                bodyLower.includes("bluetooth") ||
                summaryLower.includes("device connected") ||
                summaryLower.includes("device disconnected") ||
                bodyLower.includes("device connected") ||
                bodyLower.includes("device disconnected") ||
                summaryLower.includes("connected") ||
                summaryLower.includes("disconnected") ||
                (summaryLower.includes("mouse") && (summaryLower.includes("connected") || summaryLower.includes("disconnected"))) ||
                (summaryLower.includes("keyboard") && (summaryLower.includes("connected") || summaryLower.includes("disconnected"))) ||
                bodyLower.includes("mouse connected") ||
                bodyLower.includes("mouse disconnected") ||
                bodyLower.includes("keyboard connected") ||
                bodyLower.includes("keyboard disconnected") ||
                // Also check for device names
                summaryLower.includes("mx mchncl") ||
                summaryLower.includes("logi pop") ||
                bodyLower.includes("mx mchncl") ||
                bodyLower.includes("logi pop")) {
                console.log("Notifs: Filtering out Bluetooth/device connection notification")
                return;
            }
            
            notif.tracked = true;

            root.list.push(notifComp.createObject(root, {
                popup: true,
                notification: notif
            }));
        }
    }

    CustomShortcut {
        name: "clearNotifs"
        description: "Clear all notifications"
        onPressed: {
            for (const notif of root.list)
                notif.popup = false;
        }
    }

    IpcHandler {
        target: "notifs"

        function clear(): void {
            for (const notif of root.list)
                notif.popup = false;
        }
    }

    component Notif: QtObject {
        id: notif

        property bool popup
        readonly property date time: new Date()
        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        required property Notification notification
        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property var urgency: notification.urgency // Idk why NotificationUrgency doesn't work
        readonly property list<NotificationAction> actions: notification.actions

        readonly property Timer timer: Timer {
            running: true
            interval: notif.notification.expireTimeout > 0 ? notif.notification.expireTimeout : NotifsConfig.defaultExpireTimeout
            onTriggered: {
                if (NotifsConfig.expire)
                    notif.popup = false;
            }
        }

        readonly property Connections conn: Connections {
            target: notif.notification.Retainable

            function onDropped(): void {
                root.list.splice(root.list.indexOf(notif), 1);
            }

            function onAboutToDestroy(): void {
                notif.destroy();
            }
        }
    }

    Component {
        id: notifComp

        Notif {}
    }
}
