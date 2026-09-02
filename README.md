# dotfiles

Configuración personal de escritorio: Hyprland + herramientas asociadas. Máquina principal un desktop; la laptop objetivo es una **ThinkPad T14 Gen 5 AMD**.

## Uso

```
# antes: ten paru o yay instalado (helper de AUR)
git clone <este repo> ~/dotfiles
~/dotfiles/install.sh          # correr DENTRO de la sesión de Hyprland
```

`install.sh`:
- **instala los paquetes que falten** (pregunta antes): `sudo pacman -S` para los de repos, `paru`/`yay` para los de AUR (`aether`, `elephant*`, `python-terminaltexteffects`, `vencord-installer-git`);
- crea symlinks desde `~/.config/*` (y un par en `$HOME`) hacia las carpetas de este repo, respaldando lo que hubiera antes con sufijo `.pre-dotfiles-bak`;
- si `~/Imágenes/Wallpapers/` está vacía, copia ahí los wallpapers de arranque de `theming/themes/aether/backgrounds/`;
- corre la **primera generación del tema** (`chocomazapan-wallpaper-set random`);
- activa `chocomazapan-battery-monitor.timer`;
- ofrece (opcional, pide sudo) instalar el hook de pacman y preparar los dirs de políticas de navegador.

Es idempotente: correrlo de nuevo solo reporta "ya apunta a" / "todo instalado".

**No incluido en el repo** (se copia / configura aparte):
- Wallpapers propios → `~/Imágenes/Wallpapers/`. El repo solo trae unos pocos de arranque (`theming/themes/aether/backgrounds/`); agrega los tuyos ahí después.
- `~/.config/fish/` — funciones propias sin versionar (`waybarestart.fish` usa `chocomazapan-restart-waybar`).
- `~/.config/tmux/tmux.conf` — lo lee `chocomazapan-menu-tmux-keybindings`.
- `~/.config/aether/` — se recrea con los defaults de aether; el pipeline dinámico usa `--extract-mode`, no blueprints.
- `~/.config/environment.d/firefox-wayland.conf` (`MOZ_ENABLE_WAYLAND=1`) — opcional, Firefox reciente ya autodetecta Wayland.
- Dirs `/etc/<navegador>/policies/managed` — los prepara el paso de sudo de `install.sh`; sin ellos el color de ventana del navegador no se aplica.

## Estructura

- `hypr/` → `~/.config/hypr`
- `waybar/` → `~/.config/waybar`
- `mako/` → `~/.config/mako`
- `walker/` → `~/.config/walker`
- `theming/` → `~/.config/theming` — sistema de tema dinámico:
  - `engines/{matugen,wallust}/` → `~/.config/{matugen,wallust}` — configs de los motores de extracción usados hasta antes de adoptar `aether`; ya no están wireados a nada, quedan como referencia
  - `templates/` → plantillas propias (waybar.css, mako, walker.css, vencord-quickcss.css, quickshell-colors.json, hyprland-colors.lua) que leen `current/colors.toml`
  - `current/` → estado generado (no versionado): paleta activa + assets derivados
  - `themes/aether/` → paleta estática vendorizada de referencia (ya no es el mecanismo activo); `themes/aether/backgrounds/` son los wallpapers de arranque que `install.sh` copia si no tienes ninguno
