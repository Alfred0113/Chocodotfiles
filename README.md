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
- `theming/` → `~/.config/theming` — sistema de tema dinámico:
  - `engines/{matugen,wallust}/` → `~/.config/{matugen,wallust}` — configs de los motores de extracción usados hasta antes de adoptar `aether`; ya no están wireados a nada, quedan como referencia
  - `templates/` → plantillas propias (waybar.css, mako, walker.css, vencord-quickcss.css, quickshell-colors.json, hyprland-colors.lua) que leen `current/colors.toml`
  - `current/` → estado generado (no versionado): paleta activa + assets derivados
  - `themes/aether/` → paleta estática vendorizada de referencia, ya no es el mecanismo activo
- `bin/` → scripts propios (`chocomazapan-wallpaper-set`, `chocomazapan-apply-theme`, `chocomazapan-launch-*`, `chocomazapan-system-lock/wake`, `chocomazapan-menu-keybindings`, `chocomazapan-windows-vm`, ...) usados por keybindings, autostart, y la barra. Añade `~/dotfiles/bin` al PATH vía `uwsm/env`.
- `uwsm/` → `~/.config/uwsm` — variables de entorno de la sesión gráfica (PATH, editor/terminal por defecto, etc.)
- `systemd/user/` → archivos sueltos enlazados dentro de `~/.config/systemd/user/` (no la carpeta completa, ahí también viven unidades ajenas a este repo). Por ahora solo `chocomazapan-battery-monitor.{service,timer}`.
- `alacritty/` → `~/.config/alacritty` — incluye `screensaver.toml` (override usado solo por el screensaver)
- `swayosd/` → `~/.config/swayosd`
- `fastfetch/` → `~/.config/fastfetch` — logo propio (`bin/assets/logo.txt`), OS/wallpaper-activo/actualizaciones-pendientes reales (ver "Corte final" — antes usaba comandos de versión de Omarchy)
- `quickshell/select-by-image.qml` — el selector visual de wallpaper (carrusel de tarjetas, ver abajo). No se symlinkea a ningún `~/.config`; `chocomazapan-menu-images` lo referencia directo por su ruta dentro del repo.

## Theming dinámico

`chocomazapan-wallpaper-set` es el comando central, con dos modos:

- **Sin argumentos**: abre `chocomazapan-menu-images`, un carrusel visual real (QuickShell/QML: tarjetas con miniatura en perspectiva a los lados, la seleccionada se expande al centro con borde de acento) — puerto propio, renombrado y adaptado, de un componente que el usuario ya tenía funcionando en otra máquina (`quickshell/select-by-image.qml` + `bin/chocomazapan-menu-images`, comunicados por un socket Unix vía `socat`). Miniaturas cacheadas con ImageMagick (`~/.cache/wallpaper-selector/`, con lock por archivo para no regenerar en paralelo). Navegar (flechas/tab) no dispara nada; `Return` o click en la tarjeta expandida aplica esa imagen y modo actuales y cierra el selector. Dentro del selector: `R` salta a una imagen al azar (sin aplicar todavía, solo cambia cuál está resaltada/expandida), `M`/`Shift+M` cicla el modo de extracción de `aether` (23 modos — colorful, normal, pastel, fire, ocean, neon, ...), con el modo activo siempre visible en la esquina superior. El propio selector toma su color de acento/fondo/texto de `theming/current/quickshell-colors.json` (una plantilla más, generada por `chocomazapan-apply-theme`), así que combina con el tema activo. Se probaron y descartaron tres alternativas antes de llegar a esta (un menú custom de Walker/elephant-menus, la GUI real de `aether` con sincronización automática al detectar cambios, y un carrusel con `imv`) — ninguna daba a la vez miniaturas reales, look de tarjetas, y control explícito de "solo actuar en Enter/click".
- **Con argumentos** (`random [modo]` o `<archivo> [modo]`, `[modo]` es uno de `aether --list-modes`): headless, corre `aether --generate <imagen> --extract-mode <modo> --no-apply --output theming/current` — nunca abre ninguna GUI. Por defecto usa el modo `colorful`. Termina con una notificación de escritorio (`chocomazapan-notification-send`), útil porque esta rama suele correr en background sin consola visible.

Una vez que `theming/current/colors.toml` está listo, `chocomazapan-apply-theme` (Python) renderiza las plantillas propias de `theming/templates/` hacia `theming/current/`: waybar, mako, walker, Alacritty, SwayOSD, Neovim (vía `bjarneo/aether.nvim`), Vencord/Discord, Chromium, Obsidian, RGB (OpenRGB, RAM/GPU/fans ARGB de la board), el propio picker (`quickshell-colors.json`) y **los bordes de ventana de Hyprland** (`hyprland-colors.lua`) — necesario porque `aether` no toca esos configs (confirmado: no escribe fuera de su propio `~/.config/aether/`, y no soporta Hyprland/RGB/Obsidian/nuestro screensaver/el picker). Todo corre automático en cada cambio de wallpaper, salvo Obsidian que solo corre cuando se le pide.

