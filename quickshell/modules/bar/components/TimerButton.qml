pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property ScreenState screenState
    required property Item bar
    required property BarPopouts.Wrapper popouts

    readonly property bool isPopoutOpen: root.popouts.hasCurrent && root.popouts.currentName === "timer"
    readonly property real progress: (TimerService.totalSeconds > 0)
        ? Math.min(1.0, Math.max(0.0, 1.0 - (TimerService.remainingSeconds / TimerService.totalSeconds)))
        : 0
    readonly property real handAngle: progress * 360

    implicitWidth: 32
    implicitHeight: 32

    StateLayer {
        anchors.fill: parent
        radius: Tokens.rounding.full
        color: TimerService.ringing
            ? Colours.tPalette.m3errorContainer
            : (TimerService.running ? Colours.tPalette.m3primaryContainer : "transparent")

        onClicked: {
            if (TimerService.ringing) {
                TimerService.stopRinging();
                return;
            }

            if (root.isPopoutOpen) {
                root.popouts.hasCurrent = false;
                root.popouts.currentName = "";
            } else {
                root.popouts.currentName = "timer";
                root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.bar, 0, root.implicitHeight / 2).y);
                root.popouts.hasCurrent = true;
            }
        }
    }

    Item {
        id: dialGroup

        anchors.centerIn: parent
        width: 26
        height: 26

        // Idle state: subtle timer icon
        MaterialIcon {
            anchors.centerIn: parent
            visible: !TimerService.running && !TimerService.ringing
            text: "timer"
            color: root.isPopoutOpen ? Colours.palette.m3primary : Colours.palette.m3onSurface
            fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
        }

        // Ringing state: animated shaking bell
        MaterialIcon {
            anchors.centerIn: parent
            visible: TimerService.ringing
            text: "notifications_active"
            color: Colours.palette.m3error
            fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
        }

        // Running state: circular analog clock face with rotating progress hand
        Item {
            anchors.fill: parent
            visible: TimerService.running && !TimerService.ringing

            // Dial ring
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colours.tPalette.m3surfaceContainerHigh
                border.width: 1.5
                border.color: Colours.palette.m3primary
            }

            // Dial hour / cardinal tick marks (12, 3, 6, 9)
            Repeater {
                model: 4

                Item {
                    required property int index
                    anchors.centerIn: parent
                    width: 2
                    height: 22
                    rotation: index * 90

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 1.5
                        height: 2.5
                        radius: 0.5
                        color: Colours.palette.m3onSurfaceVariant
                        opacity: 0.6
                    }
                }
            }

            // Rotating Clock Hand (needle)
            Item {
                anchors.centerIn: parent
                width: 2
                height: 18
                rotation: root.handAngle

                Behavior on rotation {
                    RotationAnimation {
                        duration: 250
                        direction: RotationAnimation.Clockwise
                    }
                }

                // Needle pointing from center towards 12 o'clock
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 2
                    height: 7
                    radius: 1
                    color: Colours.palette.m3primary
                }
            }

            // Center pivot cap
            Rectangle {
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: Colours.palette.m3primary
            }
        }
    }

    // Shaking / Tremble animation when ringing
    SequentialAnimation {
        id: ringWiggleAnim

        running: TimerService.ringing
        loops: Animation.Infinite

        NumberAnimation { target: dialGroup; property: "rotation"; to: 18; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: -18; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: 14; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: -14; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: 8; duration: 35; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: -8; duration: 35; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dialGroup; property: "rotation"; to: 0; duration: 30; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 100 }
    }
}
