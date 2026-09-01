#!/bin/bash
# Enlaza las carpetas de este repo a ~/.config/*, para dejar el escritorio
# funcionando en una instalación nueva. Si algo ya existe en el destino y no
# es un symlink hacia este repo, lo respalda con sufijo .pre-dotfiles-bak
# en vez de sobrescribirlo.
#
# Orden recomendado en una máquina nueva:
#   1. Instala los paquetes (este script los lista al final y marca los que faltan).
#   2. Copia tus wallpapers a ~/Imágenes/Wallpapers/ (no viajan en el repo).
#   3. Corre este script DENTRO de la sesión de Hyprland ya iniciada.
# Es idempotente: correrlo de nuevo solo reporta "ya apunta a".

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"

# Enlaza src -> dest respaldando lo que hubiera antes. No hace nada si dest ya
# apunta a src. Devuelve 1 (sin abortar) si src no existe.
link_path() {
    local src="$1" dest="$2"

    if [ ! -e "$src" ]; then
        echo "Aviso: $src no existe, se omite." >&2
        return 1
    fi

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        echo "OK: $dest ya apunta a $src"
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup="${dest}.pre-dotfiles-bak"
        echo "Respaldando $dest -> $backup"
        mv "$dest" "$backup"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Enlazado: $dest -> $src"
}

# --- Carpetas del repo -> ~/.config/<nombre> -----------------------------------
# La mayoría se llama igual de los dos lados; matugen/wallust viven anidados
# dentro de theming/engines.
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
    link_path "$REPO_DIR/$src_rel" "$CONFIG_DIR/$name" || true
done

