import "root:/config"
import QtQuick

Item {
    id: root

    required property bool shouldBeVisible
    required property Item content

    visible: width > 0
    width: 0

    states: State {
        name: "visible"
        when: root.shouldBeVisible

        PropertyChanges {
            root.width: content.width
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "width"
                duration: Appearance.anim.durations.large
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "width"
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
            }
        }
    ]
}
