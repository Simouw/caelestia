pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property PopoutState popouts

    implicitWidth: 240
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.small

        // Header
        RowLayout {
            Layout.fillWidth: true

            MaterialIcon {
                text: "alarm"
                fontStyle: Tokens.font.icon.small
                color: Colours.tPalette.m3primary
            }

            StyledText {
                text: "Minuteur"
                font: Tokens.font.title.small
                color: Colours.tPalette.m3onSurface
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                implicitWidth: 24
                implicitHeight: 24
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

        // Running state controls
        ColumnLayout {
            visible: TimerService.running
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: TimerService.formatTime(TimerService.remainingSeconds)
                font.pointSize: 24
                font.bold: true
                color: Colours.tPalette.m3primary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Tokens.rounding.small
                    color: plusArea.containsMouse ? Colours.tPalette.m3surfaceContainerHighest : Colours.tPalette.m3surfaceContainer

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: plusArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: TimerService.addMinutes(5)
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "+5 min"
                        font: Tokens.font.label.small
                        color: Colours.tPalette.m3onSurface
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Tokens.rounding.small
                    color: stopArea.containsMouse ? Colours.tPalette.m3error : Colours.tPalette.m3errorContainer

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: stopArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: TimerService.stopTimer()
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "Arrêter"
                        font: Tokens.font.label.small
                        color: stopArea.containsMouse ? Colours.tPalette.m3onError : Colours.tPalette.m3onErrorContainer
                    }
                }
            }
        }

        // Presets when inactive
        ColumnLayout {
            visible: !TimerService.running
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: [
                    { label: "5 min (Pause)", sec: 300 },
                    { label: "15 min (Courte pause)", sec: 900 },
                    { label: "25 min (Pomodoro)", sec: 1500 },
                    { label: "50 min (Focus)", sec: 3000 }
                ]

                delegate: StyledRect {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Tokens.rounding.small
                    color: pArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : Colours.tPalette.m3surfaceContainer

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: pArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            TimerService.startTimer(modelData.sec);
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.label
                        font: Tokens.font.label.medium
                        color: Colours.tPalette.m3onSurface
                    }
                }
            }
        }
    }
}