# --- Unidades systemd --user individuales -------------------------------------
# (no se enlaza la carpeta completa porque ahí también viven otras unidades
# ajenas a este repo, además de los *.wants/ que systemd gestiona)
mkdir -p "$CONFIG_DIR/systemd/user"
for unit_src in "$REPO_DIR"/systemd/user/*; do
    [ -f "$unit_src" ] || continue
    link_path "$unit_src" "$CONFIG_DIR/systemd/user/$(basename "$unit_src")" || true
done

# --- Primera generación del tema --------------------------------------------
# theming/current/ NO se versiona (es estado generado por aether). Sin esto,
# los enlaces de abajo (fastfetch, colores del selector) y los `include` de
# tema de las terminales / btop apuntan a archivos que todavía no existen.
if [ ! -f "$REPO_DIR/theming/current/colors.toml" ]; then
    if command -v aether >/dev/null 2>&1 && \
       find "$WALLPAPER_DIR" -maxdepth 1 -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            -print -quit 2>/dev/null | grep -q .; then
        echo "Generando el tema inicial (chocomazapan-wallpaper-set random)..."
        "$REPO_DIR/bin/chocomazapan-wallpaper-set" random \
            || echo "Aviso: la generación del tema falló; córrela a mano después." >&2
    else
        echo "Aviso: falta 'aether' o no hay wallpapers en $WALLPAPER_DIR." >&2
        echo "  Copia tus wallpapers y corre luego: chocomazapan-wallpaper-set random" >&2
    fi
fi

# --- Archivos sueltos que dependen del tema generado ------------------------
# config.jsonc de fastfetch: el logo lleva el color de acento del tema.
if [ -f "$REPO_DIR/theming/current/fastfetch-config.jsonc" ]; then
    link_path "$REPO_DIR/theming/current/fastfetch-config.jsonc" \
              "$CONFIG_DIR/fastfetch/config.jsonc" || true
else
    echo "Aviso: falta theming/current/fastfetch-config.jsonc (genera el tema primero)." >&2
fi

# El selector visual de wallpaper (chocomazapan-menu-images) busca aquí sus
# colores cuando se le llama sin --colors-file explícito.
if [ -f "$REPO_DIR/theming/current/quickshell-colors.json" ]; then
    link_path "$REPO_DIR/theming/current/quickshell-colors.json" \
              "$CONFIG_DIR/chocomazapan/quickshell-colors.json" || true
fi

# --- Dotfiles sueltos de $HOME (no viven bajo ~/.config) --------------------
# .XCompose necesita el include "%L" para que las teclas muertas (´ + a = á)
# funcionen en apps Qt/Wayland.
for home_src in "$REPO_DIR"/home/.*; do
    case "$(basename "$home_src")" in .|..) continue ;; esac
    [ -f "$home_src" ] || continue
    link_path "$home_src" "$HOME/$(basename "$home_src")" || true
done

# --- Tema de VS Code -------------------------------------------------------
# aether regenera theming/current/vscode-extension/ en cada cambio de wallpaper;
# solo falta que la extensión instalada apunte ahí en vez de a una copia estática.
if [ -d "$HOME/.vscode/extensions" ]; then
    link_path "$REPO_DIR/theming/current/vscode-extension" \
              "$HOME/.vscode/extensions/local.theme-aether-1.0.0" || true
else
    echo "Aviso: ~/.vscode/extensions no existe (¿VS Code no instalado?), se omite el tema." >&2
fi

# --- Pasos que requieren root (opcional) ----------------------------------
if [ -t 0 ] && command -v sudo >/dev/null 2>&1; then
    read -rp "¿Instalar el hook de pacman y los dirs de políticas de navegador con sudo? [y/N] " ROOT_ANS || ROOT_ANS="N"
else
    ROOT_ANS="N"
fi
case "${ROOT_ANS:-N}" in
    [yY]*)
        # Hook: reinicia Walker/Elephant tras actualizarlos por pacman.
        sudo tee /etc/pacman.d/hooks/walker-restart.hook >/dev/null <<HOOK
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Reiniciando Walker tras actualización del sistema
When = PostTransaction
Exec = $REPO_DIR/bin/chocomazapan-restart-walker
HOOK
        echo "Instalado: /etc/pacman.d/hooks/walker-restart.hook"

        # El color de ventana de los navegadores se aplica escribiendo un
        # color.json en el dir de políticas 'managed'. Se crea y se pasa al
        # usuario para que chocomazapan-theme-set-browser pueda escribir sin sudo.
        for d in /etc/chromium/policies/managed /etc/opt/chrome/policies/managed \
                 /etc/opt/edge/policies/managed /etc/brave/policies/managed; do
            sudo mkdir -p "$d" && sudo chown "$USER" "$d" \
                && echo "  dir de políticas listo: $d" \
                || echo "  no se pudo preparar $d" >&2
        done
        ;;
    *)
        echo "Saltado el paso de root. Para hacerlo luego:"
        echo "  sudo tee /etc/pacman.d/hooks/walker-restart.hook <<'EOF'"
        echo "  [Trigger]"
        echo "  Type = Package"
        echo "  Operation = Upgrade"
        echo "  Target = walker"
        echo "  Target = walker-debug"
        echo "  Target = elephant*"
        echo "  [Action]"
        echo "  Description = Reiniciando Walker tras actualización del sistema"
        echo "  When = PostTransaction"
        echo "  Exec = $REPO_DIR/bin/chocomazapan-restart-walker"
        echo "  EOF"
        echo "  for d in /etc/{chromium,opt/chrome,opt/edge,brave}/policies/managed; do sudo mkdir -p \$d && sudo chown \$USER \$d; done"
        ;;
esac

# --- Chequeo de paquetes -------------------------------------------------
echo
echo "Revisando paquetes..."
PKGS_CORE="hyprland waybar mako walker elephant quickshell aether awww alacritty swayosd openrgb chafa python-terminaltexteffects imagemagick fastfetch socat grim jq ttf-jetbrains-mono-nerd"
PKGS_OPT="kitty foot ghostty btop hunspell mise"
if command -v pacman >/dev/null 2>&1; then
    miss=""
    for p in $PKGS_CORE; do pacman -Q "$p" >/dev/null 2>&1 || miss="$miss $p"; done
    [ -n "$miss" ] && echo "  FALTAN (necesarios):$miss" || echo "  necesarios: todo instalado"
    optmiss=""
    for p in $PKGS_OPT; do pacman -Q "$p" >/dev/null 2>&1 || optmiss="$optmiss $p"; done
    [ -n "$optmiss" ] && echo "  opcionales sin instalar:$optmiss"
    echo "  Walker usa proveedores 'elephant-*' aparte (bluetooth calc clipboard"
    echo "  desktopapplications files menus providerlist runner symbols todo unicode websearch)."
else
    echo "  (sin pacman: instala manualmente) $PKGS_CORE"
fi

# --- Pasos manuales restantes ------------------------------------------
echo
echo "Listo. Pasos manuales que quedan:"
[ -d "$WALLPAPER_DIR" ] || echo "  - Crea $WALLPAPER_DIR y copia tus wallpapers (no viajan en el repo)."
echo "  - systemctl --user daemon-reload && systemctl --user enable --now chocomazapan-battery-monitor.timer"
echo "  - Vencord: instala 'vencord-installer-git' (AUR) y corre 'vencordinstallercli -install -branch stable' antes de abrir Discord."
echo "  - Obsidian: si tu vault vive en otra ruta, edita VAULT_DIR en bin/chocomazapan-obsidian-sync."
echo "  - Windows VM (opcional): 'chocomazapan-windows-vm install' — el docker-compose.yml y los discos no viajan en el repo."
