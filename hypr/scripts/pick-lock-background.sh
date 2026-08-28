#!/bin/bash
# Picks a random wallpaper (>=1920x1080) from the active Omarchy theme's
# backgrounds folder, for use as hyprlock's background via reload_cmd.

BG_DIR="$HOME/.config/omarchy/current/theme/backgrounds"
MIN_W=1920
MIN_H=1080

candidates=()
while IFS= read -r -d '' file; do
    dims=$(identify -format "%w %h" "$file" 2>/dev/null) || continue
    w=${dims% *}
    h=${dims#* }
    [ "$w" -ge "$MIN_W" ] && [ "$h" -ge "$MIN_H" ] && candidates+=("$file")
done < <(find "$BG_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0 2>/dev/null)

if [ ${#candidates[@]} -eq 0 ]; then
    while IFS= read -r -d '' file; do
        candidates+=("$file")
    done < <(find "$BG_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0 2>/dev/null)
fi

if [ ${#candidates[@]} -eq 0 ]; then
    readlink -f "$HOME/.config/omarchy/current/background"
else
    echo "${candidates[$((RANDOM % ${#candidates[@]}))]}"
fi
