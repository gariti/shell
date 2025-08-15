import "../../../widgets"
import "../../../services-niri"
import "../../../config"
import Quickshell.Io
import QtQuick

Item {
    id: root

    property color colour: getTimeBasedColor()

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    // Function to get dynamic color based on time of day
    function getTimeBasedColor() {
        const now = new Date();
        const hour = now.getHours();
        
        // Morning (6-11): Green/Teal tones
        if (hour >= 6 && hour < 12) {
            return Colours.palette.green;
        }
        // Afternoon (12-17): Yellow/Peach tones  
        else if (hour >= 12 && hour < 18) {
            return Colours.palette.yellow;
        }
        // Evening (18-21): Orange/Red tones
        else if (hour >= 18 && hour < 22) {
            return Colours.palette.peach;
        }
        // Night (22-5): Blue/Purple tones
        else {
            return Colours.palette.lavender;
        }
    }

    // Update color every minute
    Timer {
        interval: 60000 // 1 minute
        running: true
        repeat: true
        onTriggered: {
            const newColor = getTimeBasedColor();
            console.log("Clock: Updating time-based color to:", newColor);
            root.colour = newColor;
        }
    }
    
    // Initialize color on component load
    Component.onCompleted: {
        const initialColor = getTimeBasedColor();
        console.log("Clock: Initial time-based color:", initialColor);
        root.colour = initialColor;
    }

    Column {
        id: column
        spacing: Appearance.spacing.small

        MaterialIcon {
            id: icon

            text: "calendar_month"
            color: root.colour

            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: text

            anchors.horizontalCenter: parent.horizontalCenter

            horizontalAlignment: StyledText.AlignHCenter
            text: Time.format("hh\nmm\nAP")
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.mono
            color: root.colour
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: calendarProcess.startDetached()
    }

    Process {
        id: calendarProcess
        command: ["brave", "--new-window", "https://calendar.google.com"]
    }
}
