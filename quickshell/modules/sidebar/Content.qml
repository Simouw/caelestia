import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property ScreenState screenState

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.medium

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            NotifDock {
                objectName: "sidebarNotifications"

                props: root.props
                screenState: root.screenState
            }
        }

        StyledRect {
            Layout.topMargin: Tokens.padding.large - layout.spacing
            Layout.fillWidth: true
            implicitHeight: 1

            color: Colours.tPalette.m3outlineVariant
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.small
            spacing: Tokens.spacing.medium

            StyledRect {
                id: kbSwitchBtn

                Layout.fillWidth: true
                implicitHeight: 44
                radius: Tokens.rounding.medium
                color: kbArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : Colours.tPalette.m3surfaceContainer

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    id: kbArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hypr.dispatch("switchxkblayout all next");
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        text: "keyboard"
                        color: Colours.tPalette.m3primary
                    }

                    StyledText {
                        text: {
                            const desc = Hypr.kbLayoutFull || "";
                            if (desc.toLowerCase().includes("french") || desc.toLowerCase().includes("fr"))
                                return "FR (AZERTY)";
                            if (desc.toLowerCase().includes("english") || desc.toLowerCase().includes("us"))
                                return "US (QWERTY)";
                            return desc.length > 0 ? desc : "FR / US";
                        }
                        font: Tokens.font.label.large
                        color: Colours.tPalette.m3onSurface
                    }

                    MaterialIcon {
                        text: "swap_horiz"
                        color: Colours.tPalette.m3onSurfaceVariant
                    }
                }
            }
        }
    }
}
