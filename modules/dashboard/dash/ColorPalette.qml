import "../../../widgets"
import "../../../services-niri"
import "../../../config"
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    color: Colours.alpha(Colours.palette.m3surfaceContainer, true)
    radius: Appearance.rounding.normal

    implicitWidth: 300
    implicitHeight: content.height + Appearance.padding.large * 2

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        StyledText {
            text: "Color Palette"
            font.pixelSize: Appearance.font.size.larger
            font.weight: Font.Medium
            color: Colours.palette.m3onSurface
        }

        // Material Design 3 Primary Colors
        ColumnLayout {
            spacing: Appearance.spacing.small

            StyledText {
                text: "Material Design 3"
                font.pixelSize: Appearance.font.size.normal
                font.weight: Font.Medium
                color: Colours.palette.m3onSurfaceVariant
            }

            GridLayout {
                columns: 4
                columnSpacing: Appearance.spacing.small
                rowSpacing: Appearance.spacing.small

                ColorSwatch {
                    color: Colours.palette.m3primary
                    name: "Primary"
                }
                ColorSwatch {
                    color: Colours.palette.m3secondary
                    name: "Secondary"
                }
                ColorSwatch {
                    color: Colours.palette.m3tertiary
                    name: "Tertiary"
                }
                ColorSwatch {
                    color: Colours.palette.m3error
                    name: "Error"
                }
                ColorSwatch {
                    color: Colours.palette.m3surface
                    name: "Surface"
                }
                ColorSwatch {
                    color: Colours.palette.m3surfaceVariant
                    name: "Surface Var"
                }
                ColorSwatch {
                    color: Colours.palette.m3outline
                    name: "Outline"
                }
                ColorSwatch {
                    color: Colours.palette.m3surfaceTint
                    name: "Tint"
                }
            }
        }

        // Terminal Colors (Wallust Theme - 16 colors)
        ColumnLayout {
            spacing: Appearance.spacing.small

            StyledText {
                text: "Terminal Colors (Wallust)"
                font.pixelSize: Appearance.font.size.normal
                font.weight: Font.Medium
                color: Colours.palette.m3onSurfaceVariant
            }

            GridLayout {
                columns: 8
                columnSpacing: Appearance.spacing.small
                rowSpacing: Appearance.spacing.small

                ColorSwatch {
                    color: Colours.palette.color0
                    name: "0"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color1
                    name: "1"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color2
                    name: "2"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color3
                    name: "3"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color4
                    name: "4"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color5
                    name: "5"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color6
                    name: "6"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color7
                    name: "7"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color8
                    name: "8"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color9
                    name: "9"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color10
                    name: "10"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color11
                    name: "11"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color12
                    name: "12"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color13
                    name: "13"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color14
                    name: "14"
                    compact: true
                }
                ColorSwatch {
                    color: Colours.palette.color15
                    name: "15"
                    compact: true
                }
            }
        }

        // Palette Actions
        RowLayout {
            spacing: Appearance.spacing.normal

            StyledRect {
                color: Colours.alpha(Colours.palette.m3primaryContainer, true)
                radius: Appearance.rounding.small
                implicitWidth: refreshButton.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: refreshButton.implicitHeight + Appearance.padding.smaller * 2

                StyledText {
                    id: refreshButton
                    anchors.centerIn: parent
                    text: "🎨 New Colors"
                    font.pixelSize: Appearance.font.size.normal
                    color: Colours.palette.m3onPrimaryContainer
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Trigger new wallpaper and color generation
                        const process = Qt.createQmlObject(`
                            import Quickshell.Io
                            Process {
                                command: ["systemctl", "--user", "restart", "wpgtk-restore.service"]
                            }
                        `, root)
                        process.startDetached()
                    }
                }
            }

            StyledText {
                text: "Colors update with wallpaper changes"
                font.pixelSize: Appearance.font.size.small
                color: Colours.palette.m3onSurfaceVariant
                Layout.fillWidth: true
            }
        }
    }

    component ColorSwatch: Item {
        property color color
        property string name
        property bool compact: false

        implicitWidth: compact ? 35 : 60
        implicitHeight: compact ? 35 : 60  // Make height equal to width for perfect circles

        StyledRect {
            id: colorRect
            anchors.fill: parent
            anchors.bottomMargin: compact ? 10 : 15  // Adjust margin for new height
            color: parent.color
            radius: Math.min(width, height) / 2  // Make it perfectly round

            // Add a subtle border for better visibility
            border.width: 1
            border.color: Colours.alpha(Colours.palette.m3outline, false)
        }

        StyledText {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: name
            font.pixelSize: compact ? Appearance.font.size.small - 1 : Appearance.font.size.small
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideMiddle
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors.fill: colorRect
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Copy color to clipboard
                const colorHex = parent.color.toString()
                const process = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["wl-copy", "${colorHex}"]
                    }
                `, parent)
                process.startDetached()
            }
        }

        // Tooltip effect on hover
        Rectangle {
            id: tooltip
            visible: false
            color: Colours.palette.m3inverseSurface
            radius: Appearance.rounding.small
            width: tooltipText.width + Appearance.padding.normal * 2
            height: tooltipText.height + Appearance.padding.smaller * 2
            anchors.bottom: colorRect.top
            anchors.bottomMargin: Appearance.spacing.small
            anchors.horizontalCenter: parent.horizontalCenter
            z: 100

            StyledText {
                id: tooltipText
                anchors.centerIn: parent
                text: `${name}\n${parent.parent.color.toString()}`
                font.pixelSize: Appearance.font.size.small
                color: Colours.palette.m3inverseOnSurface
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: tooltip.visible = true
            onExited: tooltip.visible = false
            onClicked: {
                // Copy color to clipboard
                const colorHex = parent.color.toString()
                const process = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["wl-copy", "${colorHex}"]
                    }
                `, parent)
                process.startDetached()
            }
        }
    }
}