**Bordes de Hyprland** (`hypr/core/looknfeel.lua`): antes eran un color fijo hardcodeado desde el port de la Fase 7a (`rgba(33ccffee)`/`rgba(00ff99ee)` activo, `rgba(595959aa)` inactivo), nunca conectado al tema — se detectó al revisar por qué "los contornos de las ventanas no se sincronizan". Ahora `dofile` (no `require`, para releer siempre y no quedarse con una copia en caché entre reloads) carga `theming/current/hyprland-colors.lua` — `active` = `accent`, `inactive` = `color8` del tema — con reintento a los valores fijos originales si el archivo aún no existe. `chocomazapan-wallpaper-set` corre `hyprctl reload` al final de `sync_desktop()` (antes no se llamaba en absoluto) para que el cambio se vea sin reiniciar Hyprland.

**Indicadores "activos" de waybar** (grabación de pantalla, idle-lock, silenciar notificaciones, voxtype grabando): usaban un rojo fijo (`#a55555`) en vez del tema — ahora `@alert` (definido en `waybar.css.template` como `{{color1}}`, el rojo semántico de la paleta ANSI del tema activo).

**Fondo real de escritorio — `awww`, no `swaybg`.** Se usó `swaybg` (mata el proceso viejo y lanza uno nuevo por cada cambio) hasta que se detectó, en una investigación a fondo pedida explícitamente por el usuario, un bug real y reproducible en este setup de dos monitores: ambas capas de wallpaper (una por monitor) terminaban con el **mismo PID** dueño (el proceso nuevo se registró correctamente en los dos outputs), pero solo una de las dos capas se repintaba con la imagen nueva — la otra se quedaba mostrando la imagen vieja indefinidamente. Verificado con capturas de pantalla por monitor (`grim -o <output>`) y comparación de píxeles exacta con ImageMagick, no solo inspección visual. Se reemplazó por `awww` (paquete oficial de CachyOS, sucesor de `swww`, provee el paquete virtual `swww` pero los binarios se llaman `awww`/`awww-daemon`) — corre como daemon persistente (`awww-daemon`, se asegura una sola vez, arrancado por `chocomazapan-wallpaper-set` si no está corriendo) y cada cambio de wallpaper es solo un comando IPC (`awww img <imagen> --resize crop`), sin matar/relanzar ningún proceso — verificado que ya no reproduce el bug (píxeles casi idénticos entre monitores tras el cambio, antes eran escenas completamente distintas).

El screensaver (`chocomazapan-screensaver`) muestra la palabra "ChocoMazapan" en degradado accent→foreground sobre el fondo del tema activo, renderizado a arte ANSI con `chafa`.

## Servicios de fondo

`chocomazapan-battery-monitor.{service,timer}` (cada 30s tras 1 min de boot) es el único servicio propio activo hoy — no-op en este desktop (sin batería), real en la laptop.

## Windows VM

`chocomazapan-windows-vm` (install/remove/launch/stop/status) administra una VM de Windows vía Docker + RDP, lanzada desde el `.desktop` "Windows". El nombre del contenedor Docker (`omarchy-windows` en `docker-compose.yml`) y sus datos (`~/.windows`, `~/Windows`) se dejaron intactos tal como ya estaban provisionados en esta máquina — renombrarlos implicaría recrear el contenedor.

## Riesgo Hyprland Lua resuelto (ver historial de commits para el detalle)

El runtime Lua de Hyprland (`hl.*`, usado en todos los `.lua` de este repo) es nativo del paquete `hyprland` — no depende de ninguna distro de dotfiles de terceros. El árbol completo de configuración por defecto (autostart, envs, looknfeel, input, windows, reglas de ventana por app, bindings de clipboard/tiling/media/utilidades) vive en `hypr/core/`.

## Corte final

La distro de dotfiles usada como referencia ya no está instalada en esta máquina: se quitaron sus directorios (`~/.local/share`, `~/.config`), su paquete de Neovim preempaquetado (no se usaba — la config real de Neovim es propia), sus tres servicios systemd de usuario (reemplazados o dados de baja en fases previas), y su ruta del PATH en `uwsm/env`. De paso se repuntaron o limpiaron varios usuarios sueltos que quedaban fuera de este repo y que dependían de ella: un hook de pacman que reinicia Walker tras actualizaciones, un `.desktop` de Tetris, una función fish (`waybarestart`), el visor de compartir pantalla (`hyprland-preview-share-picker`, quedó sin stylesheet propio — usa el tema GTK por defecto), `fastfetch` (usaba comandos de versión/tema que ya no existen — ahora muestra el OS real, el wallpaper activo, y el conteo real de actualizaciones pendientes vía `checkupdates`), y 8 wrappers de CLIs de IA en `~/.local/bin/` (opencode, gemini, codex, copilot, etc.) que auto-instalaban pnpm/bun a través de ella.

**Pérdida real, sin arreglo posible:** una extensión pequeña de Chromium/Edge ("copy-url", copiaba la URL de la pestaña activa) vivía solo dentro de esos directorios y se perdió al borrarlos — nunca se vendorizó porque no apareció en el inventario de apps de la Fase 6. Se quitó la línea `--load-extension=` de `chromium-flags.conf` y `microsoft-edge-stable-flags.conf` a petición explícita, sin reemplazo.

No se tocaron: drivers NVIDIA (`chwd`), fish shell, ni el paquete `hyprland` — son independientes de la distro de referencia aunque vinieran del mismo instalador de terceros.

## Crédito

La estructura de esta configuración se inspiró en Omarchy (https://omarchy.org), usado como referencia durante el desarrollo.
