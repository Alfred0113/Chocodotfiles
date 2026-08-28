# dotfiles

Configuración personal de escritorio: Hyprland + herramientas asociadas.

## Uso

```
git clone <este repo> ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` crea symlinks desde `~/.config/*` hacia las carpetas de este repo.

**No incluido en el repo** (copiar aparte a la carpeta indicada):
- Wallpapers → `~/Imágenes/Wallpapers/` (imágenes, no viven en git)

## Estructura

- `hypr/` → `~/.config/hypr`
- `waybar/` → `~/.config/waybar`
- `mako/` → `~/.config/mako`
- `walker/` → `~/.config/walker`
- `theming/` → `~/.config/theming` — sistema de tema din��mico:
  - `engines/{matugen,wallust}/` → `~/.config/{matugen,wallust}` — configs de los dos motores de extracción de color
  - `templates/` → plantillas propias (waybar.css, mako, walker.css) que leen `current/colors.toml`
  - `current/` → estado generado (no versionado): paleta activa + assets derivados
  - `themes/aether/` → paleta estática vendorizada de referencia, ya no es el mecanismo activo
- `bin/` → scripts propios (`chocomazapan-wallpaper-set`, `chocomazapan-apply-theme`, `chocomazapan-launch-*`, `chocomazapan-system-lock/wake`, ...) usados por keybindings, autostart, y la barra. Añade `~/dotfiles/bin` al PATH vía `uwsm/env`.
- `uwsm/` → `~/.config/uwsm` — variables de entorno de la sesión gráfica (PATH, editor/terminal por defecto, etc.)

## Pendiente de migrar (aún depende de Omarchy instalado)

- El botón de menú de waybar (`custom/omarchy`) y `SUPER+ALT+SPACE` siguen llamando `omarchy-menu`.
- El screensaver (`omarchy-launch-screensaver`, en `hypridle.conf`) y el brillo de teclado/pantalla (`omarchy-brightness-*`, usados por `chocomazapan-system-lock/wake`) — dependen de configs por terminal e integración con SwayOSD.
- `hypr/hyprland.lua` carga `require("omarchy.current.theme.hyprland")` desde `$OMARCHY_PATH` — **investigar antes de desinstalar Omarchy**: no está claro si el runtime Lua de Hyprland (`hl.*`) en sí depende de Omarchy o es de Hyprland mismo.

## Crédito

La estructura de esta configuración se inspiró en Omarchy (https://omarchy.org), usado como referencia durante el desarrollo.
