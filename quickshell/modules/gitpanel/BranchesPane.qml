import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    property string pendingDelete: ""

    Component.onCompleted: {
        if (CaelestiaGit.selected && CaelestiaGit.selected.localPath && !CaelestiaGit.detail)
            CaelestiaGit.loadDetail();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledTextField {
                id: newBranchField

                Layout.fillWidth: true
                placeholderText: "new-branch"
                leadingIcon: "account_tree"
                onAccepted: {
                    if (text.trim() !== "")
                        CaelestiaGit.createBranch(text.trim());
                }
            }

            MiniButton {
                text: "Create"
                icon: "add"
                enabled: !CaelestiaGit.actionBusy && newBranchField.text.trim() !== ""
                onClicked: {
                    CaelestiaGit.createBranch(newBranchField.text.trim());
                    newBranchField.text = "";
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Tokens.rounding.medium
            color: Colours.tPalette.m3surfaceContainerLow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.small
                spacing: Tokens.spacing.extraSmall

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small
                    StyledText {
                        Layout.leftMargin: Tokens.padding.small
                        text: "Local branches"
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.label.small
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    StyledText {
                        text: CaelestiaGit.branches.locals.length + " branch(es)"
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.label.small
                    }
                }

                ListView {
                    id: branchList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: CaelestiaGit.branches.locals

                    delegate: StyledRect {
                        required property var modelData

                        width: branchList.width
                        implicitHeight: 38
                        radius: Tokens.rounding.small
                        color: modelData.current ? Colours.tPalette.m3surfaceContainerHighest : "transparent"

                        StateLayer {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Colours.palette.m3primary
                            disabled: modelData.current
                            onClicked: CaelestiaGit.checkoutBranch(modelData.name)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.padding.small
                            anchors.rightMargin: Tokens.padding.extraSmall
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: "account_tree"
                                color: modelData.current ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                fontStyle: Tokens.font.icon.small
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Colours.palette.m3onSurface
                                font: Tokens.font.mono.small
                                elide: Text.ElideRight
                            }

                            StyledText {
                                visible: modelData.upstream
                                text: modelData.upstream || ""
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.label.small
                                elide: Text.ElideRight
                                Layout.maximumWidth: 120
                            }

                            StyledText {
                                visible: modelData.current
                                text: "current"
                                color: Colours.palette.m3primary
                                font: Tokens.font.label.small
                            }

                            IconButton {
                                visible: !modelData.current
                                icon: "download"
                                type: IconButton.Text
                                padding: Tokens.padding.extraSmall
                                onClicked: CaelestiaGit.checkoutBranch(modelData.name)
                            }

                            IconButton {
                                visible: !modelData.current
                                icon: "merge_type"
                                type: IconButton.Text
                                padding: Tokens.padding.extraSmall
                                onClicked: CaelestiaGit.mergeBranch(modelData.name)
                            }

                            IconButton {
                                visible: !modelData.current
                                icon: "swap_vert"
                                type: IconButton.Text
                                padding: Tokens.padding.extraSmall
                                onClicked: CaelestiaGit.rebaseBranch(modelData.name)
                            }

                            IconButton {
                                visible: !modelData.current
                                icon: "delete"
                                type: IconButton.Text
                                padding: Tokens.padding.extraSmall
                                onClicked: {
                                    if (root.pendingDelete === modelData.name) {
                                        root.pendingDelete = "";
                                        CaelestiaGit.deleteBranch(modelData.name);
                                    } else {
                                        root.pendingDelete = modelData.name;
                                        CaelestiaGit.notify("Click Delete again to confirm.", "warn");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(160, root.height * 0.28)
            radius: Tokens.rounding.medium
            color: Colours.tPalette.m3surfaceContainerLow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.small
                spacing: Tokens.spacing.extraSmall

                StyledText {
                    Layout.leftMargin: Tokens.padding.small
                    text: "Remote branches"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: CaelestiaGit.branches.remotes

                    delegate: StyledRect {
                        required property var modelData

                        width: ListView.view.width
                        implicitHeight: 28
                        radius: Tokens.rounding.small
                        color: "transparent"

                        StateLayer {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Colours.palette.m3primary
                            onClicked: {
                                const n = modelData.name;
                                const i = n.indexOf("/");
                                CaelestiaGit.checkoutBranch(i >= 0 ? n.substring(i + 1) : n);
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.padding.small
                            anchors.rightMargin: Tokens.padding.small
                            spacing: Tokens.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.mono.small
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        StyledText {
            Layout.leftMargin: Tokens.padding.small
            text: "Tip: Delete requires a second click to confirm."
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.label.small
        }
    }
}
