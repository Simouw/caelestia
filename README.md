# Caelestia Dotfiles (Simouw's Ecosystem)

> **A customized, productivity-focused desktop environment based on [Caelestia](https://github.com/caelestia-dots/caelestia), powered by Hyprland, Quickshell, Neovim, and Helium Browser.**

This repository contains my personal dotfiles and additions built on top of the Caelestia Wayland desktop suite. It is designed to be clean, modular, and easy to deploy on any Arch Linux machine.

---

## 🌟 Ecosystem Overview

Unlike default Caelestia setups configured around VSCode/Codium and Firefox/Zen, this rice centers around:

* **Default Browser** : **Helium Browser** (`helium-browser`), mapped to `Super + W`.
* **Default Editor** : **Neovim** in Foot terminal (`foot -e nvim`), mapped to `Super + C` (powered by LazyVim with full French typing/correction aids and custom themes).
* **Terminal** : **Foot** (customized Caelestia styling).
* **Keyboard Layout** : **AZERTY** (`fr`) with direct 1–10 workspace switching on physical keys (`&`, `é`, `"`, `'`, `(`, `-`, `è`, `_`, `ç`, `à`).
* **Integrated Notes & Todos** : Native **Caelestia Notes** tab inside the Quickshell Dashboard (`Super + K` → Notes).
* **Integrated Git Panel** : Native **Caelestia Git** tab inside the Quickshell Dashboard (`Super + G` or `Super + K` → Git) powered by `cmogit` / `caelestia-git-bridge`.
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

## 🙏 Credits & Acknowledgements

This setup stands on the shoulders of fantastic open-source projects. Heartfelt thanks to all the respective authors:

* **[Caelestia](https://github.com/caelestia-dots/caelestia)** & **[Caelestia Shell](https://github.com/caelestia-dots/shell)** — Created by the **caelestia-dots** team. The gorgeous Material You / morphing Wayland desktop shell that forms the foundation of this setup.
* **[Caelestia Notes](https://github.com/Denzils-repo/Caelestia_Notes)** — Created by **[Denzil](https://github.com/Denzils-repo)**. The lightweight Markdown note renderer, repeating daily habits, streak tracking, and to-do dashboard tab for Caelestia Quickshell.
* **[Caelestia Git Panel](https://github.com/Simouw/caelestia-git)** — Native Git panel for the Caelestia dashboard by **[Simouw](https://github.com/Simouw)**.
* **[GitXplorer (GitX)](https://github.com/Simouw/GitX)** — Desktop Git application and backend automation CLI (`cmogit`) by **[Simouw](https://github.com/Simouw)**.
* **[LazyVim](https://github.com/LazyVim/LazyVim)** — Created by **[Folke](https://github.com/folke)**. The modern, blazing-fast Neovim setup.
* **[Helium Browser](https://github.com/helium-browser)** — Modern web browser.

---

## 📄 License

This repository inherits the **GNU General Public License v3.0 (GPL-3.0)** from upstream Caelestia. Individual add-ons and components are licensed under their respective authors' terms.
