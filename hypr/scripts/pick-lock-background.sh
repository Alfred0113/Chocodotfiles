#!/bin/bash
# Picks a random wallpaper (>=1920x1080) from ~/Imágenes/Wallpapers,
# for use as hyprlock's background via reload_cmd.
#
# Scanning every image with `identify` on each lock is too slow once the
# folder has many/large files, so the list of valid (big enough) images is
# cached and only rebuilt when the folder's contents change.

BG_DIR="$HOME/Imágenes/Wallpapers"
CACHE_FILE="$HOME/dotfiles/theming/current/lockscreen-bg-cache"
MIN_W=1920
MIN_H=1080

mkdir -p "$(dirname "$CACHE_FILE")"

dir_signature() {
    find "$BG_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -printf '%f %s\n' 2>/dev/null | sort | md5sum
}

rebuild_cache() {
    : > "$CACHE_FILE"
    while IFS= read -r -d '' file; do
        dims=$(identify -format "%w %h" "$file" 2>/dev/null) || continue
        w=${dims% *}
        h=${dims#* }
        [ "$w" -ge "$MIN_W" ] && [ "$h" -ge "$MIN_H" ] && echo "$file" >> "$CACHE_FILE"
    done < <(find "$BG_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 2>/dev/null)
    dir_signature > "$CACHE_FILE.sig"
}

current_sig="$(dir_signature)"
cached_sig="$(cat "$CACHE_FILE.sig" 2>/dev/null || echo "")"

if [ ! -f "$CACHE_FILE" ] || [ "$current_sig" != "$cached_sig" ]; then
    rebuild_cache
fi

if [ -s "$CACHE_FILE" ]; then
    shuf -n1 "$CACHE_FILE"
else
    find "$BG_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | head -n1
fi
