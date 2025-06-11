pragma Singleton

import "../services-niri"
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color colour: Colours.alpha(Colours.palette.surface, 0.8)  // Proper border color from original design
    readonly property int thickness: 15  // Increase thickness for better visibility
    readonly property int rounding: Appearance.rounding.large
}
