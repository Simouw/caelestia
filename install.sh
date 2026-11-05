#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
#  Simouw Caelestia Ecosystem Installer
#  Dotfiles & Desktop Shell based on Caelestia, with Neovim, Helium Browser,
#  Caelestia Notes & Caelestia Git Panel.
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

# 2. Deploy Caelestia custom configurations & scripts
echo "[+] Deploying ~/.config/caelestia (hypr-user, hypr-vars, cheatsheet, wallpapers)..."
cp -r "$ROOT/caelestia/"* "$CONFIG_DIR/caelestia/"
chmod +x "$CONFIG_DIR/caelestia/"*.sh "$CONFIG_DIR/caelestia/"*.py 2>/dev/null || true

# 3. Deploy Hyprland configuration
echo "[+] Deploying ~/.config/hypr..."
cp -r "$ROOT/hypr/"* "$CONFIG_DIR/hypr/"

# 4. Deploy full Neovim configuration (LazyVim + Caelestia)
echo "[+] Deploying ~/.config/nvim..."
cp -r "$ROOT/nvim/"* "$CONFIG_DIR/nvim/"
# Copy hidden files
cp "$ROOT/nvim/".* "$CONFIG_DIR/nvim/" 2>/dev/null || true

# 5. Deploy Foot terminal configuration
echo "[+] Deploying ~/.config/foot..."
cp -r "$ROOT/foot/"* "$CONFIG_DIR/foot/"

# 6. Deploy Fastfetch configuration
echo "[+] Deploying ~/.config/fastfetch..."
cp -r "$ROOT/fastfetch/"* "$CONFIG_DIR/fastfetch/"

# 7. Deploy Btop configuration
echo "[+] Deploying ~/.config/btop..."
cp -r "$ROOT/btop/"* "$CONFIG_DIR/btop/"

# 8. Deploy system scripts to ~/.local/bin
echo "[+] Deploying scripts to $BIN_DIR (mic, caelestia-git-bridge)..."
cp -r "$ROOT/bin/"* "$BIN_DIR/"
chmod +x "$BIN_DIR/mic" "$BIN_DIR/caelestia-git-bridge" 2>/dev/null || true

# 9. Install Quickshell Add-ons (Notes, Git Panel) if Quickshell exists
QS_TARGET="$CONFIG_DIR/quickshell/caelestia"
if [[ -d "$QS_TARGET" && -f "$ROOT/quickshell/install-quickshell-addons.sh" ]]; then
  echo ""
  echo "[+] Detected Caelestia Quickshell! Installing add-ons (Notes + Git Panel)..."
  bash "$ROOT/quickshell/install-quickshell-addons.sh"
else
  echo ""
  echo "[i] Quickshell config not yet found at $QS_TARGET."
  echo "    Once Caelestia shell is installed, run:"
  echo "      $ROOT/quickshell/install-quickshell-addons.sh"
fi

# 10. Reload Hyprland if running
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  echo ""
  echo "[+] Reloading Hyprland configuration..."
  hyprctl reload >/dev/null 2>&1 || true
fi

echo ""
echo "============================================================"
echo "  ✓ Installation complete!"
echo "============================================================"
echo "  • Default Browser : Helium Browser (Super + W)"
echo "  • Default Editor  : Neovim in Foot (Super + C)"
echo "  • Git Panel       : Super + G (or Super + K -> Git)"
echo "  • Notes & Todos   : Super + K -> Notes tab"
echo "  • Cheatsheet      : Super + / or Super + H"
echo "  • Mic Toggle      : Super + Alt + M"
echo "  • Wallpapers      : Super + Shift + W (gallery) | Super + Alt + W (random)"
echo "============================================================"
