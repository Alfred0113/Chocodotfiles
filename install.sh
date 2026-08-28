#!/bin/bash
# Enlaza las carpetas de este repo a ~/.config/*, para dejar el escritorio
# funcionando en una instalación nueva. Si algo ya existe en el destino y no
# es un symlink hacia este repo, lo respalda con sufijo .pre-dotfiles-bak
# en vez de sobrescribirlo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Carpetas del repo que se enlazan 1:1 a ~/.config/<nombre>.
LINKED_DIRS=(hypr waybar)

for name in "${LINKED_DIRS[@]}"; do
    src="$REPO_DIR/$name"
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

echo "Listo. Revisa que tus paquetes (hyprland, waybar, mako, walker, etc.) estén instalados."
