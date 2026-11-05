pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property PopoutState popouts

    implicitWidth: 320
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.medium

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "auto_awesome"
                fontStyle: Tokens.font.icon.small
                color: Colours.tPalette.m3primary
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: "Assistants IA"
                    font: Tokens.font.title.small
                    color: Colours.tPalette.m3onSurface
                }

                StyledText {
                    text: {
                        let count = 0;
                        for (let i = 0; i < AiService.tools.length; i++) {
                            if (AiService.tools[i].installed)
                                count++;
                        }
                        return `${count} détecté${count > 1 ? "s" : ""} sur ${AiService.tools.length} CLI`;
                    }
                    font: Tokens.font.label.small
                    color: Colours.tPalette.m3onSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            // Refresh button
            MouseArea {
                implicitWidth: 26
                implicitHeight: 26
                cursorShape: Qt.PointingHandCursor
                onClicked: AiService.scan()

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "refresh"
                    fontStyle: Tokens.font.icon.small
                    color: AiService.scanning ? Colours.tPalette.m3primary : Colours.tPalette.m3onSurfaceVariant
                    rotation: AiService.scanning ? 360 : 0
                    Behavior on rotation {
                        NumberAnimation { duration: 600 }
                    }
                }
            }

            // Close button
            MouseArea {
                implicitWidth: 26
                implicitHeight: 26
                cursorShape: Qt.PointingHandCursor
                onClicked: root.popouts.hasCurrent = false

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "close"
                    fontStyle: Tokens.font.icon.small
                    color: Colours.tPalette.m3onSurfaceVariant
                }
            }
        }

        // Tools List
        Repeater {
            model: AiService.tools

            delegate: StyledRect {
                id: card

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: cardRow.implicitHeight + Tokens.padding.medium * 2
                radius: Tokens.rounding.medium

                color: !modelData.installed
                    ? Colours.tPalette.m3surfaceContainerLowest
                    : (cardArea.containsMouse ? Colours.tPalette.m3surfaceContainerHighest : Colours.tPalette.m3surfaceContainerLow)

                border.color: modelData.installed && cardArea.containsMouse
                    ? Colours.tPalette.m3primary
                    : Colours.tPalette.m3outlineVariant
                border.width: 1

                opacity: modelData.installed ? 1.0 : 0.55

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id: cardArea

                    anchors.fill: parent
                    z: 10
                    hoverEnabled: modelData.installed
                    cursorShape: modelData.installed ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: modelData.installed
                    onClicked: {
                        AiService.launch(modelData.id);
                        root.popouts.hasCurrent = false;
                    }
                }

                RowLayout {
                    id: cardRow

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    spacing: Tokens.spacing.medium

                    // Tool Icon container
                    StyledRect {
                        implicitWidth: 38
                        implicitHeight: 38
                        radius: Tokens.rounding.small
                        color: modelData.installed ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHigh

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: modelData.icon
                            fontStyle: Tokens.font.icon.small
                            color: modelData.installed ? Colours.tPalette.m3onPrimaryContainer : Colours.tPalette.m3onSurfaceVariant
                        }
                    }

                    // Tool Details
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            StyledText {
                                text: modelData.name
                                font: Tokens.font.title.small
                                color: Colours.tPalette.m3onSurface
                            }

                            Item { Layout.fillWidth: true }

                            // Status badge
                            StyledRect {
                                implicitWidth: badgeText.implicitWidth + 12
                                implicitHeight: 20
                                radius: Tokens.rounding.full
                                color: modelData.installed ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHigh

                                StyledText {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: modelData.installed ? "Installé" : "Non installé"
                                    font: Tokens.font.label.small
                                    color: modelData.installed ? Colours.tPalette.m3onPrimaryContainer : Colours.tPalette.m3outline
                                }
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.desc
                            font: Tokens.font.body.small
                            color: Colours.tPalette.m3onSurfaceVariant
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: modelData.installed && modelData.binPath.length > 0
                            Layout.fillWidth: true
                            text: modelData.binPath
                            font.pointSize: 9
                            font.family: "monospace"
                            color: Colours.tPalette.m3outline
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }
        }
    }
}
