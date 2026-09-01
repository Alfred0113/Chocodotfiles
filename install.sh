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
    "alacritty:alacritty"
    "kitty:kitty"
    "foot:foot"
    "ghostty:ghostty"
    "btop:btop"
    "swayosd:swayosd"
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

# config.jsonc de fastfetch se genera dinámicamente (el logo lleva el color
# de acento del tema) — se enlaza el archivo suelto a theming/current/, no
# una carpeta ni el archivo fuente.
FASTFETCH_DIR="$CONFIG_DIR/fastfetch"
mkdir -p "$FASTFETCH_DIR"
FASTFETCH_SRC="$REPO_DIR/theming/current/fastfetch-config.jsonc"
FASTFETCH_DEST="$FASTFETCH_DIR/config.jsonc"
if [ -L "$FASTFETCH_DEST" ] && [ "$(readlink -f "$FASTFETCH_DEST")" = "$(readlink -f "$FASTFETCH_SRC")" ]; then
    echo "OK: $FASTFETCH_DEST ya apunta a $FASTFETCH_SRC"
else
    if [ -e "$FASTFETCH_DEST" ] || [ -L "$FASTFETCH_DEST" ]; then
        backup="${FASTFETCH_DEST}.pre-dotfiles-bak"
        echo "Respaldando $FASTFETCH_DEST -> $backup"
        mv "$FASTFETCH_DEST" "$backup"
    fi
    ln -s "$FASTFETCH_SRC" "$FASTFETCH_DEST"
    echo "Enlazado: $FASTFETCH_DEST -> $FASTFETCH_SRC"
fi

# Dotfiles sueltos de $HOME (no viven bajo ~/.config). Se enlazan archivo por
# archivo desde home/ del repo. .XCompose necesita el include "%L" para que las
# teclas muertas (´ + a = á) funcionen en apps Qt/Wayland.
for home_src in "$REPO_DIR"/home/.*; do
    base="$(basename "$home_src")"
    case "$base" in .|..) continue ;; esac
    [ -f "$home_src" ] || continue
    home_dest="$HOME/$base"

    if [ -L "$home_dest" ] && [ "$(readlink -f "$home_dest")" = "$(readlink -f "$home_src")" ]; then
        echo "OK: $home_dest ya apunta a $home_src"
        continue
    fi

    if [ -e "$home_dest" ] || [ -L "$home_dest" ]; then
        backup="${home_dest}.pre-dotfiles-bak"
        echo "Respaldando $home_dest -> $backup"
        mv "$home_dest" "$backup"
    fi

    ln -s "$home_src" "$home_dest"
    echo "Enlazado: $home_dest -> $home_src"
done

# Tema de VS Code: aether ya regenera theming/current/vscode-extension/ en
# cada cambio de wallpaper (parte de su --output normal) — solo falta que la
# extensión instalada apunte ahí en vez de a una copia estática.
VSCODE_EXT_DIR="$HOME/.vscode/extensions"
VSCODE_SRC="$REPO_DIR/theming/current/vscode-extension"
VSCODE_DEST="$VSCODE_EXT_DIR/local.theme-aether-1.0.0"
if [ -d "$VSCODE_EXT_DIR" ]; then
    if [ -L "$VSCODE_DEST" ] && [ "$(readlink -f "$VSCODE_DEST")" = "$(readlink -f "$VSCODE_SRC")" ]; then
        echo "OK: $VSCODE_DEST ya apunta a $VSCODE_SRC"
    else
        if [ -e "$VSCODE_DEST" ] || [ -L "$VSCODE_DEST" ]; then
            backup="${VSCODE_DEST}.pre-dotfiles-bak"
            echo "Respaldando $VSCODE_DEST -> $backup"
            mv "$VSCODE_DEST" "$backup"
        fi
        ln -s "$VSCODE_SRC" "$VSCODE_DEST"
        echo "Enlazado: $VSCODE_DEST -> $VSCODE_SRC"
    fi
else
    echo "Aviso: $VSCODE_EXT_DIR no existe (¿VS Code no instalado?), se omite el tema." >&2
fi

echo "Listo. Revisa que tus paquetes estén instalados:"
echo "  hyprland waybar mako walker aether awww alacritty swayosd-server openrgb chafa tte imagemagick quickshell socat fastfetch"
echo "  ttf-jetbrains-mono-nerd (fuente usada en waybar/walker/selector/fastfetch — sin ella los íconos salen rotos)"
echo "  elephant elephant-bluetooth elephant-calc elephant-clipboard elephant-desktopapplications"
echo "  elephant-files elephant-menus elephant-providerlist elephant-runner elephant-symbols"
echo "  elephant-todo elephant-unicode elephant-websearch (proveedores de datos de walker, van aparte)"
echo "Falta copiar tus wallpapers a ~/Imágenes/Wallpapers/ (no viaja en este repo)."
echo "Corre 'systemctl --user daemon-reload && systemctl --user enable --now chocomazapan-battery-monitor.timer' para activar el monitor de batería."
echo "Vencord: instala 'vencord-installer-git' (AUR) y corre 'vencordinstallercli -install -branch stable' antes de abrir Discord."
echo "Obsidian: si tu vault vive en otra ruta en esta máquina, edita VAULT_DIR en bin/chocomazapan-obsidian-sync."
echo "Windows VM (chocomazapan-windows-vm): el docker-compose.yml y los discos NO viajan en este repo (son de esta"
echo "  máquina). En una máquina nueva corre 'chocomazapan-windows-vm install' para configurarlo desde cero."
