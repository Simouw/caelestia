#!/bin/bash
export LC_ALL=C.UTF-8
DIR="$HOME/Pictures/bgs"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$CACHE_DIR"

# Mise a jour des miniatures en arriere-plan
for img in "$DIR"/*; do
    [ -f "$img" ] || continue
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name%.*}.png"
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        ffmpeg -y -i "$img" -vf "scale=240:135:force_original_aspect_ratio=increase,crop=240:135" -vframes 1 "$thumb" -loglevel error &
    fi
done
wait

THEME_STR='
    window {
        width: 880px;
        height: 560px;
        border-radius: 16px;
    }
    listview {
        columns: 3;
        lines: 3;
        cycle: true;
        dynamic: true;
        layout: vertical;
        flow: horizontal;
        spacing: 12px;
    }
    element {
        orientation: vertical;
        padding: 10px;
        border-radius: 12px;
    }
    element-icon {
        size: 135px;
        horizontal-align: 0.5;
    }
    element-text {
        horizontal-align: 0.5;
        padding: 6px 0 0 0;
        font: "JetBrainsMono Nerd Font 9";
    }
'

CHOICE=$(python3 "$HOME/.config/caelestia/rofi_wallpaper_helper.py" | rofi -dmenu -i -show-icons -p "󰸉 Galerie Fonds d'Écran" -theme-str "$THEME_STR")

if [ -n "$CHOICE" ] && [ -f "$DIR/$CHOICE" ]; then
    caelestia wallpaper -f "$DIR/$CHOICE"
fi
