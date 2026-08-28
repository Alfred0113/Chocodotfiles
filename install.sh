#!/bin/bash
# Enlaza las carpetas de este repo a ~/.config/*, para dejar el escritorio
# funcionando en una instalación nueva. Si algo ya existe en el destino y no
# es un symlink hacia este repo, lo respalda con sufijo .pre-dotfiles-bak
# en vez de sobrescribirlo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Pares "carpeta del repo -> ~/.config/<nombre>". La mayoría se llama igual
# de los dos lados; matugen/wallust viven anidados dentro de theming/engines.
LINKED_DIRS=(
    "hypr:hypr"
    "waybar:waybar"
    "mako:mako"
    "walker:walker"
    "uwsm:uwsm"
    "theming:theming"
    "theming/engines/matugen:matugen"
    "theming/engines/wallust:wallust"
)

for pair in "${LINKED_DIRS[@]}"; do
    src_rel="${pair%%:*}"
    name="${pair##*:}"
    src="$REPO_DIR/$src_rel"
    dest="$CONFIG_DIR/$name"

    if [ ! -d "$src" ]; then
        echo "Aviso: $src no existe, se omite." >&2
        continue
    fi

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        echo "OK: $dest ya apunta a $src"
        continue
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="${dest}.pre-dotfiles-bak"
        echo "Respaldando $dest -> $backup"
        mv "$dest" "$backup"
    fi

    ln -s "$src" "$dest"
    echo "Enlazado: $dest -> $src"
done

# Unidades systemd --user individuales (no se enlaza la carpeta completa
# porque ahí también viven otras unidades ajenas a este repo).
SYSTEMD_DIR="$CONFIG_DIR/systemd/user"
mkdir -p "$SYSTEMD_DIR"
for unit_src in "$REPO_DIR"/systemd/user/*; do
    [ -f "$unit_src" ] || continue
    unit_name="$(basename "$unit_src")"
    unit_dest="$SYSTEMD_DIR/$unit_name"

    if [ -L "$unit_dest" ] && [ "$(readlink -f "$unit_dest")" = "$(readlink -f "$unit_src")" ]; then
        echo "OK: $unit_dest ya apunta a $unit_src"
        continue
    fi

    if [ -e "$unit_dest" ] || [ -L "$unit_dest" ]; then
        backup="${unit_dest}.pre-dotfiles-bak"
        echo "Respaldando $unit_dest -> $backup"
        mv "$unit_dest" "$backup"
    fi

    ln -s "$unit_src" "$unit_dest"
    echo "Enlazado: $unit_dest -> $unit_src"
done

echo "Listo. Revisa que tus paquetes (hyprland, waybar, mako, walker, matugen, wallust, swaybg) estén instalados."
echo "Falta copiar tus wallpapers a ~/Imágenes/Wallpapers/ (no viaja en este repo)."
echo "Corre 'systemctl --user daemon-reload && systemctl --user enable --now chocomazapan-battery-monitor.timer' para activar el monitor de batería."
