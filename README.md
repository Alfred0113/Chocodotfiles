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
  - `templates/` → plantillas propias (waybar.css, mako, walker.css, vencord-quickcss.css) que leen `current/colors.toml`
  - `current/` → estado generado (no versionado): paleta activa + assets derivados
  - `themes/aether/` → paleta estática vendorizada de referencia, ya no es el mecanismo activo
- `bin/` → scripts propios (`chocomazapan-wallpaper-set`, `chocomazapan-apply-theme`, `chocomazapan-launch-*`, `chocomazapan-system-lock/wake`, `chocomazapan-menu-keybindings`, `chocomazapan-windows-vm`, ...) usados por keybindings, autostart, y la barra. Añade `~/dotfiles/bin` al PATH vía `uwsm/env`.
- `uwsm/` → `~/.config/uwsm` — variables de entorno de la sesión gráfica (PATH, editor/terminal por defecto, etc.)
- `systemd/user/` → archivos sueltos enlazados dentro de `~/.config/systemd/user/` (no la carpeta completa, ahí también viven unidades ajenas a este repo). Por ahora solo `chocomazapan-battery-monitor.{service,timer}`.
- `alacritty/` → `~/.config/alacritty` — incluye `screensaver.toml` (override usado solo por el screensaver)
- `swayosd/` → `~/.config/swayosd`

## Theming dinámico

`chocomazapan-wallpaper-set` es el comando central, con dos modos:

- **Sin argumentos**: abre la GUI real de `aether` (picker de wallpapers, 24 modos de extracción, preview en vivo — la app de theming que ya se usaba directamente en esta máquina antes de esta migración). El script se queda vigilando `~/.config/aether/theme/colors.toml` mientras la ventana esté abierta; cada vez que se le da "Apply" ahí adentro, detecta el cambio (por mtime) y sincroniza automático con el resto del setup — toma la imagen más reciente de `~/.config/aether/theme/backgrounds/` para ponerla de verdad con `swaybg` (aether por sí solo no cambia el fondo de escritorio) y copia su `colors.toml` a `theming/current/`.
- **Con argumentos** (`random [modo]` o `<archivo> [modo]`, `[modo]` es uno de `aether --list-modes`): headless, corre `aether --generate <imagen> --extract-mode <modo> --no-apply --output theming/current` — nunca abre la GUI.

En ambos casos, una vez que `theming/current/colors.toml` está listo, `chocomazapan-apply-theme` (Python) renderiza las plantillas propias de `theming/templates/` hacia `theming/current/`: waybar, mako, walker, Alacritty, SwayOSD, Neovim (vía `bjarneo/aether.nvim`), Vencord/Discord, Chromium, Obsidian y RGB (OpenRGB, RAM/GPU/fans ARGB de la board) — esto es necesario porque `aether` no toca esos configs (confirmado: no escribe fuera de su propio `~/.config/aether/`, y no soporta RGB/Obsidian/nuestro screensaver). Todo corre automático en cada cambio de wallpaper, salvo Obsidian que solo corre cuando se le pide.

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
