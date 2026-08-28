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

- El screensaver (`omarchy-launch-screensaver`, en `hypridle.conf`) y el brillo de teclado/pantalla (`omarchy-brightness-*`, usados por `chocomazapan-system-lock/wake`) — dependen de configs por terminal e integración con SwayOSD.
- `bin/chocomazapan-restart-mako` menciona el flujo de theming en un comentario nada más — sin dependencia real.

## ⚠️ Riesgo grande a investigar antes de la Fase 7 (desinstalar Omarchy)

- `hypr/hyprland.lua` carga `require("omarchy.current.theme.hyprland")` desde `$OMARCHY_PATH` — no está claro si el runtime Lua de Hyprland (las funciones `hl.*` usadas en TODOS los `.lua` de este repo) es nativo de Hyprland o un módulo que provee/instala Omarchy.
- Confirmado: existe un árbol completo de **keybindings por defecto** fuera de este repo, en `~/.local/share/omarchy/default/hypr/bindings/` (`clipboard.lua`, `media.lua`, `tiling-v2.lua`, `utilities.lua`), con su propio DSL (`o.bind`, `o.bind_menu`). Ahí viven atajos base como `SUPER+SPACE` (launcher), tiling de ventanas, teclas multimedia, portapapeles, etc. — nada de esto está en `hypr/bindings.lua` (que solo trae los *extras* del usuario). Si `o.*`/`hl.*` son de Omarchy, desinstalarlo dejaría el escritorio sin la mayoría de sus atajos de teclado hasta reconstruir ese árbol completo — un proyecto notablemente más grande de lo planeado originalmente.

## Crédito

La estructura de esta configuración se inspiró en Omarchy (https://omarchy.org), usado como referencia durante el desarrollo.
