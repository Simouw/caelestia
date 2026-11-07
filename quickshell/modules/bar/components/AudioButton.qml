pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property ScreenState screenState
    required property Item bar
    required property BarPopouts.Wrapper popouts

    readonly property bool isPopoutOpen: root.popouts.hasCurrent && root.popouts.currentName === "audio"

    implicitWidth: 32
    implicitHeight: 32

    StateLayer {
        anchors.fill: parent
        radius: Tokens.rounding.full
        color: root.isPopoutOpen
            ? Colours.tPalette.m3primaryContainer
            : (mouseArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : "transparent")

        Behavior on color { ColorAnimation { duration: 150 } }

        onClicked: {
            if (root.isPopoutOpen) {
                root.popouts.hasCurrent = false;
                root.popouts.currentName = "";
            } else {
                root.popouts.currentName = "audio";
                root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.bar, 0, root.implicitHeight / 2).y);
                root.popouts.hasCurrent = true;
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor

        onWheel: event => {
            const step = Config.services.audioIncrement;
            if (event.angleDelta.y > 0)
                Audio.setVolume(Math.min(1.5, Audio.volume + step));
            else if (event.angleDelta.y < 0)
                Audio.setVolume(Math.max(0, Audio.volume - step));
        }
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent
        animate: true
        text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
        color: Audio.muted
            ? Colours.palette.m3error
            : (root.isPopoutOpen ? Colours.palette.m3primary : Colours.palette.m3onSurface)
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
