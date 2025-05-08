import "root:/widgets"
import "root:/config"
import "../osd"
import Quickshell

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        readonly property Positions positions: Positions {
            screen: scope.modelData
            rightDrawers: [osd]
        }

        Exclusions {
            screen: scope.modelData
        }

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            exclusionMode: ExclusionMode.Ignore

            mask: Region {
                x: BorderConfig.thickness
                y: BorderConfig.thickness
                width: scope.modelData.width - BorderConfig.thickness * 2
                height: scope.modelData.height - BorderConfig.thickness * 2
                intersection: Intersection.Xor
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Backgrounds {
                id: backgrounds

                positions: scope.positions
                visible: false
            }

            LayerShadow {
                source: backgrounds
            }

            Interactions {
                screen: scope.modelData
            }

            HorizWrapper {
                id: osd

                shouldBeVisible: true
                content: content.content

                Osd {
                    id: content

                    screen: scope.modelData
                }
            }
        }
    }
}
