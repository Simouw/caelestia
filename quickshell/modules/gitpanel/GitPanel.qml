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

    implicitWidth: Math.min(1060, (Quickshell.screens.length ? Quickshell.screens[0].width : 1920) - 100)
    implicitHeight: Math.min(640, (Quickshell.screens.length ? Quickshell.screens[0].height : 1080) - 180)

    readonly property var repo: CaelestiaGit.selected
    readonly property bool hasLocal: !!repo && !!repo.localPath
    readonly property var status: CaelestiaGit.status
    readonly property var counts: status && status.counts ? status.counts : { changed: 0, staged: 0, unstaged: 0, untracked: 0 }

    readonly property var filters: [
        { id: "all", label: "All", count: CaelestiaGit.stats.total || 0 },
        { id: "dirty", label: "Modified", count: CaelestiaGit.stats.dirty || 0 },
        { id: "ahead", label: "Ahead", count: CaelestiaGit.stats.ahead || 0 },
        { id: "behind", label: "Behind", count: CaelestiaGit.stats.behind || 0 },
        { id: "local", label: "Local", count: CaelestiaGit.stats.local || 0 }
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
            Layout.preferredWidth: 350
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
                        fontStyle: Tokens.font.icon.medium
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
                        enabled: !CaelestiaGit.actionBusy
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
                            color: Colours.tPalette.m3onSurfaceVariant
                            fontStyle: Tokens.font.icon.small
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: Colours.palette.m3onSurface
                            font.pointSize: 10
                            clip: true
                            onTextChanged: CaelestiaGit.search = text

                            Text {
                                text: "Search repository..."
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
                    spacing: 4
                    model: CaelestiaGit.filteredRepos

                    delegate: RepoRow {
                        modelData: modelData
                        selected: !!root.repo && !!modelData && (root.repo.id === modelData.id || root.repo.name === modelData.name)
                        onActivated: CaelestiaGit.selectRepo(modelData)
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
        //  RIGHT COLUMN: Status Details, Commits, Push / Pull & GitX
        // =====================================================================
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            // Empty state
            Item {
                anchors.fill: parent
                visible: !root.repo

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "info"
                        color: Colours.tPalette.m3outline
                        fontStyle: Tokens.font.icon.extraLarge
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Select a repository to view status"
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.large
                    }
                }
            }

            // Main details view
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium
                visible: !!root.repo

                // 1. Repo Header & Action Buttons
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

                            StyledText {
                                visible: CaelestiaGit.actionBusy
                                text: CaelestiaGit.actionLabel || "Working…"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3tertiary
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

                    // Push / Pull & App Buttons
                    RowLayout {
                        spacing: Tokens.spacing.small

                        IconButton {
                            icon: "download"
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal && !CaelestiaGit.actionBusy
                            onClicked: CaelestiaGit.pullSelected()
                        }

                        IconButton {
                            icon: "upload"
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal && !CaelestiaGit.actionBusy
                            onClicked: CaelestiaGit.pushSelected()
                        }

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
                                    color: Colours.palette.m3onPrimary
                                    fontStyle: Tokens.font.icon.small
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
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal
                            onClicked: CaelestiaGit.openFolder()
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Colours.tPalette.m3outlineVariant
                }

                // 2. Status Summary Cards
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    // Branch & Sync Card
                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 92
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.medium
                            spacing: 4

                            RowLayout {
                                MaterialIcon {
                                    text: "account_tree"
                                    color: Colours.tPalette.m3primary
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Branch & Remote Status"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                text: root.repo && (root.repo.branch || root.repo.local?.branch) ? (root.repo.branch || root.repo.local?.branch) : "main"
                                font: Tokens.font.title.small
                                color: Colours.tPalette.m3onSurface
                            }

                            StyledText {
                                text: {
                                    if (!root.repo) return "";
                                    const ahead = root.repo.local?.ahead || root.repo.ahead || 0;
                                    const behind = root.repo.local?.behind || root.repo.behind || 0;
                                    if (ahead > 0 && behind > 0) return `↑ ${ahead} to push, ↓ ${behind} to pull (Diverged)`;
                                    if (ahead > 0) return `↑ ${ahead} commits ahead of remote (Need to Push)`;
                                    if (behind > 0) return `↓ ${behind} commits behind remote (Need to Pull)`;
                                    return "✓ Up to date with remote";
                                }
                                font: Tokens.font.body.small
                                color: (root.repo && (root.repo.ahead || root.repo.behind || root.repo.local?.ahead || root.repo.local?.behind)) ? Colours.palette.m3tertiary : Colours.palette.m3primary
                            }
                        }
                    }

                    // Working Tree Card
                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 92
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.medium
                            spacing: 4

                            RowLayout {
                                MaterialIcon {
                                    text: root.counts.changed > 0 ? "warning" : "check_circle"
                                    color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3primary
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Working Tree Status"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                text: root.counts.changed > 0 ? `${root.counts.changed} modified files (Need to Commit)` : "Working tree clean"
                                font: Tokens.font.title.small
                                color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3onSurface
                            }

                            StyledText {
                                text: root.counts.changed > 0 ? `${root.counts.staged} staged • ${root.counts.unstaged} unstaged • ${root.counts.untracked} untracked` : "Everything is committed"
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }
                }

                // 3. Quick Commit Bar (When files are modified)
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer
                    visible: root.counts.changed > 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.padding.medium
                        anchors.rightMargin: Tokens.padding.medium
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: "edit"
                            color: Colours.palette.m3tertiary
                            fontStyle: Tokens.font.icon.small
                        }

                        TextInput {
                            id: commitMsgInput
                            Layout.fillWidth: true
                            color: Colours.palette.m3onSurface
                            font.pointSize: 10
                            clip: true
                            text: CaelestiaGit.commitMessage
                            onTextChanged: CaelestiaGit.commitMessage = text

                            Text {
                                text: "Write commit message…"
                                visible: !commitMsgInput.text
                                color: Colours.palette.m3outline
                                font: commitMsgInput.font
                            }
                        }

                        StyledRect {
                            implicitHeight: 32
                            implicitWidth: commitOnlyRow.implicitWidth + Tokens.padding.small * 2
                            radius: Tokens.rounding.small
                            color: Colours.tPalette.m3secondaryContainer

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: !CaelestiaGit.actionBusy
                                onClicked: CaelestiaGit.commit(false)
                            }

                            RowLayout {
                                id: commitOnlyRow
                                anchors.centerIn: parent
                                spacing: 4

                                MaterialIcon {
                                    text: "check"
                                    color: Colours.palette.m3onSecondaryContainer
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Commit"
                                    font: Tokens.font.label.small
                                    color: Colours.palette.m3onSecondaryContainer
                                }
                            }
                        }

                        StyledRect {
                            implicitHeight: 32
                            implicitWidth: commitPushRow.implicitWidth + Tokens.padding.small * 2
                            radius: Tokens.rounding.small
                            color: Colours.tPalette.m3primary

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: !CaelestiaGit.actionBusy
                                onClicked: CaelestiaGit.commit(true)
                            }

                            RowLayout {
                                id: commitPushRow
                                anchors.centerIn: parent
                                spacing: 4

                                MaterialIcon {
                                    text: "arrow_upward"
                                    color: Colours.palette.m3onPrimary
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Commit & Push"
                                    font: Tokens.font.label.small
                                    color: Colours.palette.m3onPrimary
                                }
                            }
                        }
                    }
                }

                // 4. Changed Files / Repository Files Glance
                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer

                    // If modified: show list of modified files
                    ListView {
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
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

                    // If clean: show ready state
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.counts.changed === 0
                        spacing: Tokens.spacing.extraSmall

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "verified"
                            color: Colours.palette.m3primary
                            fontStyle: Tokens.font.icon.extraLarge
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Working tree is clean"
                            font: Tokens.font.body.large
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No modified files. Ready to push or work."
                            font: Tokens.font.body.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }
        }
    }
}
