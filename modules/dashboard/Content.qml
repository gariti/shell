import "../../widgets"
import "../../services-niri"
import "../../config"
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property real nonAnimWidth: view.implicitWidth + viewWrapper.anchors.margins * 2
    property bool mouseInContent: false  // Track if mouse is in the Dashboard content

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    implicitWidth: nonAnimWidth
    implicitHeight: tabs.implicitHeight + tabs.anchors.topMargin + view.implicitHeight + viewWrapper.anchors.margins * 2

    // MouseArea to keep Dashboard open when hovering over child elements
    MouseArea {
        id: contentMouseArea
        anchors.fill: parent
        anchors.margins: -20 // Extend beyond the content area
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Don't handle any clicks
        
        // Timer to prevent flickering when changing tabs
        Timer {
            id: mouseContentStabilizer
            interval: 300 // Short delay
            onTriggered: {
                // Only update mouseInContent if the mouse is truly not in the content area
                if (!contentMouseArea.containsMouse) {
                    root.mouseInContent = false;
                    console.log("Dashboard content mouse exited (confirmed):", false);
                }
            }
        }
        
        // Keep the Dashboard open while hovering anywhere in this area
        onContainsMouseChanged: {
            if (containsMouse) {
                // Immediately update when mouse enters
                mouseContentStabilizer.stop();
                root.mouseInContent = true;
                console.log("Dashboard content mouse entered:", true);
            } else {
                // Delay update when mouse leaves to handle tab changes
                mouseContentStabilizer.restart();
            }
        }
    }

    // Handle tab changes properly
    Connections {
        target: tabs.bar
        function onCurrentIndexChanged() {
            console.log("Tab changed in dashboard - ensuring content stays open");
            // Reset mouseInContent to true during tab changes to prevent unwanted closing
            mouseContentStabilizer.stop(); // Stop any pending timers
            root.mouseInContent = true;
        }
    }

    Tabs {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.padding.normal
        anchors.margins: Appearance.padding.large

        nonAnimWidth: root.nonAnimWidth
        currentIndex: view.currentIndex
    }

    ClippingRectangle {
        id: viewWrapper

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.padding.large

        radius: Appearance.rounding.normal
        color: "transparent"

        Flickable {
            id: view

            readonly property int currentIndex: tabs.currentIndex
            readonly property Item currentItem: row.children[currentIndex]

            anchors.fill: parent

            flickableDirection: Flickable.HorizontalFlick

            implicitWidth: currentItem.implicitWidth
            implicitHeight: currentItem.implicitHeight

            contentX: currentItem.x
            contentWidth: row.implicitWidth
            contentHeight: row.implicitHeight

            onContentXChanged: {
                if (!moving)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 2)
                    tabs.bar.incrementCurrentIndex();
                else if (x < -currentItem.implicitWidth / 2)
                    tabs.bar.decrementCurrentIndex();
            }

            onDragEnded: {
                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 10)
                    tabs.bar.incrementCurrentIndex();
                else if (x < -currentItem.implicitWidth / 10)
                    tabs.bar.decrementCurrentIndex();
                else
                    contentX = Qt.binding(() => currentItem.x);
            }

            Row {
                id: row

                Dash {
                    shouldUpdate: visible && this === view.currentItem
                }

                Media {
                    shouldUpdate: visible && this === view.currentItem
                    visibilities: root.visibilities
                }

                Performance {}
            }

            Behavior on contentX {
                NumberAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }
}
