pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ScreenState screenState

    readonly property int notesIndex: (Config.dashboard.showDashboard ? 1 : 0) + (Config.dashboard.showMedia ? 1 : 0)
    readonly property bool isNotesOpen: screenState.dashboard && screenState.dashboardTab === notesIndex

    implicitWidth: icon.implicitHeight + Tokens.padding.small
    implicitHeight: icon.implicitHeight

    StateLayer {
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full
        onClicked: {
            if (root.isNotesOpen) {
                root.screenState.dashboard = false;
            } else {
                root.screenState.dashboard = true;
                root.screenState.dashboardTab = root.notesIndex;
            }
        }
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "edit_note"
        color: root.isNotesOpen ? Colours.palette.m3primary : Colours.palette.m3tertiary
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
