pragma Singleton

import "../services-niri"
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color colour: "#000000"
    readonly property int thickness: Appearance.padding.normal
    readonly property int rounding: Appearance.rounding.large
}