- `bin/` → scripts propios (`chocomazapan-wallpaper-set`, `chocomazapan-apply-theme`, `chocomazapan-launch-*`, `chocomazapan-system-lock/wake`, `chocomazapan-menu-keybindings`, `chocomazapan-windows-vm`, ...) usados por keybindings, autostart, y la barra. Añade `~/dotfiles/bin` al PATH vía `uwsm/env`.
- `uwsm/` → `~/.config/uwsm` — variables de entorno de la sesión gráfica (PATH, editor/terminal por defecto, etc.)
- `plymouth/chocomazapan/` → tema del splash de arranque (el pingüino + "AlfredPC"). `install.sh` (paso root) lo copia a `/usr/share/plymouth/themes/chocomazapan` y lo fija con `plymouth-set-default-theme -R`
- `sddm/` → `themes/chocomazapan/` (tema QML del login, imita hyprlock), `conf.d/chocomazapan.conf` y `hyprland.lua` (config del greeter Wayland — teclado latam); `install.sh` (paso root) los copia a `/usr/share/sddm/` y `/etc/sddm.conf.d/`
- `system/` → archivos que van a `/etc` o `/usr/lib/systemd`, aplicados por `install.sh` con sudo (no se symlinkean): `chocomazapan-sddm-bg.service` (fondo aleatorio del login), `plymouth-quit.service.d/override.conf` (`--retain-splash`) y `sudoers.d/chocomazapan-timedatectl` (cambiar zona horaria sin contraseña, reemplaza a `omarchy-tzupdate`)
- `nautilus/` → extensiones de `nautilus-python` enlazadas en `~/.local/share/nautilus-python/extensions/`. Por ahora `transcode.py` (menú contextual "Transcode" → `chocomazapan-transcode`)
- `systemd/user/` → archivos sueltos enlazados dentro de `~/.config/systemd/user/` (no la carpeta completa, ahí también viven unidades ajenas a este repo). Por ahora solo `chocomazapan-battery-monitor.{service,timer}`.
- `alacritty/` → `~/.config/alacritty` — incluye `screensaver.toml` (override usado solo por el screensaver)
- `kitty/`, `foot/`, `ghostty/` → `~/.config/{kitty,foot,ghostty}` — cada config hace `include` del tema en `theming/current/<app>` (generado por aether). Terminales opcionales; la que se usa aquí es Alacritty.
- `btop/` → `~/.config/btop` — `btop.conf` + `themes/current.theme` (symlink relativo a `theming/current/btop.theme`)
- `swayosd/` → `~/.config/swayosd`
- `home/` → archivos sueltos de `$HOME`: `.bashrc` (sin el rc de Omarchy), `.XCompose` (con `include "%L"`, si no las teclas muertas no componen en apps Qt/Wayland) y `.hushlogin` (sin MOTD/last-login en el arranque)
- `theming/current/fastfetch-config.jsonc` → `~/.config/fastfetch/config.jsonc` (archivo suelto, no carpeta) — logo propio (`bin/assets/logo.txt`), OS/wallpaper-activo/actualizaciones-pendientes reales
- `theming/current/quickshell-colors.json` → `~/.config/chocomazapan/quickshell-colors.json` — colores del selector visual cuando se le llama sin `--colors-file`
- `quickshell/select-by-image.qml` — el selector visual de wallpaper (carrusel de tarjetas, ver abajo). No se symlinkea a ningún `~/.config`; `chocomazapan-menu-images` lo referencia directo por su ruta dentro del repo.

## Theming dinámico

`chocomazapan-wallpaper-set` es el comando central, con dos modos:

- **Sin argumentos**: abre `chocomazapan-menu-images`, un carrusel visual real (QuickShell/QML: tarjetas con miniatura en perspectiva a los lados, la seleccionada se expande al centro con borde de acento) — puerto propio, renombrado y adaptado, de un componente que el usuario ya tenía funcionando en otra máquina (`quickshell/select-by-image.qml` + `bin/chocomazapan-menu-images`, comunicados por un socket Unix vía `socat`). Miniaturas cacheadas con ImageMagick (`~/.cache/wallpaper-selector/`, con lock por archivo para no regenerar en paralelo). Navegar (flechas/tab) no dispara nada; `Return` o click en la tarjeta expandida aplica esa imagen y modo actuales y cierra el selector. Dentro del selector: `R` salta a una imagen al azar (sin aplicar todavía, solo cambia cuál está resaltada/expandida), `M`/`Shift+M` cicla el modo de extracción de `aether` (23 modos — colorful, normal, pastel, fire, ocean, neon, ...), con el modo activo siempre visible en la esquina superior. El propio selector toma su color de acento/fondo/texto de `theming/current/quickshell-colors.json` (una plantilla más, generada por `chocomazapan-apply-theme`), así que combina con el tema activo. Se probaron y descartaron tres alternativas antes de llegar a esta (un menú custom de Walker/elephant-menus, la GUI real de `aether` con sincronización automática al detectar cambios, y un carrusel con `imv`) — ninguna daba a la vez miniaturas reales, look de tarjetas, y control explícito de "solo actuar en Enter/click".
- **Con argumentos** (`random [modo]` o `<archivo> [modo]`, `[modo]` es uno de `aether --list-modes`): headless, corre `aether --generate <imagen> --extract-mode <modo> --no-apply --output theming/current` — nunca abre ninguna GUI. Por defecto usa el modo `colorful`. Termina con una notificación de escritorio (`chocomazapan-notification-send`), útil porque esta rama suele correr en background sin consola visible.

