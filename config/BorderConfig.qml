pragma Singleton

import "../services-niri"
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color colour: "#000000"  // Bright red for testing visibility
    readonly property int thickness: 30  // Increase thickness for better visibility
    readonly property int rounding: Appearance.rounding.large
}
