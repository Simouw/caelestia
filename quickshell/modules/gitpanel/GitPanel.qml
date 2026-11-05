pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property ScreenState screenState

    implicitWidth: Math.min(1040, (Quickshell.screens.length ? Quickshell.screens[0].width : 1920) - 120)
    implicitHeight: Math.min(620, (Quickshell.screens.length ? Quickshell.screens[0].height : 1080) - 200)

    readonly property var repo: CaelestiaGit.selected
    readonly property bool hasLocal: !!repo && !!repo.localPath
    readonly property var status: CaelestiaGit.status
    readonly property var counts: status && status.counts ? status.counts : { changed: 0, staged: 0, unstaged: 0, untracked: 0 }

    readonly property var filters: [
        { id: "all", label: "All", count: CaelestiaGit.stats.total || 0 },
        { id: "dirty", label: "Modified", count: CaelestiaGit.stats.dirty || 0 },
        { id: "ahead", label: "Ahead", count: CaelestiaGit.stats.ahead || 0 },
        { id: "behind", label: "Behind", count: CaelestiaGit.stats.behind || 0 }
    ]

    Component.onCompleted: {
        CaelestiaGit.ensureFresh();
        CaelestiaGit.selectFirst();
    }

    Connections {
        target: root.screenState

        function onDashboardChanged() {
            if (root.screenState.dashboard && root.screenState.dashboardTab === CaelestiaGit.tabIndex) {
                CaelestiaGit.ensureFresh();
                CaelestiaGit.selectFirst();
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        // =====================================================================
        //  LEFT COLUMN: Repositories List & Filters
        // =====================================================================
        StyledRect {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                spacing: Tokens.spacing.small

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    MaterialIcon {
                        text: "account_tree"
                        color: Colours.tPalette.m3primary
                    }

                    StyledText {
                        text: "Repositories"
                        font: Tokens.font.title.small
                        color: Colours.tPalette.m3onSurface
                    }

                    Item { Layout.fillWidth: true }

                    IconButton {
                        icon: "refresh"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        onClicked: CaelestiaGit.refresh()
                    }
                }

                // Filter chips
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.filters

                        delegate: StyledRect {
                            required property var modelData

                            readonly property bool active: CaelestiaGit.filter === modelData.id
                            implicitHeight: 28
                            implicitWidth: chipRow.implicitWidth + Tokens.padding.small * 2
                            radius: Tokens.rounding.full
                            color: active ? Colours.palette.m3primary : (cArea.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : Colours.tPalette.m3surfaceContainer)

                            MouseArea {
                                id: cArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: CaelestiaGit.filter = modelData.id
                            }

                            RowLayout {
                                id: chipRow
                                anchors.centerIn: parent
                                spacing: 4

                                StyledText {
                                    text: modelData.label
                                    color: active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                                    font: Tokens.font.label.small
                                }

                                StyledText {
                                    text: String(modelData.count)
                                    color: active ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                                    font: Tokens.font.label.small
                                }
                            }
                        }
                    }
                }

                // Search Bar
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.padding.small
                        anchors.rightMargin: Tokens.padding.small
                        spacing: Tokens.spacing.extraSmall

                        MaterialIcon {
                            text: "search"
                            fontStyle: Tokens.font.icon.small
                            color: Colours.tPalette.m3onSurfaceVariant
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: Colours.palette.m3onSurface
                            font.pointSize: 10
                            clip: true
                            onTextChanged: CaelestiaGit.search = text

                            Text {
                                text: "Filter by name..."
                                visible: !searchInput.text
                                color: Colours.palette.m3outline
                                font: searchInput.font
                            }
                        }
                    }
                }

                // Repo List
                ListView {
                    id: repoList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: CaelestiaGit.filtered

                    delegate: RepoRow {
                        modelData: modelData
                        selected: !!root.repo && root.repo.name === modelData.name
                        onActivated: CaelestiaGit.select(modelData)
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: repoList.count === 0
                        text: "No repositories found"
                        color: Colours.palette.m3outline
                    }
                }
            }
        }

        // =====================================================================
        //  RIGHT COLUMN: Fast Repository Status Overview
        // =====================================================================
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            Item {
                anchors.fill: parent
                visible: !root.repo

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "info"
                        fontStyle: Tokens.font.icon.extraLarge
                        color: Colours.tPalette.m3outline
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Select a repository to view status"
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.large
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium
                visible: !!root.repo

                // 1. Repo Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: Tokens.spacing.small

                            StyledText {
                                text: root.repo ? root.repo.name : ""
                                font: Tokens.font.title.medium
                                color: Colours.tPalette.m3onSurface
                            }

                            StateChip {
                                state: root.repo ? root.repo.state : "unknown"
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.repo ? (root.repo.localPath || root.repo.fullName) : ""
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                            elide: Text.ElideMiddle
                        }
                    }

                    // Action buttons
                    RowLayout {
                        spacing: Tokens.spacing.small

                        StyledRect {
                            implicitHeight: 36
                            implicitWidth: openGitxRow.implicitWidth + Tokens.padding.medium * 2
                            radius: Tokens.rounding.full
                            color: Colours.tPalette.m3primary

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: CaelestiaGit.openFullApp()
                            }

                            RowLayout {
                                id: openGitxRow
                                anchors.centerIn: parent
                                spacing: 4

                                MaterialIcon {
                                    text: "open_in_new"
                                    fontStyle: Tokens.font.icon.small
                                    color: Colours.palette.m3onPrimary
                                }

                                StyledText {
                                    text: "Open in GitX"
                                    font: Tokens.font.label.medium
                                    color: Colours.palette.m3onPrimary
                                }
                            }
                        }

                        IconButton {
                            icon: "folder_open"
                            type: IconButton.FilledTonal
                            padding: Tokens.padding.small
                            onClicked: CaelestiaGit.openFolder()
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Colours.tPalette.m3outlineVariant
                }

                // 2. Status Cards Grid
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    // Card: Branch & Sync
                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 100
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.medium
                            spacing: 4

                            RowLayout {
                                MaterialIcon {
                                    text: "branching"
                                    fontStyle: Tokens.font.icon.small
                                    color: Colours.tPalette.m3primary
                                }
                                StyledText {
                                    text: "Active Branch"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                text: root.repo && root.repo.branch ? root.repo.branch : "main"
                                font: Tokens.font.title.small
                                color: Colours.tPalette.m3onSurface
                            }

                            StyledText {
                                text: {
                                    if (!root.repo) return "";
                                    const ahead = root.repo.ahead || 0;
                                    const behind = root.repo.behind || 0;
                                    if (ahead > 0 && behind > 0) return `↑ ${ahead} ahead, ↓ ${behind} behind`;
                                    if (ahead > 0) return `↑ ${ahead} commits ahead of remote`;
                                    if (behind > 0) return `↓ ${behind} commits behind remote`;
                                    return "✓ Synced with remote";
                                }
                                font: Tokens.font.body.small
                                color: (root.repo && (root.repo.ahead || root.repo.behind)) ? Colours.palette.m3tertiary : Colours.palette.m3primary
                            }
                        }
                    }

                    // Card: Working Tree State
                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 100
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.medium
                            spacing: 4

                            RowLayout {
                                MaterialIcon {
                                    text: root.counts.changed > 0 ? "warning" : "check_circle"
                                    fontStyle: Tokens.font.icon.small
                                    color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3primary
                                }
                                StyledText {
                                    text: "Working Tree"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                text: root.counts.changed > 0 ? `${root.counts.changed} modified files` : "Clean working directory"
                                font: Tokens.font.title.small
                                color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3onSurface
                            }

                            StyledText {
                                text: root.counts.changed > 0 ? `${root.counts.staged} staged • ${root.counts.unstaged} unstaged • ${root.counts.untracked} untracked` : "No uncommitted changes"
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }
                }

                // 3. Changed Files Glance (if any)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Tokens.spacing.small

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: root.counts.changed > 0 ? "Changed Files Glance" : "Repository Details"
                            font: Tokens.font.label.large
                            color: Colours.tPalette.m3onSurface
                        }

                        Item { Layout.fillWidth: true }

                        StyledText {
                            visible: root.counts.changed > 0
                            text: "Full diff & staging in GitX"
                            font: Tokens.font.label.small
                            color: Colours.palette.m3outline
                        }
                    }

                    // List of files
                    StyledRect {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        ListView {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.small
                            clip: true
                            spacing: 4
                            visible: root.counts.changed > 0 && root.status && root.status.files && root.status.files.length > 0
                            model: root.status && root.status.files ? root.status.files.slice(0, 50) : []

                            delegate: RowLayout {
                                required property var modelData
                                width: ListView.view.width
                                spacing: Tokens.spacing.small

                                StyledText {
                                    text: modelData.status || "M"
                                    font: Tokens.font.label.small
                                    color: modelData.status === "A" || modelData.status === "?" ? Colours.palette.m3primary : Colours.palette.m3tertiary
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.path || ""
                                    font: Tokens.font.body.medium
                                    color: Colours.palette.m3onSurface
                                    elide: Text.ElideMiddle
                                }
                            }
                        }

                        // Clean state placeholder
                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: root.counts.changed === 0
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                Layout.alignment: Qt.AlignHCenter
                                text: "done_all"
                                fontStyle: Tokens.font.icon.extraLarge
                                color: Colours.palette.m3primary
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Working tree clean"
                                font: Tokens.font.body.large
                                color: Colours.palette.m3onSurface
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No files need staging or committing."
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }
}
