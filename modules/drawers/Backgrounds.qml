pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/config"
import QtQuick

Item {
    id: root

    required property Positions positions

    anchors.fill: parent

    Border {}

    Repeater {
        model: root.positions.rightDrawers

        RightBackground {
            required property HorizWrapper modelData
            required property int index

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: root.positions.rightDrawers.slice(0, index).reduce((a, b) => a + b.width, 0)

            wrapper: modelData
        }
    }
}
