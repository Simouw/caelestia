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

    implicitWidth: row.implicitWidth + Tokens.padding.small * 2
    implicitHeight: 22

    radius: Tokens.rounding.full
    color: palette.bg

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Tokens.spacing.extraSmall

        StyledRect {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 5
            implicitHeight: 5
            radius: Tokens.rounding.full
            color: root.palette.dot
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: root.label || labelFor(root.state)
            color: root.palette.fg
            font: Tokens.font.label.small
        }
    }

    function labelFor(state: string): string {
        switch (state) {
        case "synced":
            return "Up to date";
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
