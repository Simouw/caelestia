#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
#  Caelestia Quickshell Add-ons Installer
#  Installs:
#  - Caelestia Notes & Todos
#  - Streamlined Caelestia Git Panel (Status Overview)
#  - Top Bar Timer / Reminder widget (Pomodoro & presets)
#  - Top Bar AI Assistant Launcher (OpenCode, Antigravity, Codex, Claude)
#  - Sidebar Keyboard Layout Switcher (FR / US)
# ==============================================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QS_CONFIG="${QS_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/caelestia}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

if [[ ! -f "$QS_CONFIG/shell.qml" ]]; then
  echo "[-] Caelestia shell configuration not found at $QS_CONFIG"
  echo "    Please install or start Caelestia shell first."
  exit 1
fi

echo "[+] Target Quickshell config: $QS_CONFIG"

# 1. Copy modules and services
echo "[+] Copying QML modules & services..."
mkdir -p "$QS_CONFIG/modules/bar/components" \
         "$QS_CONFIG/modules/bar/popouts/icons" \
         "$QS_CONFIG/modules/dashboard/notes" \
         "$QS_CONFIG/modules/gitpanel" \
         "$QS_CONFIG/modules/sidebar" \
         "$QS_CONFIG/modules/nexus/pages/audio" \
         "$QS_CONFIG/components/containers" \
         "$QS_CONFIG/services"

cp "$ROOT/components/containers/HorizontalFadeFlickable.qml" "$QS_CONFIG/components/containers/HorizontalFadeFlickable.qml"
cp -r "$ROOT/modules/gitpanel/"* "$QS_CONFIG/modules/gitpanel/"
cp "$ROOT/modules/dashboard/NotesTab.qml" "$QS_CONFIG/modules/dashboard/NotesTab.qml"
cp -r "$ROOT/modules/dashboard/notes/"* "$QS_CONFIG/modules/dashboard/notes/"
cp "$ROOT/modules/bar/components/TimerButton.qml" "$QS_CONFIG/modules/bar/components/TimerButton.qml"
cp "$ROOT/modules/bar/components/AiButton.qml" "$QS_CONFIG/modules/bar/components/AiButton.qml"
cp "$ROOT/modules/bar/components/AudioButton.qml" "$QS_CONFIG/modules/bar/components/AudioButton.qml"
cp "$ROOT/modules/bar/popouts/TimerPopout.qml" "$QS_CONFIG/modules/bar/popouts/TimerPopout.qml"
cp "$ROOT/modules/bar/popouts/AiPopout.qml" "$QS_CONFIG/modules/bar/popouts/AiPopout.qml"
cp "$ROOT/modules/bar/popouts/AudioPopout.qml" "$QS_CONFIG/modules/bar/popouts/AudioPopout.qml"
cp "$ROOT/modules/nexus/pages/audio/AppVolumes.qml" "$QS_CONFIG/modules/nexus/pages/audio/AppVolumes.qml"
cp "$ROOT/modules/nexus/pages/AudioPage.qml" "$QS_CONFIG/modules/nexus/pages/AudioPage.qml"
cp -r "$ROOT/modules/bar/popouts/icons/"* "$QS_CONFIG/modules/bar/popouts/icons/"
cp "$ROOT/modules/sidebar/Content.qml" "$QS_CONFIG/modules/sidebar/Content.qml"
cp "$ROOT/services/CaelestiaGit.qml" "$QS_CONFIG/services/CaelestiaGit.qml"
cp "$ROOT/services/NotesStore.qml" "$QS_CONFIG/services/NotesStore.qml"
cp "$ROOT/services/TimerService.qml" "$QS_CONFIG/services/TimerService.qml"
cp "$ROOT/services/AiService.qml" "$QS_CONFIG/services/AiService.qml"
cp "$ROOT/services/Audio.qml" "$QS_CONFIG/services/Audio.qml"

# 2. Patch Quickshell core files idempotently
python3 - "$QS_CONFIG" <<'PY'
import pathlib
import sys

qs = pathlib.Path(sys.argv[1])

def edit_file(path: pathlib.Path, old: str, new: str, marker: str, label: str):
    if not path.exists():
        print(f"  [-] Skipping {label}: file not found")
        return
    text = path.read_text(encoding="utf-8")
    if marker in text:
        print(f"  [=] Already present: {label}")
        return
    if old not in text:
        print(f"  [!] Anchor not found for: {label} in {path.name}")
        return
    text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")
    print(f"  [+] Patched: {label}")

