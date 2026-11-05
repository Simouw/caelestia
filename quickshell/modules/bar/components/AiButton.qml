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

    readonly property bool isPopoutOpen: root.popouts.hasCurrent && root.popouts.currentName === "ai"

    implicitWidth: icon.implicitHeight + Tokens.padding.small
    implicitHeight: icon.implicitHeight

    StateLayer {
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full

        onClicked: {
            if (root.isPopoutOpen) {
                root.popouts.hasCurrent = false;
                root.popouts.currentName = "";
            } else {
                root.popouts.currentName = "ai";
                root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.bar, 0, root.implicitHeight / 2).y);
                root.popouts.hasCurrent = true;
            }
        }
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent
        text: "auto_awesome"
        color: root.isPopoutOpen ? Colours.palette.m3primary : Colours.palette.m3onSurface
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
