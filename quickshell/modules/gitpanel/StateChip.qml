import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property string state
    property string label: ""

    readonly property var palette: {
        switch (state) {
        case "synced":
            return { bg: Colours.palette.m3secondaryContainer, fg: Colours.palette.m3onSecondaryContainer, dot: Colours.palette.m3primary };
        case "behind":
        case "dirty":
            return { bg: Colours.palette.m3tertiaryContainer, fg: Colours.palette.m3onTertiaryContainer, dot: Colours.palette.m3tertiary };
        case "ahead":
            return { bg: Colours.palette.m3primaryContainer, fg: Colours.palette.m3onPrimaryContainer, dot: Colours.palette.m3primary };
        case "diverged":
            return { bg: Colours.palette.m3secondaryContainer, fg: Colours.palette.m3onSecondaryContainer, dot: Colours.palette.m3secondary };
        case "conflicted":
        case "operation":
            return { bg: Colours.palette.m3errorContainer, fg: Colours.palette.m3onErrorContainer, dot: Colours.palette.m3error };
        default:
            return { bg: Colours.tPalette.m3surfaceContainerHigh, fg: Colours.palette.m3onSurfaceVariant, dot: Colours.palette.m3outline };
        }
    }

    implicitWidth: chipRow.implicitWidth + 14
    implicitHeight: 20
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: implicitWidth
    radius: Tokens.rounding.full
    color: palette.bg

    RowLayout {
        id: chipRow
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 4

        StyledRect {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 6
            implicitHeight: 6
            radius: Tokens.rounding.full
            color: root.palette.dot
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: false
            text: root.label || root.labelFor(root.state)
            color: root.palette.fg
            font: Tokens.font.label.small
        }
    }

    function labelFor(state: string): string {
        switch (state) {
        case "synced":
            return "Clean";
        case "behind":
            return "Behind";
        case "ahead":
            return "Ahead";
        case "diverged":
            return "Diverged";
        case "dirty":
            return "Modified";
        case "conflicted":
            return "Conflict";
        case "operation":
            return "Operation";
        case "missing":
            return "Not cloned";
        default:
            return "External";
        }
    }
}