Una vez que `theming/current/colors.toml` está listo, `chocomazapan-apply-theme` (Python) renderiza las plantillas propias de `theming/templates/` hacia `theming/current/`: waybar, mako, walker, Alacritty, SwayOSD, Neovim (vía `bjarneo/aether.nvim`), Vencord/Discord, Chromium, Obsidian, RGB (OpenRGB, RAM/GPU/fans ARGB de la board), el propio picker (`quickshell-colors.json`) y **los bordes de ventana de Hyprland** (`hyprland-colors.lua`) — necesario porque `aether` no toca esos configs (confirmado: no escribe fuera de su propio `~/.config/aether/`, y no soporta Hyprland/RGB/Obsidian/nuestro screensaver/el picker). Todo corre automático en cada cambio de wallpaper, salvo Obsidian que solo corre cuando se le pide.

**Bordes de Hyprland** (`hypr/core/looknfeel.lua`): antes eran un color fijo hardcodeado desde el port de la Fase 7a (`rgba(33ccffee)`/`rgba(00ff99ee)` activo, `rgba(595959aa)` inactivo), nunca conectado al tema — se detectó al revisar por qué "los contornos de las ventanas no se sincronizan". Ahora `dofile` (no `require`, para releer siempre y no quedarse con una copia en caché entre reloads) carga `theming/current/hyprland-colors.lua` — `active` = `accent`, `inactive` = `color8` del tema — con reintento a los valores fijos originales si el archivo aún no existe. `chocomazapan-wallpaper-set` corre `hyprctl reload` al final de `sync_desktop()` (antes no se llamaba en absoluto) para que el cambio se vea sin reiniciar Hyprland.

**Indicadores "activos" de waybar** (grabación de pantalla, idle-lock, silenciar notificaciones, voxtype grabando): usaban un rojo fijo (`#a55555`) en vez del tema — ahora `@alert` (definido en `waybar.css.template` como `{{color1}}`, el rojo semántico de la paleta ANSI del tema activo).

**Calendario emergente en waybar**: ícono nuevo (`custom/calendar`, antes del reloj) que hace toggle de `quickshell/calendar-popup.qml` vía `chocomazapan-toggle-calendar`. Primer intento usó `gsimplecal` (calendario GTK ligero) superpuesto con la barra para tapar sus esquinas redondeadas — funcionaba, pero el usuario pidió específicamente el efecto de "protuberancia" con esquina cóncava (como el panel de ajustes rápidos de GNOME). `gsimplecal` no expone ningún hook de CSS/tema (revisado su código fuente en GitHub), así que se reemplazó por un widget propio en QuickShell/QML: la forma se dibuja a mano con `Shape`/`ShapePath` — un "cuello" rectangular centrado que sale de la barra, con un filete cóncavo (`PathArc` con `direction: Counterclockwise`, al revés de las esquinas normales del cuerpo) a cada lado conectándolo con el cuerpo redondeado del calendario (esquinas normales, `Clockwise`). `PanelWindow` con `WlrLayershell.layer: Overlay` (encima de la barra) y `anchors.top` + `margins.top: 30`, sin necesitar ningún truco de superposición/enmascarado. Colores del tema vía el mismo `quickshell-colors.json` que ya usa el selector de wallpaper (`FileView` con `watchChanges: true`). Calendario funcional completo: mes/año con flechas de navegación, grid de días con los del mes anterior/siguiente atenuados, hoy resaltado con el acento del tema.

