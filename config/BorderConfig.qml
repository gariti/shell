pragma Singleton

import "../services-niri"
import Quickshell
import QtQuick

Singleton {
    id: root

    // Use exact same color as panel for perfect consistency
    readonly property color colour: "#000000"  // OLED black - matches panel exactly
    readonly property int thickness: Appearance.padding.normal
    readonly property int rounding: Appearance.rounding.large
}
