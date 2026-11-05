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

    implicitWidth: Math.min(1040, (Quickshell.screens.length ? Quickshell.screens[0].width : 1920) - 80)
    implicitHeight: Math.min(620, (Quickshell.screens.length ? Quickshell.screens[0].height : 1080) - 160)
    width: implicitWidth
    height: implicitHeight

    readonly property var repo: CaelestiaGit.selected
    readonly property bool hasLocal: !!repo && !!repo.localPath
    readonly property var status: CaelestiaGit.status
    readonly property var counts: status && status.counts ? status.counts : (repo && repo.local && repo.local.counts ? repo.local.counts : { changed: 0, staged: 0, unstaged: 0, untracked: 0 })

    readonly property var filters: [
        { id: "all", label: "All", count: CaelestiaGit.stats.total || 0 },
        { id: "dirty", label: "Modified", count: CaelestiaGit.stats.dirty || 0 },
        { id: "ahead", label: "Ahead", count: CaelestiaGit.stats.ahead || 0 },
        { id: "behind", label: "Behind", count: CaelestiaGit.stats.behind || 0 },
        { id: "synced", label: "Clean", count: CaelestiaGit.stats.synced || 0 }
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
        //  LEFT COLUMN: Repositories List & Manual Scanner
        // =====================================================================
        StyledRect {
            Layout.preferredWidth: 310
            Layout.minimumWidth: 310
            Layout.maximumWidth: 310
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: Tokens.spacing.small

                // Header with "Scan" button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        text: "account_tree"
                        color: Colours.tPalette.m3primary
                        fontStyle: Tokens.font.icon.small
                    }

                    StyledText {
                        text: "Git Projects"
                        font: Tokens.font.title.small
                        color: Colours.tPalette.m3onSurface
                    }

                    Item { Layout.fillWidth: true }

                    // Explicit Scan Button (Only scans on user click)
                    StyledRect {
                        implicitHeight: 28
                        implicitWidth: scanBtnRow.implicitWidth + 14
                        radius: Tokens.rounding.full
                        color: CaelestiaGit.scanning ? Colours.palette.m3tertiaryContainer : Colours.palette.m3primaryContainer

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !CaelestiaGit.scanning && !CaelestiaGit.actionBusy
                            onClicked: CaelestiaGit.scanPc()
                        }

                        RowLayout {
                            id: scanBtnRow
                            anchors.centerIn: parent
                            spacing: 4

                            MaterialIcon {
                                text: CaelestiaGit.scanning ? "sync" : "travel_explore"
                                color: CaelestiaGit.scanning ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3onPrimaryContainer
                                fontStyle: Tokens.font.icon.small

                                RotationAnimation on rotation {
                                    running: CaelestiaGit.scanning
                                    from: 0
                                    to: 360
                                    loops: Animation.Infinite
                                    duration: 1000
                                }
                            }

                            StyledText {
                                text: CaelestiaGit.scanning ? "Scan…" : "Scan"
                                font: Tokens.font.label.small
                                color: CaelestiaGit.scanning ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3onPrimaryContainer
                            }
                        }
                    }
                }

                // Filter chips with Flow (Wraps neatly across lines, never overflows!)
                Flow {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.filters

                        delegate: StyledRect {
                            required property var modelData

                            readonly property bool active: CaelestiaGit.filter === modelData.id
                            implicitHeight: 24
                            implicitWidth: chipRow.implicitWidth + 12
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
                    implicitHeight: 32
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
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
                        required property var modelData
                        width: repoList.width
                        repo: modelData
                        selected: !!root.repo && (root.repo.id === modelData.id || root.repo.name === modelData.name || (root.repo.localPath && root.repo.localPath === modelData.localPath))
                        onActivated: CaelestiaGit.selectRepo(modelData)
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: repoList.count === 0
                        text: "No repositories found\nClick 'Scan' to search PC"
                        color: Colours.palette.m3outline
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // =====================================================================
        //  RIGHT COLUMN: Read-Only Status Monitor & Project Overview
        // =====================================================================
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow
            clip: true

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
                anchors.margins: Tokens.padding.medium
                spacing: Tokens.spacing.small
                visible: !!root.repo

                // 1. Repo Header & Action Icons (With preferredWidth: 0 to prevent overflowing!)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.small

                            StyledText {
                                text: root.repo ? (root.repo.name || root.repo.fullName || "") : ""
                                font: Tokens.font.title.medium
                                color: Colours.tPalette.m3onSurface
                                elide: Text.ElideRight
                            }

                            // Branch Pill
                            StyledRect {
                                implicitHeight: 22
                                implicitWidth: branchRow.implicitWidth + 10
                                radius: Tokens.rounding.small
                                color: Colours.tPalette.m3surfaceContainerHigh

                                RowLayout {
                                    id: branchRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    MaterialIcon {
                                        text: "fork_right"
                                        color: Colours.palette.m3primary
                                        fontStyle: Tokens.font.icon.small
                                    }

                                    StyledText {
                                        text: root.repo && (root.repo.branch || root.repo.local?.branch) ? (root.repo.branch || root.repo.local?.branch) : (root.repo?.defaultBranch || "main")
                                        font: Tokens.font.label.small
                                        color: Colours.palette.m3onSurface
                                    }
                                }
                            }

                            StateChip {
                                state: root.repo && root.repo.state ? root.repo.state : "synced"
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Path / Remote display (elides nicely in the middle)
                        StyledText {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            text: {
                                if (!root.repo) return "";
                                const p = root.repo.localPath || "";
                                const r = root.repo.local?.remoteUrl || root.repo.cloneUrl || "";
                                return p + (r ? " • " + r : "");
                            }
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.mono.small
                            elide: Text.ElideMiddle
                        }
                    }

                    // Navigation Actions (Compact and right-aligned)
                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.fillWidth: false
                        spacing: 4

                        IconButton {
                            icon: "content_copy"
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal
                            onClicked: CaelestiaGit.copy(root.repo ? root.repo.localPath : "")
                        }

                        IconButton {
                            icon: "folder_open"
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal
                            onClicked: CaelestiaGit.openFolder()
                        }

                        IconButton {
                            icon: "terminal"
                            type: IconButton.Tonal
                            padding: Tokens.padding.small
                            enabled: root.hasLocal
                            onClicked: CaelestiaGit.openTerminal()
                        }

                        StyledRect {
                            implicitHeight: 32
                            implicitWidth: openGitxRow.implicitWidth + 14
                            radius: Tokens.rounding.full
                            color: Colours.tPalette.m3surfaceContainerHigh

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
                                    color: Colours.palette.m3onSurface
                                    fontStyle: Tokens.font.icon.small
                                }

                                StyledText {
                                    text: "GitX"
                                    font: Tokens.font.label.medium
                                    color: Colours.palette.m3onSurface
                                }
                            }
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Colours.tPalette.m3outlineVariant
                }

                // 2. Status Summary Cards (Even 3-way split with preferredWidth: 0)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Card 1: Remote Sync Status
                    StyledRect {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        implicitHeight: 92
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            RowLayout {
                                spacing: 4
                                MaterialIcon {
                                    text: {
                                        if (!root.repo || !root.hasLocal) return "cloud_off";
                                        const ahead = root.repo.local?.ahead || root.repo.ahead || 0;
                                        const behind = root.repo.local?.behind || root.repo.behind || 0;
                                        if (ahead > 0 && behind > 0) return "sync_problem";
                                        if (ahead > 0) return "cloud_upload";
                                        if (behind > 0) return "cloud_download";
                                        return "cloud_done";
                                    }
                                    color: {
                                        if (!root.repo || !root.hasLocal) return Colours.palette.m3outline;
                                        const ahead = root.repo.local?.ahead || root.repo.ahead || 0;
                                        const behind = root.repo.local?.behind || root.repo.behind || 0;
                                        if (ahead > 0 || behind > 0) return Colours.palette.m3tertiary;
                                        return Colours.palette.m3primary;
                                    }
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Remote Sync"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: {
                                    if (!root.repo || !root.hasLocal) return "Not cloned locally";
                                    const ahead = root.repo.local?.ahead || root.repo.ahead || 0;
                                    const behind = root.repo.local?.behind || root.repo.behind || 0;
                                    if (ahead > 0 && behind > 0) return `↑ ${ahead} • ↓ ${behind}`;
                                    if (ahead > 0) return `↑ ${ahead} commit(s) ahead`;
                                    if (behind > 0) return `↓ ${behind} commit(s) behind`;
                                    return "Up to date";
                                }
                                font: Tokens.font.title.small
                                color: Colours.tPalette.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: {
                                    if (!root.repo || !root.hasLocal) return "Missing local clone";
                                    const ahead = root.repo.local?.ahead || root.repo.ahead || 0;
                                    const behind = root.repo.local?.behind || root.repo.behind || 0;
                                    if (ahead > 0 && behind > 0) return "Diverged — need merge";
                                    if (ahead > 0) return "Ready to push";
                                    if (behind > 0) return "Ready to pull";
                                    return "In sync with upstream";
                                }
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Card 2: Working Tree Status
                    StyledRect {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        implicitHeight: 92
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            RowLayout {
                                spacing: 4
                                MaterialIcon {
                                    text: root.counts.changed > 0 ? "edit_document" : "check_circle"
                                    color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3primary
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Working Tree"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: root.counts.changed > 0 ? `${root.counts.changed} modified file(s)` : "Clean working tree"
                                font: Tokens.font.title.small
                                color: root.counts.changed > 0 ? Colours.palette.m3tertiary : Colours.palette.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: root.counts.changed > 0 ? `${root.counts.staged} staged • ${root.counts.unstaged} unstaged` : "No uncommitted changes"
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Card 3: Latest Commit Info
                    StyledRect {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        implicitHeight: 92
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            RowLayout {
                                spacing: 4
                                MaterialIcon {
                                    text: "history"
                                    color: Colours.tPalette.m3primary
                                    fontStyle: Tokens.font.icon.small
                                }
                                StyledText {
                                    text: "Latest Commit"
                                    font: Tokens.font.label.medium
                                    color: Colours.tPalette.m3onSurfaceVariant
                                }
                                Item { Layout.fillWidth: true }
                                StyledText {
                                    visible: !!root.repo && !!root.repo.local?.lastCommit?.short
                                    text: root.repo && root.repo.local?.lastCommit ? root.repo.local.lastCommit.short : ""
                                    font: Tokens.font.mono.small
                                    color: Colours.palette.m3primary
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: root.repo && root.repo.local?.lastCommit ? root.repo.local.lastCommit.subject : "No commit info"
                                font: Tokens.font.body.medium
                                color: Colours.tPalette.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: {
                                    if (!root.repo || !root.repo.local?.lastCommit) return "";
                                    const c = root.repo.local.lastCommit;
                                    const author = c.author || "unknown";
                                    const dateStr = c.date ? c.date.substring(0, 10) : "";
                                    return `${author}${dateStr ? " • " + dateStr : ""}`;
                                }
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // 3. Status Detail / Glance Area
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.fillHeight: true
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer
                    clip: true

                    // View 1: If modified -> show clean list of changed files
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6
                        visible: root.counts.changed > 0

                        RowLayout {
                            Layout.fillWidth: true

                            MaterialIcon {
                                text: "format_list_bulleted"
                                color: Colours.palette.m3tertiary
                                fontStyle: Tokens.font.icon.small
                            }

                            StyledText {
                                text: `Uncommitted Files (${root.counts.changed})`
                                font: Tokens.font.title.small
                                color: Colours.tPalette.m3onSurface
                            }

                            Item { Layout.fillWidth: true }

                            StyledText {
                                text: "Read-only overview • Commit via terminal or GitX"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3outline
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: root.status && root.status.files && root.status.files.length > 0 ? root.status.files.slice(0, 100) : []

                            delegate: StyledRect {
                                required property var modelData
                                width: ListView.view.width
                                implicitHeight: 30
                                radius: Tokens.rounding.small
                                color: Colours.tPalette.m3surfaceContainerHigh

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    // Status Badge (M, ?, A, D)
                                    StyledRect {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        radius: 4
                                        color: modelData.worktree === "?" || modelData.untracked ? Colours.tPalette.m3surfaceContainerHighest : (modelData.staged ? Colours.palette.m3primaryContainer : Colours.palette.m3tertiaryContainer)

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: modelData.worktree === "?" || modelData.untracked ? "?" : (modelData.worktree || modelData.index || "M")
                                            font: Tokens.font.mono.small
                                            color: modelData.worktree === "?" || modelData.untracked ? Colours.palette.m3onSurfaceVariant : (modelData.staged ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onTertiaryContainer)
                                        }
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 0
                                        text: modelData.path || ""
                                        font: Tokens.font.mono.small
                                        color: Colours.palette.m3onSurface
                                        elide: Text.ElideMiddle
                                    }
                                }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                visible: (!root.status || !root.status.files || root.status.files.length === 0) && root.counts.changed > 0
                                text: "Loading changed file details…"
                                color: Colours.palette.m3outline
                                font: Tokens.font.body.small
                            }
                        }
                    }

                    // View 2: If clean -> show clean confirmation state
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.counts.changed === 0
                        spacing: 6

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "verified"
                            color: Colours.palette.m3primary
                            fontStyle: Tokens.font.icon.large
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Working tree is clean"
                            font: Tokens.font.title.medium
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "All changes are committed. No unstaged or untracked files."
                            font: Tokens.font.body.medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledRect {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !!root.repo && !!root.repo.local?.lastCommit
                            implicitWidth: Math.min(480, root.width - 380)
                            implicitHeight: lastCommitBox.implicitHeight + 16
                            radius: Tokens.rounding.medium
                            color: Colours.tPalette.m3surfaceContainerHigh

                            ColumnLayout {
                                id: lastCommitBox
                                anchors.centerIn: parent
                                width: parent.implicitWidth - 16
                                spacing: 4

                                RowLayout {
                                    MaterialIcon {
                                        text: "commit"
                                        color: Colours.palette.m3primary
                                        fontStyle: Tokens.font.icon.small
                                    }
                                    StyledText {
                                        text: root.repo && root.repo.local?.lastCommit ? (root.repo.local.lastCommit.short + " · " + root.repo.local.lastCommit.author) : ""
                                        font: Tokens.font.mono.small
                                        color: Colours.palette.m3primary
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: root.repo && root.repo.local?.lastCommit ? root.repo.local.lastCommit.subject : ""
                                    font: Tokens.font.body.small
                                    color: Colours.palette.m3onSurface
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
