import Quickshell
import QtQuick

PersistentProperties {
    id: root

    required property ShellScreen screen

    property list<HorizWrapper> leftDrawers: []
    property list<HorizWrapper> rightDrawers: []
    property list<Item> topDrawers: []
    property list<Item> bottomDrawers: []

    reloadableId: "positions"
}
