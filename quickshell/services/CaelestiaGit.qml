pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.services

Singleton {
    id: root

    // ---- state -----------------------------------------------------------
    property var snapshot: null
    property var detail: null
    property var logData: []
    property var diffData: null
    property var commitDetail: null
    property var diffSelection: null
    property string diffFile: ""
    property string selectedFullName: ""
    property int tab: 0
    property string filter: "all"
    property string search: ""
    property string commitMessage: ""
    property string pendingSelectPath: ""
    property bool newRepoOpen: false
    property bool publishOpen: false
    property bool folderPickerOpen: false
    property bool detailLoading: false
    property bool logLoading: false
    property bool diffLoading: false
    property bool commitLoading: false
    property bool actionBusy: false
    property string actionLabel: ""
    property string error: ""
    property string toastText: ""
    property string toastKind: "info"
    property bool toastVisible: false
    property var requestQueue: []
    property var currentRequest: null

    readonly property bool loading: currentRequest !== null || requestQueue.length > 0
    readonly property var allRepos: snapshot ? ((snapshot.repos || []).concat(snapshot.localOnly || [])) : []
    readonly property var stats: {
        const s = (snapshot && snapshot.stats) ? snapshot.stats : ({});
        const total = s.total || 0;
        const dirty = s.dirty || 0;
        const ahead = s.ahead || 0;
        const behind = s.behind || 0;
        const missing = s.missing || 0;
        const synced = Math.max(0, total - dirty - ahead - behind - missing);
        return {
            total: total,
            local: s.local || 0,
            missing: missing,
            dirty: dirty,
            ahead: ahead,
            behind: behind,
            synced: synced,
            localOnly: s.localOnly || 0
        };
    }
    readonly property var auth: snapshot && snapshot.auth ? snapshot.auth : ({})
    readonly property int tabIndex: {
        const mon = Hypr.focusedMonitor;
        const screen = Screens.screens.find(s => Hypr.monitorFor(s) === mon) || Screens.screens[0];
        return screen ? root.tabIndexForScreen(screen.name) : 4;
    }

    function tabIndexForScreen(screenName: string): int {
        const cfg = GlobalConfig.forScreen(screenName);
        return (cfg.dashboard.showDashboard ? 1 : 0) + (cfg.dashboard.showMedia ? 1 : 0) + 1 + (cfg.dashboard.showPerformance ? 1 : 0) + (cfg.dashboard.showWeather ? 1 : 0);
    }

    readonly property var selected: {
        if (!selectedFullName)
            return null;
        return allRepos.find(r => String(r.id || r.fullName) === selectedFullName) || null;
    }

    readonly property var filteredRepos: {
        let list = allRepos;
        switch (filter) {
        case "local":
            list = list.filter(r => !!r.localPath);
            break;
        case "synced":
            list = list.filter(r => r.state === "synced");
            break;
        case "missing":
            list = list.filter(r => !r.localPath);
            break;
        case "dirty":
            list = list.filter(r => ["dirty", "conflicted", "operation"].includes(r.state));
            break;
        case "behind":
            list = list.filter(r => ["behind", "diverged"].includes(r.state));
            break;
        case "ahead":
            list = list.filter(r => ["ahead", "diverged"].includes(r.state));
            break;
        }
        const q = search.trim().toLowerCase();
        if (q) {
            list = list.filter(r => [r.fullName, r.name, r.owner, r.description, r.localPath, r.local?.branch, r.defaultBranch, r.stateLabel].filter(Boolean).some(v => String(v).toLowerCase().includes(q)));
        }
        return list;
    }

    readonly property var status: detail && detail.status ? detail.status : null
    readonly property var branches: detail && detail.branches ? detail.branches : ({ locals: [], remotes: [] })
    readonly property var changeGroups: {
        if (!status)
            return [];
        const groups = [];
        const add = (label, files, group) => {
            if (!files || files.length === 0)
                return;
            groups.push({
                label: label,
                group: group,
                files: files.map(f => ({
                    path: f.path,
                    index: f.index,
                    worktree: f.worktree,
                    untracked: !!f.untracked,
                    conflict: !!f.conflict
                }))
            });
        };
        add("Conflicts", status.conflicts, "conflict");
        add("Staged", status.staged, "staged");
        add("Modified", status.unstaged, "unstaged");
        add("Untracked", status.untracked, "untracked");
        return groups;
    }

    // ---- helpers ---------------------------------------------------------
    function notify(text, kind) {
        root.toastText = text;
        root.toastKind = kind || "info";
        root.toastVisible = true;
        toastTimer.restart();
    }

    function ensureFresh() {
        if (!root.snapshot) {
            root.refresh();
            return;
        }
        if (Date.now() - (root.snapshot.at || 0) > 60000)
            root.refresh();
    }

    function openDashboard() {
        const state = ShellState.forActive();
        if (!state)
            return;
        state.dashboard = true;
        state.dashboardTab = root.tabIndex;
    }

    function toggleDashboard() {
        const state = ShellState.forActive();
        if (!state)
            return;
        if (state.dashboard && state.dashboardTab === root.tabIndex) {
            state.dashboard = false;
            return;
        }
        state.dashboard = true;
        state.dashboardTab = root.tabIndex;
    }

    function selectRepo(repo) {
        if (!repo)
            return;
        const id = String(repo.id || repo.fullName);
        if (root.selectedFullName === id) {
            root.tab = 0;
            return;
        }
        root.selectedFullName = id;
        root.tab = 0;
        root.detail = null;
        root.logData = [];
        root.diffData = null;
        root.diffSelection = null;
        root.diffFile = "";
        root.commitDetail = null;
        if (repo.localPath) {
            root.loadDetail();
            root.loadLog();
        }
    }

    function clearSelection() {
        root.selectedFullName = "";
        root.detail = null;
        root.logData = [];
        root.diffData = null;
        root.diffSelection = null;
        root.diffFile = "";
        root.commitDetail = null;
    }

    // ---- request queue ---------------------------------------------------
    function request(method, params, onSuccess, onError) {
        root.requestQueue = root.requestQueue.concat([{
            method: method,
            params: params || {},
            onSuccess: onSuccess,
            onError: onError
        }]);
        root.pump();
    }

    function pump() {
        if (root.currentRequest || root.requestQueue.length === 0)
            return;
        const req = root.requestQueue[0];
        root.requestQueue = root.requestQueue.slice(1);
        root.currentRequest = req;
        proc.command = ["caelestia-git-bridge", req.method, JSON.stringify(req.params)];
        proc.running = true;
    }

    function finishRequest(ok, data, message) {
        const req = root.currentRequest;
        root.currentRequest = null;
        if (ok) {
            root.error = "";
            if (req && req.onSuccess)
                req.onSuccess(data);
        } else {
            root.error = message || "Caelestia Git error";
            root.notify(root.error, "bad");
            if (req && req.onError)
                req.onError(root.error);
        }
        root.pump();
    }

    // ---- snapshot --------------------------------------------------------
    function refresh() {
        request("refresh", {}, data => {
            const all = (data.repos || []).concat(data.localOnly || []);
            root.snapshot = data;
            if (root.selectedFullName && !all.some(r => String(r.id || r.fullName) === root.selectedFullName)) {
                root.clearSelection();
            } else {
                const current = all.find(r => String(r.id || r.fullName) === root.selectedFullName);
                if (current && current.localPath && !root.detail)
                    root.loadDetail();
            }
            if (root.pendingSelectPath) {
                const created = all.find(r => r.localPath === root.pendingSelectPath);
                root.pendingSelectPath = "";
                if (created)
                    root.selectRepo(created);
                else if (!root.selectedFullName && all.length > 0)
                    root.selectRepo(all[0]);
            } else if (!root.selectedFullName && all.length > 0) {
                root.selectRepo(all[0]);
            }
        });
    }

    function selectFirst() {
        if (!root.selected && root.allRepos.length > 0)
            root.selectRepo(root.allRepos[0]);
    }

    function selectByName(name) {
        const repo = root.allRepos.find(r => (r.fullName || r.name || r.id) === name) || root.allRepos.find(r => (r.fullName || "").toLowerCase() === String(name).toLowerCase());
        if (repo)
            root.selectRepo(repo);
    }

    // ---- detail / history / diff ----------------------------------------
    function loadDetail() {
        const repo = root.selected;
        if (!repo || !repo.localPath)
            return;
        const id = root.selectedFullName;
        root.detailLoading = true;
        request("detail", { fullName: repo.fullName || repo.id, path: repo.localPath }, data => {
            if (root.selectedFullName === id) {
                root.detail = data;
                root.detailLoading = false;
            }
        }, () => {
            root.detailLoading = false;
        });
    }

    function loadLog() {
        const repo = root.selected;
        if (!repo || !repo.localPath)
            return;
        const id = root.selectedFullName;
        root.logLoading = true;
        request("log", { fullName: repo.fullName || repo.id, path: repo.localPath, limit: 60 }, data => {
            if (root.selectedFullName === id) {
                root.logData = data || [];
                root.logLoading = false;
                if (root.logData.length > 0 && (!root.commitDetail || !root.logData.some(c => c.hash === root.commitDetail.hash)))
                    root.loadCommitDetail(root.logData[0].hash);
            }
        }, () => {
            root.logLoading = false;
        });
    }

    function loadDiff(file) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !file)
            return;
        const id = root.selectedFullName;
        root.diffLoading = true;
        root.diffSelection = file;
        request("diff", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            file: file.path,
            staged: file.group === "staged",
            untracked: file.group === "untracked"
        }, data => {
            if (root.selectedFullName === id) {
                root.diffData = data;
                root.diffFile = file.path;
                root.diffLoading = false;
            }
        }, () => {
            root.diffLoading = false;
        });
    }

    function loadCommitDetail(sha) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !sha)
            return;
        const id = root.selectedFullName;
        root.commitLoading = true;
        request("commitDetail", { fullName: repo.fullName || repo.id, path: repo.localPath, sha: sha }, data => {
            if (root.selectedFullName === id) {
                root.commitDetail = data;
                root.commitLoading = false;
            }
        }, () => {
            root.commitLoading = false;
        });
    }

    // ---- mutations -------------------------------------------------------
    function reloadRepo() {
        root.loadDetail();
        root.loadLog();
        root.refresh();
    }

    function stageFiles(files) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !files || files.length === 0)
            return;
        root.actionBusy = true;
        root.actionLabel = "Staging…";
        request("stage", { fullName: repo.fullName || repo.id, path: repo.localPath, files: files }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.reloadRepo();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function unstageFiles(files) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !files || files.length === 0)
            return;
        root.actionBusy = true;
        root.actionLabel = "Unstaging…";
        request("unstage", { fullName: repo.fullName || repo.id, path: repo.localPath, files: files }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.reloadRepo();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function commit(push) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !root.commitMessage.trim()) {
            root.notify("Write a commit message.", "warn");
            return;
        }
        root.actionBusy = true;
        root.actionLabel = push ? "Commit + push…" : "Commit…";
        request("commit", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            message: root.commitMessage
        }, () => {
            root.commitMessage = "";
            root.commitDetail = null;
            root.notify("Commit created.", "ok");
            root.loadDetail();
            root.loadLog();
            if (push) {
                request("push", {
                    fullName: repo.fullName || repo.id,
                    path: repo.localPath,
                    options: {}
                }, () => {
                    root.actionBusy = false;
                    root.actionLabel = "";
                    root.notify("Commit pushed to GitHub.", "ok");
                    root.refresh();
                }, () => {
                    root.actionBusy = false;
                    root.actionLabel = "";
                    root.refresh();
                });
            } else {
                root.actionBusy = false;
                root.actionLabel = "";
                root.refresh();
            }
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function repoAction(method, label) {
        const repo = root.selected;
        if (!repo || !repo.localPath || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = label + "…";
        request(method, {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            options: {}
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify(label + " : OK", "ok");
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.refresh();
        });
    }

    function fetchSelected() {
        repoAction("fetch", "Fetch");
    }

    function pullSelected() {
        repoAction("pull", "Pull");
    }

    function pushSelected() {
        repoAction("push", "Push");
    }

    function checkoutBranch(name) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !name || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Checkout…";
        request("branchAction", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            action: "checkout",
            payload: { name: name }
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify("Bascule sur " + name + ".", "ok");
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function cloneSelected() {
        const repo = root.selected;
        if (!repo || !repo.fullName || repo.localPath || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Cloning…";
        request("clone", { fullName: repo.fullName }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify("Repository cloned.", "ok");
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function cloneMissing() {
        if (root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Cloning missing repositories…";
        request("cloneMissing", {}, data => {
            root.actionBusy = false;
            root.actionLabel = "";
            const ok = (data || []).filter(r => r.ok).length;
            root.notify(ok + " repository(ies) cloned.", ok ? "ok" : "warn");
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function openFolder() {
        const repo = root.selected;
        if (!repo || !repo.localPath)
            return;
        request("open", { target: repo.localPath });
    }

    function openTerminal() {
        const repo = root.selected;
        if (!repo || !repo.localPath)
            return;
        Quickshell.execDetached(["foot", "--working-directory", repo.localPath]);
    }

    function openFile(file) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !file)
            return;
        request("open", { target: repo.localPath + "/" + file.path });
    }

    function openFullApp() {
        Quickshell.execDetached(["caelestia-git-bridge", "openApp"]);
        root.notify("Opening Caelestia Git…", "info");
    }

    function copy(text) {
        Quickshell.execDetached(["wl-copy", String(text)]);
        root.notify("Copied.", "ok");
    }

    function createRepo(params, onDone) {
        if (root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Creating repository…";
        request("initRepo", params, data => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.pendingSelectPath = data && data.path ? data.path : "";
            root.notify(data && data.fullName ? "Repository created and published to GitHub." : "Local repository created.", "ok");
            root.refresh();
            if (onDone)
                onDone(null, data);
        }, err => {
            root.actionBusy = false;
            root.actionLabel = "";
            if (onDone)
                onDone(err);
        });
    }

    function publishRepo(params, onDone) {
        if (root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Publishing to GitHub…";
        request("publish", params, data => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.pendingSelectPath = data && data.path ? data.path : "";
            root.notify("Repository published to GitHub.", "ok");
            root.detail = null;
            root.loadDetail();
            root.refresh();
            if (onDone)
                onDone(null, data);
        }, err => {
            root.actionBusy = false;
            root.actionLabel = "";
            if (onDone)
                onDone(err);
        });
    }

    function createBranch(name) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !name || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Creating branch…";
        request("branchAction", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            action: "create",
            payload: { name: name, checkout: true }
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify("Branch " + name + " created.", "ok");
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function mergeBranch(name) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !name || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Merge…";
        request("branchAction", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            action: "merge",
            payload: { name: name }
        }, data => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify(data && data.conflict ? "Merge completed with conflicts." : "Merge complete.", data && data.conflict ? "warn" : "ok");
            root.commitDetail = null;
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function rebaseBranch(name) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !name || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Rebase…";
        request("branchAction", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            action: "rebase",
            payload: { name: name }
        }, data => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify(data && data.conflict ? "Rebase completed with conflicts." : "Rebase complete.", data && data.conflict ? "warn" : "ok");
            root.commitDetail = null;
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    function deleteBranch(name) {
        const repo = root.selected;
        if (!repo || !repo.localPath || !name || root.actionBusy)
            return;
        root.actionBusy = true;
        root.actionLabel = "Deleting branch…";
        request("branchAction", {
            fullName: repo.fullName || repo.id,
            path: repo.localPath,
            action: "delete",
            payload: { name: name, force: false }
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
            root.notify("Branch " + name + " deleted.", "ok");
            root.commitDetail = null;
            root.loadDetail();
            root.loadLog();
            root.refresh();
        }, () => {
            root.actionBusy = false;
            root.actionLabel = "";
        });
    }

    // ---- process ---------------------------------------------------------
    Process {
        id: proc

        running: false
        command: []

        stdout: StdioCollector {
            id: stdoutText
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: stderrText
            waitForEnd: true
        }

        onExited: (exitCode, exitStatus) => {
            let parsed = null;
            try {
                parsed = JSON.parse(stdoutText.text);
            } catch (e) {}
            if (!parsed) {
                const detail = stderrText.text.trim();
                root.finishRequest(false, null, detail || "Invalid response from Caelestia Git. Make sure `caelestia-git-bridge` and cmoGit are installed.");
                return;
            }
            if (parsed.ok)
                root.finishRequest(true, parsed.data);
            else
                root.finishRequest(false, null, parsed.error?.message || "Caelestia Git error");
        }
    }

    Timer {
        id: toastTimer

        interval: 3800
        onTriggered: root.toastVisible = false
    }
}