# --- shell.qml cleanup ---
shell = qs / "shell.qml"
if shell.exists():
    text = shell.read_text(encoding="utf-8")
    if 'import "modules/aitab"\n' in text:
        text = text.replace('import "modules/aitab"\n', "")
        shell.write_text(text, encoding="utf-8")
        print("  [+] Removed aitab import from shell.qml")
    if '\n    AiSlideTab {}\n' in text:
        text = text.replace('\n    AiSlideTab {}\n', "\n")
        shell.write_text(text, encoding="utf-8")
        print("  [+] Removed AiSlideTab component from shell.qml")

# --- modules/dashboard/Content.qml ---
content = qs / "modules/dashboard/Content.qml"
if content.exists():
    text = content.read_text(encoding="utf-8")
    if "import qs.modules.gitpanel" not in text:
        edit_file(content,
                  "import qs.components.filedialog\n",
                  "import qs.components.filedialog\nimport qs.modules.gitpanel\n",
                  "import qs.modules.gitpanel",
                  "Content.qml gitpanel import")

    if "notesComponent" not in text:
        edit_file(content,
                  """            {
                component: mediaComponent,
                iconName: "music_note",
                text: Tr.tr("Media"),
                enabled: Config.dashboard.showMedia
            },""",
                  """            {
                component: mediaComponent,
                iconName: "music_note",
                text: Tr.tr("Media"),
                enabled: Config.dashboard.showMedia
            },
            {
                component: notesComponent,
                iconName: "edit_note",
                text: Tr.tr("Notes"),
                enabled: true
            },""",
                  "notesComponent",
                  "Content.qml Notes tab entry")

    if "gitPanelComponent" not in text:
        edit_file(content,
                  """            {
                component: weatherComponent,
                iconName: "cloud",
                text: Tr.tr("Weather"),
                enabled: Config.dashboard.showWeather
            }
        ];""",
                  """            {
                component: weatherComponent,
                iconName: "cloud",
                text: Tr.tr("Weather"),
                enabled: Config.dashboard.showWeather
            },
            {
                component: gitPanelComponent,
                iconName: "account_tree",
                text: Tr.tr("Git"),
                enabled: true
            }
        ];""",
                  "gitPanelComponent",
                  "Content.qml Git tab entry")

    if "NotesTab {}" not in text:
        edit_file(content,
                  """            Component {
                id: mediaComponent

                MediaTab {}
            }""",
                  """            Component {
                id: mediaComponent

                MediaTab {}
            }

            Component {
                id: notesComponent

                NotesTab {}
            }""",
                  "NotesTab {}",
                  "Content.qml NotesComponent definition")

    if "gitPanelComponent" not in text:
        edit_file(content,
                  """            Component {
                id: weatherComponent

                WeatherTab {}
            }""",
                  """            Component {
                id: weatherComponent

                WeatherTab {}
            }

            Component {
                id: gitPanelComponent

                GitPanel {
                    screenState: root.screenState
                }
            }""",
                  "gitPanelComponent",
                  "Content.qml GitPanel definition")

# --- modules/bar/Bar.qml ---
bar = qs / "modules/bar/Bar.qml"
if bar.exists():
    text = bar.read_text(encoding="utf-8")
    if 'id === "ai"' not in text:
        edit_file(bar,
                  """                if (!res.some(e => e.id === "timer")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "timer", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                return res;""",
                  """                if (!res.some(e => e.id === "timer")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "timer", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                if (!res.some(e => e.id === "ai")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "ai", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                if (!res.some(e => e.id === "audio")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "audio", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                return res;""",
                  'id === "ai"',
                  "Bar.qml ai/audio entry injection")

    if 'id === "audio"' not in text:
        edit_file(bar,
                  """                if (!res.some(e => e.id === "ai")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "ai", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                return res;""",
                  """                if (!res.some(e => e.id === "ai")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "ai", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                if (!res.some(e => e.id === "audio")) {
                    const statusIdx = res.findIndex(e => e.id === "statusIcons");
                    const insertIdx = statusIdx >= 0 ? statusIdx : Math.max(0, res.length - 1);
                    res = [
                        ...res.slice(0, insertIdx),
                        { id: "audio", enabled: true },
                        ...res.slice(insertIdx)
                    ];
                }
                return res;""",
                  'id === "audio"',
                  "Bar.qml audio entry injection")

    if "AudioButton" not in text:
        edit_file(bar,
                  """            DelegateChoice {
                roleValue: "ai"
                delegate: EntryWrapper {
                    AiButton {
                        objectName: "taskbarAiButton"
                        screenState: root.screenState
                        bar: root
                        popouts: root.popouts
                    }
                }
            }""",
                  """            DelegateChoice {
                roleValue: "ai"
                delegate: EntryWrapper {
                    AiButton {
                        objectName: "taskbarAiButton"
                        screenState: root.screenState
                        bar: root
                        popouts: root.popouts
                    }
                }
            }
            DelegateChoice {
                roleValue: "audio"
                delegate: EntryWrapper {
                    AudioButton {
                        objectName: "taskbarAudioButton"
                        screenState: root.screenState
                        bar: root
                        popouts: root.popouts
                    }
                }
            }""",
                  "AudioButton {}",
                  "Bar.qml AudioButton delegate")