**Fondo real de escritorio — `awww`, no `swaybg`.** Se usó `swaybg` (mata el proceso viejo y lanza uno nuevo por cada cambio) hasta que se detectó, en una investigación a fondo pedida explícitamente por el usuario, un bug real y reproducible en este setup de dos monitores: ambas capas de wallpaper (una por monitor) terminaban con el **mismo PID** dueño (el proceso nuevo se registró correctamente en los dos outputs), pero solo una de las dos capas se repintaba con la imagen nueva — la otra se quedaba mostrando la imagen vieja indefinidamente. Verificado con capturas de pantalla por monitor (`grim -o <output>`) y comparación de píxeles exacta con ImageMagick, no solo inspección visual. Se reemplazó por `awww` (paquete oficial de CachyOS, sucesor de `swww`, provee el paquete virtual `swww` pero los binarios se llaman `awww`/`awww-daemon`) — corre como daemon persistente (`awww-daemon`, se asegura una sola vez, arrancado por `chocomazapan-wallpaper-set` si no está corriendo) y cada cambio de wallpaper es solo un comando IPC (`awww img <imagen> --resize crop`), sin matar/relanzar ningún proceso — verificado que ya no reproduce el bug (píxeles casi idénticos entre monitores tras el cambio, antes eran escenas completamente distintas).

El screensaver (`chocomazapan-screensaver`) muestra la palabra "ChocoMazapan" en degradado accent→foreground sobre el fondo del tema activo, renderizado a arte ANSI con `chafa`.

## Servicios de fondo

`chocomazapan-battery-monitor.{service,timer}` (cada 30s tras 1 min de boot): aviso de batería baja al 10%. `install.sh` solo lo activa si `chocomazapan-is-laptop` da verdadero; en desktop se enlaza pero no se arranca.

## Menú (Súper+Ctrl+O)

Además de lo de siempre (Capture, Toggle, Setup, Style, System), dos añadidos que dependen del sistema, no del repo:

- **System → Hibernar** (`systemctl hibernate`) — requiere swap ≥ RAM y `resume=`/`resume_offset=` en la línea de kernel (CachyOS lo configura al instalar).
- **Setup → Crear snapshot** (`chocomazapan-snapshot-create`) — snapshot de snapper de `/` bajo demanda vía `pkexec`, marcado `important=yes` para que no lo borre pronto la limpieza. Un "punto de restauración" manual antes de hacer cosas locas; se ve en el menú de arranque de Limine. Necesita `snapper` + `limine-snapper-sync` (los trae CachyOS).

## Laptop vs desktop

No hay dos ramas de config: es una sola, pensada para desktop, con lo de laptop en tres estados.

- **`bin/chocomazapan-is-laptop`** — exit 0 si hay batería de sistema (`/sys/class/power_supply/BAT*`, ignorando periféricos) o `hostnamectl chassis` es portátil. Lo usan `install.sh` (timer de batería) y `o.is_laptop()` en la config Lua de Hyprland.
- **Degrada solo**: módulo `battery` de Waybar (se oculta sin batería), `chocomazapan-battery-status` (dice "Sin batería" en vez de basura).
- **Pendiente Fase 8** (scripts sin vendorizar): binds de lid switch / pantalla interna (`hypr/core/bindings/utilities.lua`), `chocomazapan-powerprofiles-init` y `chocomazapan-hyprland-monitor-watch` (`autostart.lua`) — al descomentarlos, envolver en `if o.is_laptop() then`.

### Teclas de función (F-row de la ThinkPad)

Todo esto ya está bindeado en `hypr/core/bindings/media.lua` (los scripts usan `brightnessctl` vía logind — sin udev ni root — y apuntan a `amdgpu_bl*` / `platform::kbd_backlight`, que es lo de la T14 G5 AMD):

| Tecla | Acción |
|---|---|
| F1 / F2 / F3 | mute / volumen − / volumen + (`XF86Audio*`, OSD por SwayOSD) |
| F4 | mute de micrófono (+ LED `platform::micmute`) |
| F5 / F6 | brillo − / + (Shift = mín/máx, Alt = pasos de 1%) |
| F7 | menú de pantallas (`chocomazapan-menu-display`): solo interna / solo externa / extender / espejo — usa la primera externa conectada |
| F8 | modo avión (`chocomazapan-toggle-airplane`, bloquea/desbloquea rfkill) |
| Fn+Space | luz del teclado — la maneja el kernel (`thinkpad_acpi`) directo, sin OSD |
| media (play/prev/next) | vía `playerctl` |

`install.sh` instala `brightnessctl` y `playerctl` y activa `swayosd-server.service` (sin él las teclas de volumen/brillo no hacen nada). El menú de F7 cambia el modo de pantallas para la sesión (con `hyprctl keyword monitor`); al reiniciar Hyprland vuelve a lo de `monitors.lua`. Solo maneja una pantalla externa a la vez.

## Windows VM

