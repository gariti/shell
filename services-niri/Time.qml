pragma Singleton

import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds
    
    // Add missing time and date string properties
    readonly property string time: Qt.formatTime(clock.date, "hh:mm")
    readonly property string dateString: Qt.formatDate(clock.date, "dddd, MMM d")

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