# --- modules/bar/popouts/Content.qml ---
popouts_content = qs / "modules/bar/popouts/Content.qml"
if popouts_content.exists():
    text = popouts_content.read_text(encoding="utf-8")
    if 'name: "ai"' not in text:
        edit_file(popouts_content,
                  """        Popout {
            name: "lockstatus"
            sourceComponent: LockStatus {}
        }""",
                  """        Popout {
            name: "lockstatus"
            sourceComponent: LockStatus {}
        }

        Popout {
            name: "timer"
            sourceComponent: TimerPopout {
                popouts: root.popouts
            }
        }

        Popout {
            name: "ai"
            sourceComponent: AiPopout {
                popouts: root.popouts
            }
        }""",
                  'name: "ai"',
                  "Content.qml ai & timer popout definitions")

# --- modules/drawers/ContentWindow.qml ---
window = qs / "modules/drawers/ContentWindow.qml"
if window.exists():
    text = window.read_text(encoding="utf-8")
    if "screenState.dashboard ? WlrKeyboardFocus.OnDemand" not in text:
        edit_file(window,
                  "WlrLayershell.keyboardFocus: screenState.launcher || screenState.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None",
                  "WlrLayershell.keyboardFocus: screenState.launcher || screenState.session || screenState.dashboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None",
                  "screenState.dashboard ? WlrKeyboardFocus.OnDemand",
                  "ContentWindow.qml keyboard focus for dashboard")

# --- modules/Shortcuts.qml ---
shortcuts = qs / "modules/Shortcuts.qml"
if shortcuts.exists():
    text = shortcuts.read_text(encoding="utf-8")
    if 'name: "gitpanel"' not in text:
        edit_file(shortcuts,
                  '    // qmllint disable unresolved-type\n    CustomShortcut {\n        // qmllint enable unresolved-type\n        name: "session"',
                  """    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "gitpanel"
        description: "Toggle Caelestia Git panel"
        onPressed: {
            if (root.hasFullscreen)
                return;
            CaelestiaGit.toggleDashboard();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "session\"""",
                  'name: "gitpanel"',
                  "Shortcuts.qml gitpanel shortcut")

    if 'target: "gitpanel"' not in text:
        edit_file(shortcuts,
                  '    IpcHandler {\n        function toggle(drawer: string): void {',
                  """    IpcHandler {
        function open(): void {
            CaelestiaGit.openDashboard();
        }

        function toggle(): void {
            CaelestiaGit.toggleDashboard();
        }

        function select(repo: string): void {
            CaelestiaGit.selectByName(repo);
        }

        function refresh(): void {
            CaelestiaGit.refresh();
        }

        target: "gitpanel"
    }

    IpcHandler {
        function toggle(drawer: string): void {""",
                  'target: "gitpanel"',
                  "Shortcuts.qml gitpanel IPC handler")

    if 'target: "ai"' not in text:
        edit_file(shortcuts,
                  '    IpcHandler {\n        function toggle(drawer: string): void {',
                  """    IpcHandler {
        function scan(): void {
            AiService.scan();
        }

        function launch(tool: string): void {
            AiService.launch(tool);
        }

        target: "ai"
    }

    IpcHandler {
        function start(sec: int): void {
            TimerService.startTimer(sec);
        }

        function stop(): void {
            TimerService.stopTimer();
        }

        function toggle(): void {
            TimerService.togglePause();
        }

        function add(min: int): void {
            TimerService.addMinutes(min);
        }

        target: "timer"
    }

    IpcHandler {
        function toggle(drawer: string): void {""",
                  'target: "ai"',
                  "Shortcuts.qml ai & timer IPC handlers")

PY

echo "[+] Quickshell add-ons successfully installed and updated!"