`chocomazapan-windows-vm` (install/remove/launch/stop/status) es un wrapper de [dockurr/windows](https://github.com/dockur/windows) (Windows en un contenedor Docker con KVM/QEMU, viewer web + RDP), lanzado desde el `.desktop` "Windows". El nombre del contenedor (`omarchy-windows` en `docker-compose.yml`) y sus datos (`~/.windows`, `~/Windows`) se dejaron como estaban — renombrarlos implicaría recrear el contenedor.

El `docker-compose.yml` y los discos **no viajan en el repo** (son de cada máquina). En una instalación nueva:

```
sudo pacman -S --needed docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"      # reinicia sesión para que aplique
# habilita la virtualización en el BIOS si 'ls /dev/kvm' falla
chocomazapan-windows-vm install      # pregunta RAM/CPU/disco/usuario/contraseña, descarga Win11 (~10-15 min)
```

Luego: `chocomazapan-windows-vm launch` (arranca + conecta por RDP; auto-apaga al cerrar), `launch -k` (deja corriendo), `stop`, `status`, `remove`. `install` también instala `freerdp openbsd-netcat gum` y crea el `.desktop` "Windows" (Súper+Space).

## Riesgo Hyprland Lua resuelto (ver historial de commits para el detalle)

El runtime Lua de Hyprland (`hl.*`, usado en todos los `.lua` de este repo) es nativo del paquete `hyprland` — no depende de ninguna distro de dotfiles de terceros. El árbol completo de configuración por defecto (autostart, envs, looknfeel, input, windows, reglas de ventana por app, bindings de clipboard/tiling/media/utilidades) vive en `hypr/core/`.

## Corte final

La distro de dotfiles usada como referencia ya no está instalada en esta máquina: se quitaron sus directorios (`~/.local/share`, `~/.config`), su paquete de Neovim preempaquetado (no se usaba — la config real de Neovim es propia), sus tres servicios systemd de usuario (reemplazados o dados de baja en fases previas), y su ruta del PATH en `uwsm/env`. De paso se repuntaron o limpiaron varios usuarios sueltos que quedaban fuera de este repo y que dependían de ella: un hook de pacman que reinicia Walker tras actualizaciones, un `.desktop` de Tetris, una función fish (`waybarestart`), el visor de compartir pantalla (`hyprland-preview-share-picker`, quedó sin stylesheet propio — usa el tema GTK por defecto), `fastfetch` (usaba comandos de versión/tema que ya no existen — ahora muestra el OS real, el wallpaper activo, y el conteo real de actualizaciones pendientes vía `checkupdates`), y 8 wrappers de CLIs de IA en `~/.local/bin/` (opencode, gemini, codex, copilot, etc.) que auto-instalaban pnpm/bun a través de ella.

**Pérdida real, sin arreglo posible:** una extensión pequeña de Chromium/Edge ("copy-url", copiaba la URL de la pestaña activa) vivía solo dentro de esos directorios y se perdió al borrarlos — nunca se vendorizó porque no apareció en el inventario de apps de la Fase 6. Se quitó la línea `--load-extension=` de `chromium-flags.conf` y `microsoft-edge-stable-flags.conf` a petición explícita, sin reemplazo.

**Barrido final de remanentes.** Búsqueda completa por todo `$HOME` y `/etc` (esta última con root): ya no queda ninguna dependencia funcional de la distro de referencia. Se eliminaron restos muertos: `~/.local/state/omarchy` y `~/.cache/omarchy` (estado/caché viejos), tres symlinks rotos de skills para agentes de IA (`~/.{codex,agents,pi/agent}/skills/omarchy`), una extensión de `pi` que sondeaba una ruta ya borrada, la fuente de íconos `omarchy.ttf` (waybar usa ícono propio desde la Fase 4), un `plymouthd.confe` basura en `/etc`, y el drop-in `omarchy_resume.conf` de mkinitcpio (renombrado a `resume.conf`, mismo contenido). Reglas sudoers: `omarchy-tzupdate` → `system/sudoers.d/chocomazapan-timedatectl` (solo `timedatectl`, que es lo que usa `chocomazapan-tz-select`); `99-omarchy-installer-reboot` (NOPASSWD para `/usr/bin/reboot`) **borrada sin reemplazo** — `chocomazapan-system-reboot` usa `systemctl reboot`, que logind ya permite sin sudo. Se **repuntó** la extensión de Nautilus `transcode.py` (llamaba a `omarchy-transcode`/`omarchy-launch-floating-terminal-with-presentation`, ambos ya vendorizados) — ahora vive en `nautilus/` del repo. Pendiente de decisión del usuario: dos temas de VS Code (`bjarne.*-omarchy`) instalados pero no referenciados, y el `Environment=PATH` de `ollama.service` con un segmento muerto. Lo que **se deja**: un comentario en `/etc/modprobe.d/nvidia-hibernate-fix.conf` que cita el issue de origen del fix (zona NVIDIA, es solo una cita), el `container_name: omarchy-windows` del Windows VM (renombrarlo = recrear el contenedor de ~84 GB), y menciones que `aether` (tercero) escribe en sus propios archivos generados.

No se tocaron: drivers NVIDIA (`chwd`), fish shell, ni el paquete `hyprland` — son independientes de la distro de referencia aunque vinieran del mismo instalador de terceros.

## Arranque y login

1. **Plymouth** — tema `chocomazapan` (`plymouth/chocomazapan/`, copiado a `/usr/share/plymouth/themes/` por `install.sh`). Renombrado del tema de la distro de referencia, con el `logo.png` ya personalizado (Tux + "AlfredPC"). Se fija con `sudo plymouth-set-default-theme -R chocomazapan` (regenera el initramfs). `plymouth-quit.service` lleva un override para salir con `--retain-splash` (deja el logo congelado durante el handoff a SDDM, sin negro).
2. **Cmdline del kernel** — `install.sh` añade `loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0` a `/etc/default/limine` (+ `limine-update`): sin ruido de systemd/udev ni cursor parpadeante bajo el splash.
3. **SDDM con tema `chocomazapan`** — `sddm/themes/chocomazapan/` (QML Qt6 puro), copiado a `/usr/share/sddm/themes/`. **Imita a hyprlock**: fondo aleatorio borroso, reloj `HH:MM`, fecha en es_MX, campo de contraseña tipo píldora con borde de acento — mismos colores catppuccin que `hyprlock.conf`. `sddm/conf.d/chocomazapan.conf` → `/etc/sddm.conf.d/` fija el tema; SDDM es un DM real que dibuja al instante (sin el hueco de `fbcon` que dejaba ver la consola con getty/greetd). **Sin autologin** — la contraseña se escribe aquí.
   - **Fondo**: `bin/chocomazapan-sddm-bg` (corre como `alfredo` vía `chocomazapan-sddm-bg.service`, `Before=sddm.service`) elige un wallpaper al azar de `~/Imágenes/Wallpapers` (≥1920×1080, caché por firma como `pick-lock-background.sh`), lo recorta + desenfoca + oscurece con ImageMagick y lo deja en `backgrounds/current.jpg` (ese dir lo hace escribible `install.sh` con `chown`).
   - Preview sin reiniciar: `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/chocomazapan`.
4. **hyprlock** ya **no** se lanza al arrancar (SDDM es la pantalla de login). Sigue igual para bloqueo manual (`chocomazapan-system-lock`, bind) e inactividad (`hypridle.conf`).

⚠️ **No** enmascarar `plymouth-quit*` para tapar la consola — plymouthd se queda de DRM master y Hyprland no arranca (`CBackend::create() failed!`), sistema en bucle de crash. Ya probado y revertido. Con SDDM no hace falta: dibuja de inmediato, no hay consola visible.

**Rescate si SDDM falla:** menú de Limine → snapshot, o `Ctrl+Alt+F2` → login → `sudo systemctl disable sddm`. El paquete `greetd` quedó instalado de un intento previo; se puede quitar (`sudo pacman -Rns greetd`), no se usa.

## Crédito y licencia

Este repo empezó como una migración fuera de [Omarchy](https://omarchy.org) (Copyright 37signals LLC, MIT): varios scripts y archivos de tema se copiaron desde Omarchy y se adaptaron/renombraron (ver el historial de commits y la sección "Corte final"). Las plantillas de tema por app las genera [aether](https://github.com/bjarneo/aether) (Copyright bjarneo, MIT).

Licencia: **MIT** (ver [`LICENSE`](LICENSE)) — compatible con las partes heredadas, que conservan su aviso de copyright original.
