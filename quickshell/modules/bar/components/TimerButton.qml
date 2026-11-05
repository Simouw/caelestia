pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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

    implicitWidth: pill.implicitWidth
    implicitHeight: icon.implicitHeight

    StyledRect {
        id: pill

        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: row.implicitWidth + (TimerService.running ? Tokens.padding.medium : Tokens.padding.small)
        implicitHeight: icon.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full
        color: TimerService.running
            ? Colours.tPalette.m3primaryContainer
            : (root.isPopoutOpen ? Colours.tPalette.m3surfaceContainerHighest : (mouseArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : "transparent"))

        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
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

        RowLayout {
            id: row

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                id: icon

                text: TimerService.running ? "hourglass_top" : "timer"
                color: TimerService.running
                    ? Colours.palette.m3onPrimaryContainer
                    : (root.isPopoutOpen ? Colours.palette.m3primary : Colours.palette.m3onSurface)
                fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
            }

            StyledText {
                visible: TimerService.running
                text: TimerService.formatTime(TimerService.remainingSeconds)
                color: Colours.palette.m3onPrimaryContainer
                font: Tokens.font.label.medium
            }
        }
    }
}
