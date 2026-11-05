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

    implicitWidth: Math.min(1080, (Quickshell.screens.length ? Quickshell.screens[0].width : 1920) - 120)
    implicitHeight: Math.min(640, (Quickshell.screens.length ? Quickshell.screens[0].height : 1080) - 200)

    readonly property var repo: CaelestiaGit.selected
    readonly property bool hasLocal: !!repo && !!repo.localPath
    readonly property bool hasRemote: !!(CaelestiaGit.detail && CaelestiaGit.detail.remotes && CaelestiaGit.detail.remotes.length > 0)
    readonly property var status: CaelestiaGit.status
    readonly property int changedCount: status && status.counts ? status.counts.changed : 0
    readonly property var tabs: [
        { label: "Changes", icon: "edit_note", badge: changedCount },
        { label: "History", icon: "history", badge: 0 },
        { label: "Branches", icon: "account_tree", badge: CaelestiaGit.branches.locals.length }
    ]
    readonly property var filters: [
        { id: "all", label: "All", count: CaelestiaGit.stats.total || 0 },
        { id: "local", label: "Local", count: CaelestiaGit.stats.local || 0 },
        { id: "dirty", label: "Modified", count: CaelestiaGit.stats.dirty || 0 },
        { id: "behind", label: "Behind", count: CaelestiaGit.stats.behind || 0 },
        { id: "missing", label: "Not cloned", count: CaelestiaGit.stats.missing || 0 }
    ]

    Component.onCompleted: {
        CaelestiaGit.ensureFresh();
        CaelestiaGit.selectFirst();
    }

    Connections {
        target: CaelestiaGit

        function onSnapshotChanged() {
            CaelestiaGit.selectFirst();
        }
    }

    Connections {
        target: root.screenState

        function onDashboardChanged() {
            if (root.screenState.dashboard && root.screenState.dashboardTab === CaelestiaGit.tabIndex) {
                CaelestiaGit.ensureFresh();
                CaelestiaGit.selectFirst();
            } else if (!root.screenState.dashboard) {
                CaelestiaGit.newRepoOpen = false;
                CaelestiaGit.publishOpen = false;
                CaelestiaGit.folderPickerOpen = false;
            }
        }
    }

    Component.onDestruction: {
        CaelestiaGit.newRepoOpen = false;
        CaelestiaGit.publishOpen = false;
        CaelestiaGit.folderPickerOpen = false;
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.screenState.dashboard && root.screenState.dashboardTab === CaelestiaGit.tabIndex
        onActivated: root.screenState.dashboard = false
    }

    Shortcut {
        sequence: "Ctrl+R"
        enabled: root.screenState.dashboard && root.screenState.dashboardTab === CaelestiaGit.tabIndex
        onActivated: CaelestiaGit.refresh()
    }

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        // ------------------------------------------------------------------
        // Repository list
        // ------------------------------------------------------------------
        StyledRect {
            Layout.preferredWidth: Math.min(370, Math.max(280, root.width * 0.34))
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        implicitWidth: 34
                        implicitHeight: 34
                        radius: Tokens.rounding.small
                        color: Colours.palette.m3primaryContainer

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "account_tree"
                            color: Colours.palette.m3onPrimaryContainer
                            fontStyle: Tokens.font.icon.medium
                            fill: 1
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: "Caelestia Git"
                            color: Colours.palette.m3onSurface
                            font: Tokens.font.title.small
                        }

                        StyledText {
                            text: CaelestiaGit.auth.login ? "GitHub · " + CaelestiaGit.auth.login : "GitHub not connected"
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.label.small
                        }
                    }

                    IconButton {
                        icon: "add"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        onClicked: CaelestiaGit.newRepoOpen = true
                    }

                    IconButton {
                        icon: "refresh"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        enabled: !CaelestiaGit.loading
                        onClicked: CaelestiaGit.refresh()
                    }

                    IconButton {
                        icon: "open_in_new"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        onClicked: CaelestiaGit.openFullApp()
                    }
                }

                SearchBar {
                    id: searchBar

                    Layout.fillWidth: true
                    placeholderText: "Search repositories…"
                    text: CaelestiaGit.search
                    onTextEdited: CaelestiaGit.search = text
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.extraSmall

                    Repeater {
                        model: root.filters

                        delegate: FilterChip {
                            text: modelData.label
                            count: modelData.count
                            active: CaelestiaGit.filter === modelData.id
                            onClicked: CaelestiaGit.filter = modelData.id
                        }
                    }
                }

                ListView {
                    id: repoList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: CaelestiaGit.filteredRepos

                    delegate: RepoRow {
                        width: repoList.width
                        selected: String(modelData.id || modelData.fullName) === CaelestiaGit.selectedFullName
                        onActivated: CaelestiaGit.selectRepo(modelData)
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: CaelestiaGit.filteredRepos.length === 0 && !CaelestiaGit.loading
                    text: "No matching repositories."
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        Layout.fillWidth: true
                        text: (CaelestiaGit.stats.total || 0) + " repos · " + (CaelestiaGit.stats.local || 0) + " local"
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.label.small
                    }

                    MiniButton {
                        visible: (CaelestiaGit.stats.missing || 0) > 0
                        compact: true
                        icon: "cloud_download"
                        text: "Clone " + (CaelestiaGit.stats.missing || 0)
                        enabled: !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.cloneMissing()
                    }
                }
            }
        }

        // ------------------------------------------------------------------
        // Detail
        // ------------------------------------------------------------------
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainerLow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        StyledText {
                            Layout.fillWidth: true
                            text: root.repo ? (root.repo.owner ? root.repo.owner + "/" : "") + root.repo.name : "Caelestia Git"
                            color: Colours.palette.m3onSurface
                            font: Tokens.font.title.medium
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: Tokens.spacing.extraSmall

                            StateChip {
                                visible: !!root.repo
                                state: root.repo ? root.repo.state : "missing"
                            }

                            StyledText {
                                visible: root.hasLocal
                                text: root.status && root.status.branch ? root.status.branch : ""
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.mono.small
                            }

                            StyledText {
                                visible: root.hasLocal && root.status && (root.status.ahead > 0 || root.status.behind > 0)
                                text: root.status ? "↑" + root.status.ahead + " ↓" + root.status.behind : ""
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.mono.small
                            }

                            StyledText {
                                visible: !!root.repo && !root.hasLocal
                                text: root.repo ? root.repo.fullName : ""
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.mono.small
                                elide: Text.ElideRight
                            }
                        }
                    }

                    IconButton {
                        visible: root.hasLocal
                        icon: "cloud_download"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        enabled: root.hasRemote && !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.fetchSelected()
                    }

                    IconButton {
                        visible: root.hasLocal
                        icon: "download"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        enabled: root.hasRemote && !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.pullSelected()
                    }

                    IconButton {
                        visible: root.hasLocal
                        icon: "upload"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        enabled: root.hasRemote && !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.pushSelected()
                    }

                    IconButton {
                        visible: root.hasLocal && !root.hasRemote
                        icon: "cloud_upload"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        enabled: !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.publishOpen = true
                    }

                    IconButton {
                        visible: root.hasLocal
                        icon: "folder_open"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        onClicked: CaelestiaGit.openFolder()
                    }

                    IconButton {
                        icon: "open_in_new"
                        type: IconButton.Text
                        padding: Tokens.padding.small
                        onClicked: CaelestiaGit.openFullApp()
                    }

                    MiniButton {
                        visible: !!root.repo && !root.hasLocal
                        text: "Clone"
                        icon: "cloud_download"
                        primary: true
                        enabled: !CaelestiaGit.actionBusy
                        onClicked: CaelestiaGit.cloneSelected()
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: !!root.repo && root.hasLocal
                    text: root.repo ? root.repo.localPath : ""
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.mono.small
                    elide: Text.ElideMiddle
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: root.hasLocal

                    Repeater {
                        model: root.tabs

                        delegate: PanelTab {
                            label: modelData.label
                            icon: modelData.icon
                            badge: modelData.badge
                            active: CaelestiaGit.tab === index
                            onClicked: {
                                CaelestiaGit.tab = index;
                                if (index === 1) {
                                    if (CaelestiaGit.logData.length === 0)
                                        CaelestiaGit.loadLog();
                                    else if (!CaelestiaGit.commitDetail && CaelestiaGit.logData.length > 0)
                                        CaelestiaGit.loadCommitDetail(CaelestiaGit.logData[0].hash);
                                } else if (index === 2 && !CaelestiaGit.detail) {
                                    CaelestiaGit.loadDetail();
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        visible: CaelestiaGit.actionBusy && CaelestiaGit.actionLabel !== ""
                        text: CaelestiaGit.actionLabel
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.label.small
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ChangesPane {
                        anchors.fill: parent
                        visible: root.hasLocal && CaelestiaGit.tab === 0
                    }

                    HistoryPane {
                        anchors.fill: parent
                        visible: root.hasLocal && CaelestiaGit.tab === 1
                    }

                    BranchesPane {
                        anchors.fill: parent
                        visible: root.hasLocal && CaelestiaGit.tab === 2
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width - Tokens.padding.extraLarge * 2
                        spacing: Tokens.spacing.small
                        visible: root.repo && !root.hasLocal

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "cloud_off"
                            color: Colours.palette.m3onSurfaceVariant
                            fontStyle: Tokens.font.icon.extraLarge
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "This repository isn’t cloned"
                            color: Colours.palette.m3onSurface
                            font: Tokens.font.title.small
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.repo ? root.repo.description || "Clone it to commit, pull and push from the panel." : ""
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Clone"
                            icon: "cloud_download"
                            primary: true
                            enabled: !CaelestiaGit.actionBusy
                            onClicked: CaelestiaGit.cloneSelected()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Tokens.spacing.small
                        visible: !root.repo

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "account_tree"
                            color: Colours.palette.m3onSurfaceVariant
                            fontStyle: Tokens.font.icon.extraLarge
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Select a repository"
                            color: Colours.palette.m3onSurface
                            font: Tokens.font.title.small
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "The left list combines your GitHub account and your disk."
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                        }
                    }
                }
            }
        }
    }

    // ----------------------------------------------------------------------
    // Toast
    // ----------------------------------------------------------------------
    StyledRect {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.padding.large
        width: Math.min(360, toastText.implicitWidth + Tokens.padding.large * 2)
        implicitHeight: toastText.implicitHeight + Tokens.padding.medium * 2
        radius: Tokens.rounding.medium
        color: CaelestiaGit.toastKind === "bad" ? Colours.palette.m3errorContainer : CaelestiaGit.toastKind === "warn" ? Colours.palette.m3tertiaryContainer : Colours.palette.m3secondaryContainer
        opacity: CaelestiaGit.toastVisible ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity {
            Anim {
                type: Anim.FastEffects
            }
        }

        StyledText {
            id: toastText

            anchors.centerIn: parent
            width: parent.width - Tokens.padding.large * 2
            text: CaelestiaGit.toastText
            color: CaelestiaGit.toastKind === "bad" ? Colours.palette.m3onErrorContainer : CaelestiaGit.toastKind === "warn" ? Colours.palette.m3onTertiaryContainer : Colours.palette.m3onSecondaryContainer
            font: Tokens.font.body.small
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    NewRepoDialog {
        anchors.fill: parent
        open: CaelestiaGit.newRepoOpen
        onClosed: CaelestiaGit.newRepoOpen = false
    }

    PublishDialog {
        anchors.fill: parent
        open: CaelestiaGit.publishOpen
        repo: root.repo
        onClosed: CaelestiaGit.publishOpen = false
    }

    // ----------------------------------------------------------------------
    // Local components
    // ----------------------------------------------------------------------
    component FilterChip: StyledRect {
        id: chip

        property string text: ""
        property int count: 0
        property bool active: false
        signal clicked

        implicitWidth: chipRow.implicitWidth + Tokens.padding.medium * 2
        implicitHeight: 28
        radius: Tokens.rounding.full
        color: active ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainerHigh

        StateLayer {
            anchors.fill: parent
            radius: chip.radius
            color: Colours.palette.m3primary
            onClicked: chip.clicked()
        }

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.extraSmall

            StyledText {
                text: chip.text
                color: chip.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }

            StyledText {
                text: chip.count
                color: chip.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font: Tokens.font.mono.small
                opacity: 0.75
            }
        }
    }

    component PanelTab: StyledRect {
        id: tab

        property string label: ""
        property string icon: ""
        property int badge: 0
        property bool active: false
        signal clicked

        implicitWidth: tabRow.implicitWidth + Tokens.padding.medium * 2
        implicitHeight: 32
        radius: Tokens.rounding.full
        color: active ? Colours.palette.m3secondaryContainer : "transparent"

        StateLayer {
            anchors.fill: parent
            radius: tab.radius
            color: Colours.palette.m3primary
            onClicked: tab.clicked()
        }

        RowLayout {
            id: tabRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.extraSmall

            MaterialIcon {
                text: tab.icon
                color: tab.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                text: tab.label
                color: tab.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }

            StyledText {
                visible: tab.badge > 0
                text: tab.badge
                color: tab.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font: Tokens.font.mono.small
                opacity: 0.8
            }
        }
    }
}
