import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    property string icon: ""
    property string text: ""
    property bool primary: false
    property bool active: false
    property bool compact: false
    signal clicked

    implicitWidth: content.implicitWidth + (compact ? Tokens.padding.small : Tokens.padding.medium) * 2
    implicitHeight: compact ? 26 : 32

    radius: Tokens.rounding.full
    color: active || primary ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer
    opacity: enabled ? 1 : 0.45

    StateLayer {
        anchors.fill: parent
        radius: root.radius
        color: root.active || root.primary ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
        disabled: !root.enabled
        onClicked: root.clicked()
    }

    RowLayout {
        id: content

        anchors.centerIn: parent
        spacing: Tokens.spacing.extraSmall

        MaterialIcon {
            visible: root.icon !== ""
            text: root.icon
            color: root.active || root.primary ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
            fontStyle: Tokens.font.icon.small
        }

        StyledText {
            visible: root.text !== ""
            text: root.text
            color: root.active || root.primary ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
            font: Tokens.font.label.medium
        }
    }
}
