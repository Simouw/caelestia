pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property var repo
    property bool selected: false
    signal activated()

    readonly property var local: repo ? repo.local : null
    readonly property bool isMissing: !repo || !repo.localPath

    implicitWidth: 280
    implicitHeight: 52
    width: ListView.view ? ListView.view.width : implicitWidth
    clip: true

    StyledRect {
        anchors.fill: parent
        radius: Tokens.rounding.medium
        color: root.selected ? Colours.tPalette.m3surfaceContainerHighest : "transparent"
    }

    StateLayer {
        anchors.fill: parent
        radius: Tokens.rounding.medium
        color: Colours.palette.m3primary
        onClicked: root.activated()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        StyledRect {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 32
            implicitHeight: 32
            radius: Tokens.rounding.small
            color: root.selected ? Colours.palette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHigh

            MaterialIcon {
                anchors.centerIn: parent
                text: root.isMissing ? "cloud_off" : "folder"
                color: root.selected ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    text: root.repo ? (root.repo.name || root.repo.fullName || "Unnamed") : ""
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                }

                StateChip {
                    Layout.alignment: Qt.AlignRight
                    state: root.repo && root.repo.state ? root.repo.state : (root.isMissing ? "missing" : "synced")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    text: {
                        if (!root.repo) return "";
                        const owner = root.repo.owner || "local";
                        const branch = root.local && root.local.branch ? root.local.branch : (root.repo.defaultBranch || "main");
                        return owner + " · " + branch;
                    }
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: !!root.local && ((root.local.ahead || 0) > 0 || (root.local.behind || 0) > 0)
                    text: {
                        if (!root.local) return "";
                        const a = (root.local.ahead || 0) > 0 ? "↑" + root.local.ahead : "";
                        const b = (root.local.behind || 0) > 0 ? "↓" + root.local.behind : "";
                        return (a + " " + b).trim();
                    }
                    color: Colours.palette.m3tertiary
                    font: Tokens.font.mono.small
                }
            }
        }
    }
}
