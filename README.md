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
- `systemd/user/` → archivos sueltos enlazados dentro de `~/.config/systemd/user/` (no la carpeta completa, ahí también viven unidades ajenas a este repo). Por ahora solo `chocomazapan-battery-monitor.{service,timer}`.

## Pendiente de migrar (aún depende de Omarchy instalado)

- El screensaver (`omarchy-launch-screensaver`, en `hypridle.conf`) y el brillo de teclado/pantalla (`omarchy-brightness-*`, usados por `chocomazapan-system-lock/wake`) — dependen de configs por terminal e integración con SwayOSD.
- `omarchy-recover-internal-monitor.service` (limpia un toggle de "monitor interno desactivado" cuando no hay pantalla externa) — **no se vendorizó**: depende de un archivo de estado (`~/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua`) que solo se crea desde el árbol de keybindings por defecto (ver riesgo abajo), que tampoco está portado. Hoy es un no-op (la condición nunca se cumple, es una laptop sin esto configurado). Retomar cuando se porte a la laptop (Fase 8) y se resuelva el árbol de bindings por defecto.
- `bin/chocomazapan-restart-mako` menciona el flujo de theming en un comentario nada más — sin dependencia real.

## Notas de la Fase 5 (servicios de fondo)

- `omarchy-bg-carousel.timer` (cambiaba el wallpaper cada 20 min vía `omarchy theme bg next`) quedó **deshabilitado** — chocamaba con `chocomazapan-wallpaper-set`, y de cualquier forma está superado por él (Fase 1b ya cubre el cambio de wallpaper al iniciar sesión).
- `omarchy-battery-monitor.timer` reemplazado por `chocomazapan-battery-monitor.timer` (mismo intervalo: cada 30s tras 1 min de boot). En este desktop es un no-op (sin batería), pero es real en la laptop.

## ⚠️ Riesgo grande a investigar antes de la Fase 7 (desinstalar Omarchy)

- `hypr/hyprland.lua` carga `require("omarchy.current.theme.hyprland")` desde `$OMARCHY_PATH` — no está claro si el runtime Lua de Hyprland (las funciones `hl.*` usadas en TODOS los `.lua` de este repo) es nativo de Hyprland o un módulo que provee/instala Omarchy.
- Confirmado: existe un árbol completo de **keybindings por defecto** fuera de este repo, en `~/.local/share/omarchy/default/hypr/bindings/` (`clipboard.lua`, `media.lua`, `tiling-v2.lua`, `utilities.lua`), con su propio DSL (`o.bind`, `o.bind_menu`). Ahí viven atajos base como `SUPER+SPACE` (launcher), tiling de ventanas, teclas multimedia, portapapeles, etc. — nada de esto está en `hypr/bindings.lua` (que solo trae los *extras* del usuario). Si `o.*`/`hl.*` son de Omarchy, desinstalarlo dejaría el escritorio sin la mayoría de sus atajos de teclado hasta reconstruir ese árbol completo — un proyecto notablemente más grande de lo planeado originalmente.

## Crédito

La estructura de esta configuración se inspiró en Omarchy (https://omarchy.org), usado como referencia durante el desarrollo.
