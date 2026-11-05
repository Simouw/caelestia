pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ScreenState screenState

    property int remainingSeconds: 0
    property int totalSeconds: 0
    property bool running: false
    property bool popupOpen: false

    function formatTime(sec: int): string {
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return `${m < 10 ? "0" : ""}${m}:${s < 10 ? "0" : ""}${s}`;
    }

    function startTimer(seconds: int): void {
        root.totalSeconds = seconds;
        root.remainingSeconds = seconds;
        root.running = true;
        root.popupOpen = false;
        countdownTimer.restart();
    }

    function stopTimer(): void {
        root.running = false;
        root.remainingSeconds = 0;
        root.totalSeconds = 0;
        countdownTimer.stop();
    }

    function togglePause(): void {
        root.running = !root.running;
        if (root.running)
            countdownTimer.restart();
        else
            countdownTimer.stop();
    }

    function addMinutes(min: int): void {
        root.remainingSeconds += min * 60;
        root.totalSeconds += min * 60;
    }

    function onTimerFinished(): void {
        root.running = false;
        root.remainingSeconds = 0;
        notifyProc.command = [
            "notify-send",
            "-u", "critical",
            "-a", "Caelestia",
            "-i", "alarm",
            "⏰ Minuteur terminé !",
            "Le temps imparti pour votre session est écoulé."
        ];
        notifyProc.running = true;

        soundProc.command = ["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"];
        soundProc.running = true;
    }

    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.remainingSeconds > 1) {
                root.remainingSeconds--;
            } else {
                root.onTimerFinished();
            }
        }
    }

    Process {
        id: notifyProc
    }

    Process {
        id: soundProc
    }

    implicitWidth: pill.implicitWidth
    implicitHeight: icon.implicitHeight

    StyledRect {
        id: pill

        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: row.implicitWidth + (root.running ? Tokens.padding.medium : Tokens.padding.small)
        implicitHeight: icon.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full
        color: root.running ? Colours.tPalette.m3primaryContainer : (mouseArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : "transparent")

        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.popupOpen = !root.popupOpen
        }

        RowLayout {
            id: row

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                id: icon

                text: root.running ? "hourglass_top" : "timer"
                color: root.running ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3primary
                fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
            }

            StyledText {
                visible: root.running
                text: root.formatTime(root.remainingSeconds)
                color: Colours.palette.m3onPrimaryContainer
                font: Tokens.font.label.medium
            }
        }
    }

    // Popup for presets & controls
    StyledRect {
        id: popup

        visible: root.popupOpen
        z: 999
        anchors.top: parent.bottom
        anchors.topMargin: Tokens.spacing.small
        anchors.left: parent.left
        anchors.leftMargin: -20

        implicitWidth: 200
        implicitHeight: popupLayout.implicitHeight + Tokens.padding.medium * 2
        radius: Tokens.rounding.medium
        color: Colours.tPalette.m3surfaceContainerHighest
        border.color: Colours.tPalette.m3outlineVariant
        border.width: 1

        ColumnLayout {
            id: popupLayout

            anchors.fill: parent
            anchors.margins: Tokens.padding.medium
            spacing: Tokens.spacing.small

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
                    implicitWidth: 20
                    implicitHeight: 20
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.popupOpen = false

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
                visible: root.running
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.formatTime(root.remainingSeconds)
                    font.pointSize: 22
                    color: Colours.tPalette.m3primary
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: Tokens.rounding.small
                        color: Colours.tPalette.m3surfaceContainer

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addMinutes(5)
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
                        implicitHeight: 30
                        radius: Tokens.rounding.small
                        color: Colours.tPalette.m3errorContainer

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stopTimer()
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: "Arrêter"
                            font: Tokens.font.label.small
                            color: Colours.tPalette.m3onErrorContainer
                        }
                    }
                }
            }

            // Presets when inactive
            ColumnLayout {
                visible: !root.running
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
                        implicitHeight: 32
                        radius: Tokens.rounding.small
                        color: pArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : Colours.tPalette.m3surfaceContainer

                        Behavior on color { ColorAnimation { duration: 100 } }

                        MouseArea {
                            id: pArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.startTimer(modelData.sec)
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
}
