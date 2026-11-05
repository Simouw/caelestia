import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        StyledRect {
            Layout.preferredWidth: Math.max(250, root.width * 0.4)
            Layout.fillHeight: true
            radius: Tokens.rounding.medium
            color: Colours.tPalette.m3surfaceContainerLow

            ListView {
                id: commitList

                anchors.fill: parent
                anchors.margins: Tokens.padding.extraSmall
                clip: true
                model: CaelestiaGit.logData

                delegate: StyledRect {
                    required property var modelData

                    width: commitList.width
                    implicitHeight: 46
                    radius: Tokens.rounding.small
                    color: CaelestiaGit.commitDetail && CaelestiaGit.commitDetail.hash === modelData.hash ? Colours.tPalette.m3surfaceContainerHighest : "transparent"

                    StateLayer {
                        anchors.fill: parent
                        radius: parent.radius
                        color: Colours.palette.m3primary
                        onClicked: CaelestiaGit.loadCommitDetail(modelData.hash)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.padding.small
                        anchors.rightMargin: Tokens.padding.small
                        spacing: Tokens.spacing.small

                        StyledText {
                            text: "●"
                            color: Colours.palette.m3primary
                            font: Tokens.font.mono.small
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.subject
                                color: Colours.palette.m3onSurface
                                font: Tokens.font.body.small
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.short + " · " + modelData.author + " · " + modelData.date.substring(0, 10)
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.label.small
                            }
                        }
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                visible: CaelestiaGit.logLoading
                text: "Loading…"
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }

            StyledText {
                anchors.centerIn: parent
                visible: !CaelestiaGit.logLoading && CaelestiaGit.logData.length === 0
                text: "No commits"
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }
        }

        DiffPane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: CaelestiaGit.commitDetail ? CaelestiaGit.commitDetail.short + " — " + CaelestiaGit.commitDetail.subject : "History"
            patch: CaelestiaGit.commitDetail ? CaelestiaGit.commitDetail.patch : ""
            loading: CaelestiaGit.commitLoading
            emptyText: CaelestiaGit.selected && CaelestiaGit.selected.localPath ? "Select a commit." : "Repository not cloned."
        }
    }
}
