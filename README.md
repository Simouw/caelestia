# Caelestia Dotfiles (Simouw's Ecosystem)

> **A customized, productivity-focused desktop environment based on [Caelestia](https://github.com/caelestia-dots/caelestia), powered by Hyprland, Quickshell, Neovim, and Helium Browser.**

This repository contains my personal dotfiles and additions built on top of the Caelestia Wayland desktop suite. It is designed to be clean, modular, and easy to deploy on any Arch Linux machine.

---

## 🌟 Ecosystem Overview

Unlike default Caelestia setups configured around VSCode/Codium and Firefox/Zen, this rice centers around:

* **Default Browser** : **Helium Browser** (`helium-browser`), mapped to `Super + W`.
* **Default Editor** : **Neovim** in Foot terminal (`foot -e nvim`), mapped to `Super + C` (powered by LazyVim with full French typing/correction aids and custom themes).
* **AI CLI Launcher** : Dedicated button in the Caelestia bar (`auto_awesome`). Displays instant status badges for installed vs uninstalled AI CLIs (**OpenCode**, **Antigravity (`agy`)**, **Codex**, and **Claude**) and launches them directly into the active workspace as a standard tiled terminal (`foot -e <cli>`).
* **AI Tooling by Default** : Auto-installs **OpenCode CLI**, **OpenAI Codex CLI**, and **Antigravity CLI** (`agy`).
* **Terminal** : **Foot** (customized Caelestia styling with standard tiling workspace integration).
* **Keyboard Layout Switcher** : **AZERTY (`fr`) & QWERTY (`us`)** support. Click the keyboard indicator at the bottom of the Caelestia sidebar (`Super + N`) to switch instantaneously between French and US layouts.
* **Top Bar Timer & Pomodoro** : Integrated timer widget in the top bar. Click to select 5m, 15m, 25m (Pomodoro), or 50m presets, with live countdown and audio/OSD completion alert.
* **Streamlined Git Status Glance** : Lightweight, zero-lag **Caelestia Git** tab inside the Dashboard (`Super + G` or `Super + K` → Git) showing clean working tree overview, branch sync status, changed files, and a one-click *"Open in GitX"* button.
* **Integrated Notes & Todos** : Native **Caelestia Notes** tab inside the Quickshell Dashboard (`Super + K` → Notes).
* **Visual Wallpaper Gallery** : Interactive 3x3 wallpaper preview and switcher (`Super + Shift + W`), plus instant random wallpaper toggle (`Super + Alt + W`).
* **Microphone Mute Toggle** : Global mute toggle with OSD notifications (`Super + Alt + M`).
* **Keyboard Cheatsheet** : Instant fuzzy shortcut cheatsheet (`Super + /` or `Super + H`).

---

## 📂 Repository Structure

```
.
├── bin/                          # Helper scripts installed to ~/.local/bin
│   ├── mic                       # Microphone toggle & notification script
│   └── caelestia-git-bridge      # Node.js bridge for Caelestia Git panel
├── btop/                         # Btop system monitor theme
├── caelestia/                    # Personal Caelestia overrides (~/.config/caelestia)
│   ├── cheatsheet.sh             # Rofi/Fuzzel shortcut cheatsheet
│   ├── hypr-user.lua             # Hyprland layout, binds, autostarts
│   ├── hypr-vars.lua             # Default app overrides (Helium, Neovim)
│   ├── notes.default.json        # Initial notes template
│   ├── rofi_wallpaper_helper.py  # Thumbnail generator helper
│   ├── shell.json                # Quickshell unit & visual options
│   └── wallpaper-gallery.sh      # 3x3 wallpaper gallery
├── fastfetch/                    # Fastfetch system info layout
├── fish/                         # Clean Caelestia fish shell integration
├── foot/                         # Foot terminal configuration
├── hypr/                         # Hyprland configuration (Lua-based)
│   ├── hyprland.lua              # Main loader
│   ├── variables.lua             # Keybinds & default variables
│   └── hyprland/keybinds.lua     # Core binds including Git panel
├── nvim/                         # Complete LazyVim + Caelestia Neovim config
│   ├── init.lua
│   ├── lua/                      # Config & plugins
│   ├── colors/                   # Base2Tone & Caelestia colorschemes
│   └── ftdetect/ & syntax/       # Custom syntax helpers
├── quickshell/                   # Quickshell add-ons (Notes, GitPanel, Bar)
│   ├── modules/                  # QML modules (gitpanel, notes, NotesButton)
│   ├── services/                 # CaelestiaGit.qml & NotesStore.qml
│   └── install-quickshell-addons.sh # Automated Quickshell patcher
├── install.sh                    # Unified one-command installer
└── manifest.toml                 # Caelestia CLI manifest
```

---

## 🚀 Installation

### Automated Install (Recommended)

1. Clone this repository:
   ```bash
   git clone https://github.com/Simouw/caelestia.git ~/code/caelestia
   cd ~/code/caelestia
   ```

2. Run the master installer:
   ```bash
   ./install.sh
   ```

The script will:
* Deploy all configuration files into `~/.config/` (`hypr`, `caelestia`, `nvim`, `foot`, `fastfetch`, `btop`).
* Deploy `mic` and `caelestia-git-bridge` to `~/.local/bin/`.
* Automatically patch and install Quickshell add-ons (Notes & Git Panel) if Quickshell is detected.
* Reload Hyprland.

---

## ⌨️ Keybindings Summary

### Applications & Launchers
| Keybind | Action |
| :--- | :--- |
| `Super` *(tap)* | Open Caelestia launcher |
| `Super + W` | Launch **Helium Browser** |
| `Super + C` | Launch **Neovim** in Foot |
| `Super + T` | Open Foot terminal |
| `Super + E` | Open Thunar file manager |
| `Super + /` or `Super + H` | Open **Shortcuts Cheatsheet** |

### Desktop Shell & Panels
| Keybind | Action |
| :--- | :--- |
| `Super + G` | Open / Toggle **Git Panel** |
| `Super + K` | Open all shell panels & Dashboard (Notes, Git, Weather, Media) |
| `Super + N` | Toggle sidebar (Controls & Notifications) |
| `Ctrl + Alt + Delete` | Session menu (Lock, Reboot, Poweroff) |
| `Ctrl + Alt + C` | Clear notifications |
| `Ctrl + Super + Alt + R` | Restart Caelestia shell |

### Wallpapers & Media
| Keybind | Action |
| :--- | :--- |
| `Super + Shift + W` | Open **Wallpaper Gallery** (visual 3x3 grid) |
| `Super + Alt + W` | Switch to a random wallpaper |
| `Super + Alt + M` | Toggle **Microphone Mute** (with OSD notification) |
| `Super + Shift + M` | Toggle Speakers Mute |

---

## 🎧 Audio & Shell Enhancements

* **Per-App Audio Control & Routing**: Fine-grained per-app volume sliders, quick mute toggles, stream target routing, and combined multi-output playback directly in the bar popout and Nexus audio settings.
* **Animated Dial Timer Widget**: Clock face widget in the vertical taskbar with a real-time revolving progress hand and playful vibration / tremble ringing animation when the timer expires.

---

## 🙏 Credits & Acknowledgements

This setup stands on the shoulders of fantastic open-source projects. Heartfelt thanks to all the respective authors for their incredible work:

* **[Caelestia](https://github.com/caelestia-dots/caelestia)** & **[Caelestia Shell](https://github.com/caelestia-dots/shell)** — Created by the **[caelestia-dots](https://github.com/caelestia-dots)** team. The gorgeous Material You / morphing Wayland desktop shell that forms the complete foundation of this setup.
* **[Caelestia Notes](https://github.com/Denzils-repo/Caelestia_Notes)** — Created entirely by **[Denzil](https://github.com/Denzils-repo)** (`@Denzils-repo`). The lightweight Markdown note renderer, repeating daily habits, streak tracking, to-do list, and topbar widget for Caelestia Quickshell. Integrated into this rice with full attribution.
* **[op-caelestia-shell](https://github.com/OVERxPOWERED/op-caelestia-shell)** — Created by **[OVERxPOWERED](https://github.com/OVERxPOWERED)** (`@OVERxPOWERED`). Per-app audio routing & volume controls, multi-output combination, and enhanced PipeWire stream management.
* **[Helium Browser](https://github.com/imputnet/helium)** — Created by the **[Imputnet](https://github.com/imputnet)** team. Minimalist, fast, and privacy-first web browser used as the default browser (`Super + W`).
* **[LazyVim](https://github.com/LazyVim/LazyVim)** — Created by **[Folke Lemaitre](https://github.com/folke)** (`@folke`). The modern, blazing-fast Neovim distribution powering our editor configuration.
* **[Base2Tone Colorschemes](https://github.com/atelierbram/Base2Tone)** — Created by **[Bram de Haan](https://github.com/atelierbram)** (`@atelierbram`). Elegant duotone syntax highlighting themes.
* **[Hyprland](https://github.com/hyprwm/Hyprland)** — Created by **[Vaxry](https://github.com/vaxerski)** and the **hyprwm** team. The dynamic tiling Wayland compositor.
* **[Quickshell](https://github.com/outfoxxed/quickshell)** — Created by **[Outfoxxed](https://github.com/outfoxxed)**. The flexible Qt Quick desktop shell framework powering Caelestia.
* **AI Tooling & CLIs**:
  * **[OpenCode](https://github.com/opencode-ai)** — Autonomous AI coding CLI.
  * **[Codex](https://github.com/openai)** — OpenAI Codex command-line interface.
  * **[Antigravity (`agy`)](https://github.com/google-deepmind)** — Agentic AI coding assistant by Google DeepMind.
* **Personal Additions by [Simouw](https://github.com/Simouw)**:
  * **[Caelestia Git Panel](https://github.com/Simouw/caelestia-git)** — 100% standalone, zero-dependency Git status dashboard for the Caelestia shell.
  * **[GitXplorer (GitX)](https://github.com/Simouw/GitX)** — Companion desktop Git visualizer and manager.
  * Topbar AI assistant popout launcher, topbar timer widget, AZERTY/QWERTY layout switcher, unified installer, wallpaper gallery, and Neovim customizations.

---

## 📄 License

This repository inherits the **GNU General Public License v3.0 (GPL-3.0)** from upstream Caelestia. Individual add-ons and components are licensed under their respective authors' terms.
