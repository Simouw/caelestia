import QtQuick
import QtQuick.Layouts
import Caelestia.Models
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    property bool open: false
    property string initialPath: Paths.home
    property string currentPath: Paths.home

    signal accepted(path: string)
    signal cancelled

    visible: open
    z: 1000

    onOpenChanged: {
        if (open)
            currentPath = expand(initialPath || Paths.home);
    }

    function expand(p: string): string {
        return String(p || "").replace(/^~(?=\/|$)/, Paths.home);
    }

    function parentOf(p: string): string {
        const clean = String(p).replace(/\/+$/, "");
        const i = clean.lastIndexOf("/");
        return i <= 0 ? "/" : clean.substring(0, i);
    }

    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3scrim
        opacity: 0.55

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancelled()
        }
    }

    StyledRect {
        anchors.centerIn: parent
        width: Math.min(680, root.width - Tokens.padding.extraLarge * 2)
        height: Math.min(560, root.height - Tokens.padding.extraLarge * 2)
        radius: Tokens.rounding.large

        color: Colours.light ? "#f3eff7" : "#19171d"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.medium

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: "Choose a folder"
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.title.medium
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text
                    padding: Tokens.padding.small
                    onClicked: root.cancelled()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                IconButton {
                    icon: "arrow_upward"
                    type: IconButton.Text
                    padding: Tokens.padding.small
                    enabled: root.currentPath !== "/"
                    onClicked: root.currentPath = root.parentOf(root.currentPath)
                }

                StyledTextField {
                    id: pathField

                    Layout.fillWidth: true
                    text: root.currentPath
                    leadingIcon: "folder_open"
                    onEditingFinished: {
                        if (text.trim() !== "")
                            root.currentPath = text.trim();
                    }

                    Connections {
                        target: root

                        function onCurrentPathChanged() {
                            if (pathField.text !== root.currentPath)
                                pathField.text = root.currentPath;
                        }
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Tokens.rounding.medium
                color: Colours.light ? "#e9e4ef" : "#211e27"

                ListView {
                    id: folderList

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.extraSmall
                    clip: true
                    model: fsm

                    delegate: StyledRect {
                        required property FileSystemEntry modelData

                        width: folderList.width
                        implicitHeight: 34
                        radius: Tokens.rounding.small
                        color: "transparent"

                        StateLayer {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Colours.palette.m3primary
                            onClicked: root.currentPath = modelData.path
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.padding.small
                            anchors.rightMargin: Tokens.padding.small
                            spacing: Tokens.spacing.small

                            MaterialIcon {
                                text: "folder"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.small
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Colours.palette.m3onSurface
                                font: Tokens.font.body.small
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: fsm.entries.length === 0
                    text: "No subfolders."
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: root.currentPath
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.mono.small
                    elide: Text.ElideMiddle
                }

                MiniButton {
                    text: "Cancel"
                    onClicked: root.cancelled()
                }

                MiniButton {
                    text: "Choose this folder"
                    icon: "check"
                    primary: true
                    onClicked: root.accepted(root.currentPath)
                }
            }
        }
    }

    FileSystemModel {
        id: fsm

        path: root.expand(root.currentPath)
        filter: FileSystemModel.Dirs
        showHidden: false
        watchChanges: true
    }
}
