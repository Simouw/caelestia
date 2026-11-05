#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
#  Simouw Caelestia Ecosystem Installer
#  Dotfiles & Desktop Shell based on Caelestia, with Neovim, Helium Browser,
#  AI CLIs (OpenCode, Codex, Antigravity), Caelestia Notes & Git Panel.
# ==============================================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "============================================================"
echo "  Installing Simouw's Caelestia Ecosystem"
echo "============================================================"
echo ""

# 1. Ensure target directories exist
mkdir -p "$CONFIG_DIR/hypr" \
         "$CONFIG_DIR/caelestia" \
         "$CONFIG_DIR/nvim" \
         "$CONFIG_DIR/foot" \
         "$CONFIG_DIR/fastfetch" \
         "$CONFIG_DIR/btop" \
         "$BIN_DIR"

# 2. Check / Auto-install AI CLIs by default (OpenCode, Codex, Antigravity)
echo "[+] Checking AI CLIs (OpenCode, Codex, Antigravity)..."
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
fi

# OpenCode CLI
if command -v opencode >/dev/null 2>&1; then
  echo "  ✓ opencode ($(command -v opencode))"
else
  echo "  [+] Installing OpenCode CLI..."
  if [[ -n "$AUR_HELPER" ]]; then
    "$AUR_HELPER" -S --needed --noconfirm opencode || true
  else
    curl -fsSL https://opencode.ai/install | bash || true
  fi
fi

# OpenAI Codex CLI
if command -v codex >/dev/null 2>&1; then
  echo "  ✓ codex ($(command -v codex))"
else
  echo "  [+] Installing OpenAI Codex CLI (openai-codex-bin)..."
  if [[ -n "$AUR_HELPER" ]]; then
    "$AUR_HELPER" -S --needed --noconfirm openai-codex-bin || true
  else
    echo "    ! AUR helper not found; please install 'openai-codex-bin' via your package manager."
  fi
fi

# Antigravity CLI (agy)
if command -v agy >/dev/null 2>&1; then
  echo "  ✓ agy ($(command -v agy))"
elif [[ -f "$HOME/.local/bin/agy" ]]; then
  echo "  ✓ agy found in ~/.local/bin/agy"
else
  echo "  [!] Antigravity 'agy' CLI not found. If installed elsewhere, link it to ~/.local/bin/agy"
fi

# 3. Deploy Caelestia custom configurations & scripts
echo ""
echo "[+] Deploying ~/.config/caelestia (hypr-user, hypr-vars, cheatsheet, wallpapers)..."
cp -r "$ROOT/caelestia/"* "$CONFIG_DIR/caelestia/"
chmod +x "$CONFIG_DIR/caelestia/"*.sh "$CONFIG_DIR/caelestia/"*.py 2>/dev/null || true

# 4. Deploy Hyprland configuration
echo "[+] Deploying ~/.config/hypr..."
cp -r "$ROOT/hypr/"* "$CONFIG_DIR/hypr/"

# 5. Deploy full Neovim configuration (LazyVim + Caelestia)
echo "[+] Deploying ~/.config/nvim..."
cp -r "$ROOT/nvim/"* "$CONFIG_DIR/nvim/"
# Copy hidden files
cp "$ROOT/nvim/".* "$CONFIG_DIR/nvim/" 2>/dev/null || true

# 6. Deploy Foot terminal configuration
echo "[+] Deploying ~/.config/foot..."
cp -r "$ROOT/foot/"* "$CONFIG_DIR/foot/"

# 7. Deploy Fastfetch configuration
echo "[+] Deploying ~/.config/fastfetch..."
cp -r "$ROOT/fastfetch/"* "$CONFIG_DIR/fastfetch/"

# 8. Deploy Btop configuration
echo "[+] Deploying ~/.config/btop..."
cp -r "$ROOT/btop/"* "$CONFIG_DIR/btop/"

# 9. Deploy system scripts to ~/.local/bin
echo "[+] Deploying scripts to $BIN_DIR (mic, caelestia-git-bridge)..."
cp -r "$ROOT/bin/"* "$BIN_DIR/"
chmod +x "$BIN_DIR/mic" "$BIN_DIR/caelestia-git-bridge" 2>/dev/null || true

# 10. Install Quickshell Add-ons if Quickshell exists
QS_TARGET="$CONFIG_DIR/quickshell/caelestia"
if [[ -d "$QS_TARGET" && -f "$ROOT/quickshell/install-quickshell-addons.sh" ]]; then
  echo ""
  echo "[+] Detected Caelestia Quickshell! Installing/updating add-ons..."
  bash "$ROOT/quickshell/install-quickshell-addons.sh"
else
  echo ""
  echo "[i] Quickshell config not yet found at $QS_TARGET."
  echo "    Once Caelestia shell is installed, run:"
  echo "      $ROOT/quickshell/install-quickshell-addons.sh"
fi

# 11. Reload Hyprland if running
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  echo ""
  echo "[+] Reloading Hyprland configuration..."
  hyprctl reload >/dev/null 2>&1 || true
fi

echo ""
echo "============================================================"
echo "  ✓ Installation complete!"
echo "============================================================"
echo "  • AI CLI Launchers : Right-edge slide tab (OpenCode, agy, Codex)"
echo "  • Default Browser  : Helium Browser (Super + W)"
echo "  • Default Editor   : Neovim in Foot (Super + C)"
echo "  • Top Bar Timer    : Click timer icon for Pomodoro / presets"
echo "  • Sidebar KB Switch: Click bottom button in sidebar to switch FR / US"
echo "  • Fast Git Glance  : Super + G (or Super + K -> Git)"
echo "  • Notes & Todos    : Super + K -> Notes tab"
echo "  • Cheatsheet       : Super + / or Super + H"
echo "  • Mic Toggle       : Super + Alt + M"
echo "============================================================"
