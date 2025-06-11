pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color colour: "#141318" // Default dark surface color
    readonly property int thickness: 10 // Default padding
    readonly property int rounding: 25 // Default large rounding
}
