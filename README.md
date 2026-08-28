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
- `alacritty/` → `~/.config/alacritty` — incluye `screensaver.toml` (override usado solo por el screensaver)
- `swayosd/` → `~/.config/swayosd`

## Notas de la Fase 5 (servicios de fondo)

- `omarchy-bg-carousel.timer` (cambiaba el wallpaper cada 20 min vía `omarchy theme bg next`) quedó **deshabilitado** — chocaba con `chocomazapan-wallpaper-set`, y de cualquier forma está superado por él (Fase 1b ya cubre el cambio de wallpaper al iniciar sesión).
- `omarchy-battery-monitor.timer` reemplazado por `chocomazapan-battery-monitor.timer` (mismo intervalo: cada 30s tras 1 min de boot). En este desktop es un no-op (sin batería), pero es real en la laptop.

## Notas de la Fase 6 (theming del resto de apps + screensaver/brillo)

Se investigó qué de la lista original (kitty/foot/ghostty, Zed, Neovim, Obsidian, Discord/Vencord, Chromium, RGB) estaba realmente instalado/activo antes de tocar nada:

- **Alacritty** y **SwayOSD**: dependencias reales confirmadas (`@import`/`general.import` a Omarchy) — repuntadas a `theming/current/` como todo lo demás, con sus templates en `theming/templates/`.
- **Neovim**: tiene una integración real con el plugin `bjarneo/aether.nvim`, que usa exactamente el mismo esquema de colores que `colors.toml`. Solo se enlaza `~/.config/nvim/lua/plugins/theme.lua -> theming/current/nvim-theme.lua` (no se movió toda la config de nvim al repo, es del usuario y no estaba en git).
- **Vencord**: no estaba instalado (Discord sí, pero sin mod). Se instaló (`vencord-installer-git` + `vencordinstallercli -install`) y se generó `theming/current/vencord-quickcss.css`, enlazado a `~/.config/Vencord/settings/quickCss.css`. **Falta un paso manual**: activar "Custom CSS/Themes" dentro de la configuración de Vencord en Discord (no se puede automatizar sin abrir la app).
- **Chromium**: se vendorizó `chocomazapan-theme-set-browser` (pinta el color de la ventana vía policy en `/etc/chromium/policies/managed/`, ese directorio ya es de escritura libre — así lo dejó el instalador de Omarchy).
- **RGB (RAM/GPU/fans ARGB de la board)**: se detectó hardware real vía OpenRGB (no había RGB de teclado, que es lo que tenía el tema original). Nuevo `chocomazapan-rgb-sync` aplica el color de acento del tema a todo con `openrgb --mode static --color`.
- **Obsidian**: vault en `~/Documentos/Machiliztli` (ruta específica de esta máquina, ajustar `VAULT_DIR` en `chocomazapan-obsidian-sync` si cambia). Genera y activa un snippet CSS vía `.obsidian/appearance.json`.
- **Screensaver**: `chocomazapan-screensaver` + `chocomazapan-launch-screensaver` (simplificado — solo soporta Alacritty, el único terminal instalado). El arte ya no es el logo de Omarchy: es la palabra "ChocoMazapan" con degradado accent→foreground, renderizada a imagen con ImageMagick y convertida a arte ANSI con `chafa`. El fondo cambia con el tema (`chocomazapan-screensaver-art` lo regenera con `background` del tema actual en cada cambio de wallpaper, escribe a `theming/current/screensaver.txt`; `bin/assets/screensaver.txt` queda como respaldo estático por si aún no corrió ningún `chocomazapan-wallpaper-set`). `hypridle.conf` ya apunta a esto (ya no diferido).
- **Brillo de teclado/pantalla**: `chocomazapan-brightness-{keyboard,display}` + `chocomazapan-swayosd-{client,brightness,kbd-brightness}` vendorizados (se quitó la rama específica de hardware Apple, no aplica aquí). `chocomazapan-system-lock`/`wake` ya los usan.

Todo lo anterior (excepto Obsidian, que solo corre cuando se le pide) se ejecuta automáticamente dentro de `chocomazapan-wallpaper-set` cada vez que cambia el wallpaper.

**No vendorizado, documentado y con razón:**
- `omarchy-recover-internal-monitor.service` — depende de un toggle que solo crea el árbol de keybindings por defecto (ver riesgo abajo), no portado. No-op en este desktop. Retomar en la Fase 8 (laptop).

## Notas de la Fase 7a (portar el árbol de keybindings/config por defecto)

El riesgo grande que se arrastraba desde las Fases 4/6 quedó resuelto: `pacman -Qo /usr/share/hypr/stubs/hl.meta.lua` confirma que el runtime Lua de Hyprland (`hl.*`) es 100% nativo del paquete `hyprland`, autogenerado por el propio compositor — no depende de Omarchy en absoluto. El wrapper `o.*` (usado en todo el árbol de bindings por defecto) resultó ser solo 103 líneas propias de Omarchy sobre `hl.bind`, mecánicamente portable.

Se portó el árbol completo `default/hypr` (~600 líneas) a `hypr/core/`: `paths`, `helpers` (el wrapper `o.*`), `autostart`, `envs`, `looknfeel`, `input`, `windows`, `toggles`, `require_all`, más `apps/` (19 archivos de reglas de ventana por app, con los app-id `org.omarchy.*` renombrados a `org.chocomazapan.*`) y los bindings de `clipboard`/`tiling-v2`/`media`/`utilities`. `hyprland.lua` ya no usa `$OMARCHY_PATH` ni carga nada de Omarchy. `~/.local/state/chocomazapan/toggles/hypr/` reemplaza la ruta de estado de Omarchy para los toggles (gaps, aspect-ratio).

## Notas de la Fase 7b (vendorizar los scripts que faltaban)

Se vendorizaron los ~28 scripts que habían quedado marcados `TODO Fase 7b` en `hypr/core/bindings/{media,utilities}.lua`: mostrar keybindings de Hyprland (`SUPER+K`) y de Tmux (`SUPER+ALT+K`), toggle/posición de waybar, toggle de transparencia/gaps/aspecto de ventana, nightlight, mic-mute, audio-output-switch, toggle de touchpad, OCR de captura, transcode, y notificaciones de hora/batería/clima. Todo activado en `hypr/core/bindings/{media,utilities}.lua` — probado en vivo (194 keybindings cargados sin conflicto tras el reload).

De paso se limpió un `omarchy-menu-tmux-keybindings` que quedaba vivo en `~/.config/tmux/tmux.conf` (atajo `PREFIX + ?`, fuera de este repo — es config propia del usuario) y se vendorizó localmente el CSS de tema de Discord (`theming/templates/vencord-quickcss.css.template`), que antes traía un `@import` a una URL externa llamada `omarchy-discord.theme.css`; ahora el CSS está inlineado en la plantilla, sin dependencia de red y sin la palabra "omarchy".

Lo laptop-only (`chocomazapan-powerprofiles-init`, `chocomazapan-hyprland-monitor-watch`, toggle de monitor interno/mirror, lid switch) se queda diferido a la Fase 8, marcado explícito en `hypr/core/autostart.lua` y `hypr/core/bindings/utilities.lua`.

## Crédito

La estructura de esta configuración se inspiró en Omarchy (https://omarchy.org), usado como referencia durante el desarrollo.
