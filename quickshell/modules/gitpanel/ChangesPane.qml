import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    readonly property var status: CaelestiaGit.status
    readonly property int changedCount: status && status.counts ? status.counts.changed : 0
    readonly property int stagedCount: status && status.counts ? status.counts.staged : 0

    Item {
        id: leftPane

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: Math.min(310, Math.max(255, root.width * 0.4))

        ColumnLayout {
            anchors.fill: parent
            spacing: Tokens.spacing.small

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Tokens.rounding.medium
                color: Colours.tPalette.m3surfaceContainerHigh

                ListView {
                    id: fileList

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.extraSmall
                    clip: true
                    spacing: 0
                    model: CaelestiaGit.changeGroups

                    delegate: Column {
                        id: groupColumn

                        required property var modelData

                        width: fileList.width
                        spacing: 0

                        RowLayout {
                            width: parent.width
                            height: 26
                            spacing: Tokens.spacing.extraSmall

                            StyledText {
                                Layout.leftMargin: Tokens.padding.small
                                Layout.fillWidth: true
                                text: groupColumn.modelData.label + " · " + groupColumn.modelData.files.length
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.label.small
                            }
                        }

                        Repeater {
                            model: groupColumn.modelData.files

                            delegate: FileRow {
                                required property var modelData

                                width: groupColumn.width
                                file: modelData
                                group: groupColumn.modelData.group
                            }
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: CaelestiaGit.changeGroups.length === 0
                    text: "Working tree clean"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }

            StyledTextField {
                id: commitField

                Layout.fillWidth: true
                type: StyledTextField.Filled
                placeholderText: "Commit message…"
                leadingIcon: "edit_note"
                text: CaelestiaGit.commitMessage
                onTextEdited: CaelestiaGit.commitMessage = text
                enabled: !CaelestiaGit.actionBusy

                Connections {
                    target: CaelestiaGit

                    function onCommitMessageChanged() {
                        if (CaelestiaGit.commitMessage === "" && commitField.text !== "")
                            commitField.text = "";
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.extraSmall

                StyledText {
                    Layout.fillWidth: true
                    text: root.stagedCount > 0 ? root.stagedCount + " staged file(s)" : "Nothing staged"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Item {
                        Layout.fillWidth: true
                    }

                    MiniButton {
                        text: "Commit"
                        icon: "check"
                        primary: true
                        enabled: !CaelestiaGit.actionBusy && root.stagedCount > 0 && CaelestiaGit.commitMessage.trim().length > 0
                        onClicked: CaelestiaGit.commit(false)
                    }

                    MiniButton {
                        text: "Push"
                        icon: "upload"
                        enabled: !CaelestiaGit.actionBusy && root.stagedCount > 0 && CaelestiaGit.commitMessage.trim().length > 0
                        onClicked: CaelestiaGit.commit(true)
                    }
                }
            }
        }
    }

    DiffPane {
        id: diffPane

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: leftPane.right
        anchors.right: parent.right
        anchors.leftMargin: Tokens.spacing.medium
        title: CaelestiaGit.diffFile
        patch: CaelestiaGit.diffData ? CaelestiaGit.diffData.patch : ""
        loading: CaelestiaGit.diffLoading
        emptyText: root.changedCount === 0 ? "No pending changes." : "Select a file to see its diff."
    }

    component FileRow: StyledRect {
        id: row

        property var file
        property string group
        readonly property bool selected: CaelestiaGit.diffSelection && CaelestiaGit.diffSelection.path === file.path

        implicitHeight: 30
        color: selected ? Colours.tPalette.m3surfaceContainerHighest : "transparent"
        radius: Tokens.rounding.small

        StateLayer {
            anchors.fill: parent
            radius: row.radius
            color: Colours.palette.m3primary
            onClicked: CaelestiaGit.loadDiff({
                path: row.file.path,
                group: row.group
            })
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.small
            anchors.rightMargin: Tokens.padding.extraSmall
            spacing: Tokens.spacing.extraSmall

            StyledText {
                text: {
                    if (row.file.conflict)
                        return "!";
                    if (row.group === "untracked")
                        return "U";
                    const code = row.file.worktree !== "." ? row.file.worktree : row.file.index;
                    return code === "." ? "M" : code;
                }
                color: row.file.conflict ? Colours.palette.m3error : row.group === "staged" ? Colours.palette.m3primary : Colours.palette.m3tertiary
                font: Tokens.font.mono.small
            }

            StyledText {
                Layout.fillWidth: true
                text: row.file.path
                color: Colours.palette.m3onSurface
                font: Tokens.font.mono.small
                elide: Text.ElideMiddle
            }

            MiniButton {
                visible: row.group !== "conflict"
                icon: row.group === "staged" ? "remove" : "add"
                compact: true
                onClicked: {
                    if (row.group === "staged")
                        CaelestiaGit.unstageFiles([row.file.path]);
                    else
                        CaelestiaGit.stageFiles([row.file.path]);
                }
            }
        }
    }
}
