# Reparar instalación limpia (ThinkPad T14 Gen 5 AMD)

Handoff para un agente que trabaje **en la T14**. Escrito 2026-09-06 desde el
desktop tras el primer intento de instalar este repo en la laptop.

## Contexto

- El repo (`Chocodotfiles`) se movió a `~/.dotfiles` (carpeta oculta). Clonar con
  `git clone https://github.com/Alfred0113/Chocodotfiles.git ~/.dotfiles`.
- Es una config de Hyprland + SDDM + tema dinámico, pensada para **desktop**
  (RTX 3080) con lo de laptop en tres estados. La T14 es **AMD, sin NVIDIA**.
- El escritorio arranca así: Plymouth (tema propio "AlfredPC") → **SDDM**
  (tema QML `chocomazapan`, imita hyprlock) → contraseña → **Hyprland
  gestionado por uwsm**. Sin autologin.
- `install.sh` es idempotente. Se corre **dos veces**: 1ª desde un TTY
  (instala paquetes, enlaza configs, aplica el arranque), 2ª ya dentro de
  Hyprland (genera el tema, activa servicios `--user`).

## BUG QUE ROMPIÓ EL PRIMER INTENTO — pantalla negra tras el splash

Fueron **dos causas encadenadas**. La segunda es la de fondo y la que hay que
recordar.

### Causa 1 (tapa la 2): `DisplayServer=x11` sin Xorg-greeter

SDDM quedó en su default `DisplayServer=x11`. En el CachyOS del desktop ya
venía un `/etc/sddm.conf.d/10-wayland.conf`; en limpio no. **Fix:** vendorizado
en `sddm/conf.d/10-wayland.conf`, lo instala `install.sh`. `start-hyprland`
viene con `hyprland`; `hyprland.lua` lo pone `install.sh`.

### Causa 2 (la real): el greeter Qt5 sin sus libs Qt5

El paquete `sddm` de CachyOS instala **dos** greeters:

- `/usr/bin/sddm-greeter`      → build **Qt5** (necesita `libQt5Quick.so.5`,
  `libQt5Qml.so.5`)
- `/usr/bin/sddm-greeter-qt6`  → build Qt6

El daemon `sddm` es Qt6 **pero arranca `sddm-greeter` (el Qt5)** — tanto en
x11 como en wayland. Y el paquete **no declara Qt5 como dependencia**. En una
instalación limpia (sin KDE ni apps Qt5) faltan las libs y el greeter muere,
en **dos etapas** según lo que falte:

1. Sin `qt5-declarative`:
   `journalctl -b -u sddm` → `/usr/bin/sddm-greeter: error while loading shared
   libraries: libQt5Quick.so.5` → `sddm-helper exited with 127`.
   Confirmar: `ldd /usr/bin/sddm-greeter | grep 'not found'`.
2. Con `qt5-declarative` pero **sin `qt5-wayland`** (con `DisplayServer=wayland`
   el greeter corre con `-platform wayland`):
   `sddm-greeter: Could not find the Qt platform plugin "wayland"` →
   `terminated abnormally with signal 6/ABRT` → `wayland greeter finished 6`.
   Confirmar: `ls /usr/lib/qt/plugins/platforms/ | grep wayland` (debe existir
   `libqwayland-*.so`).

En ambos casos: **negro tras Plymouth**. En el desktop no se veía porque otro
paquete Qt5 ya jalaba todo.

### Fix inmediato

```bash
sudo pacman -S --needed qt5-declarative qt5-wayland qt5-quickcontrols2 qt5-graphicaleffects
sudo install -Dm644 ~/.dotfiles/sddm/conf.d/10-wayland.conf /etc/sddm.conf.d/10-wayland.conf
sudo systemctl restart sddm
```

### Fix permanente

Ya en el repo: `qt5-declarative qt5-wayland qt5-quickcontrols2
qt5-graphicaleffects` en `PKGS_REPO` + `sddm/conf.d/10-wayland.conf`
vendorizado. `cd ~/.dotfiles && git pull && ./install.sh` (paso de paquetes +
paso de arranque) deja todo.

## Cómo entrar si la pantalla está negra

1. **TTY:** `Ctrl+Alt+F2` (o F3). Debería dar login de texto.
2. **Si el TTY también está negro** (Plymouth agarrado al framebuffer):
   en el menú de **Limine** al prender, pica `e` sobre la entrada de CachyOS,
   agrega al final de la línea del kernel:
   `plymouth.enable=0 systemd.unit=multi-user.target`
   y arranca (`Ctrl+X`). Entra en modo texto sin gráficos.
3. **Rollback total:** menú de Limine → elegir un **snapshot** anterior
   (snap-pac crea uno por transacción de pacman, así que hay varios de hoy).

## Verificar que SDDM/Hyprland funcionan

```bash
systemctl get-default                       # debe ser graphical.target
systemctl is-enabled sddm                   # enabled
cat /etc/sddm.conf.d/10-wayland.conf        # DisplayServer=wayland
ldd /usr/bin/sddm-greeter | grep 'not found' # NADA (si sale libQt5*, falta qt5-declarative)
ls /usr/lib/qt/plugins/platforms/ | grep wayland  # libqwayland-*.so (si no: falta qt5-wayland)
ls /usr/share/wayland-sessions/             # hyprland.desktop + hyprland-uwsm.desktop
sudo systemctl restart sddm                 # debe salir el greeter con fondo borroso
```

**IMPORTANTE al hacer login la 1ª vez:** en el greeter, abajo a la izquierda
hay un selector de sesión — elegir **"Hyprland (uwsm-managed)"**, NO el
"Hyprland" pelón. La config depende de `uwsm/env` (PATH con `~/.dotfiles/bin`,
variables de sesión); sin uwsm los comandos `chocomazapan-*` y la barra no
cargan. SDDM recuerda la última sesión (`RememberLastSession=true`).

## Otros huecos conocidos de instalación limpia (revisar en orden)

1. **Bootloader != Limine.** El paso de arranque de `install.sh` edita
   `/etc/default/limine` para bajar el ruido de consola. Si la T14 quedó con
   systemd-boot/GRUB, `install.sh` ahora solo imprime los flags a poner a
   mano: `loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0`.
2. **Segunda pasada de `install.sh`.** Correrlo YA DENTRO de Hyprland para
   que genere el tema (`chocomazapan-wallpaper-set random` — necesita
   `aether` de AUR + al menos un wallpaper en `~/Imágenes/Wallpapers/`) y
   active `swayosd-server.service` (`--user`). La 1ª pasada desde TTY no
   puede (no hay compositor).
3. **Relogin tras mover/instalar.** `uwsm/env` (PATH) solo aplica al iniciar
   sesión. Si algo `chocomazapan-*` "no se encuentra", cerrar sesión y volver
   a entrar.
4. **No viajan en el repo:** `~/.config/fish/` (funciones propias),
   `~/.config/tmux/tmux.conf`, `~/.config/aether/` (se recrea con defaults).
5. **Wallpapers:** el repo trae 6 de arranque en
   `theming/themes/aether/backgrounds/`; `install.sh` los copia a
   `~/Imágenes/Wallpapers/` si está vacía. Agregar los propios ahí.
6. **Hibernación:** en la T14 (AMD) funciona sola — responder **n** al prompt
   de hibernación de `install.sh` (esa config es del desktop NVIDIA).
7. **GPU:** `bin/chocomazapan-gpu-mode` debe dar `none` en la T14. Si diera
   otra cosa, `uwsm/env` exportaría variables NVIDIA que rompen la sesión.
8. **Plymouth `--retain-splash`:** `install.sh` instala un override de
   `plymouth-quit.service` con `--retain-splash` (para que el splash no
   parpadee a negro en el handoff). En el desktop con SDDM es inofensivo.
   Si en la T14 el greeter no aparece y se sospecha de esto:
   `sudo rm -f /etc/systemd/system/plymouth-quit.service.d/override.conf`
   `&& sudo systemctl daemon-reload`. NUNCA `systemctl mask plymouth-quit`
   (deja plymouthd de DRM master → Hyprland revienta).

## Estado del repo (commits relevantes de esta ronda)

- `195b156` paquetes base del shell en `PKGS_REPO`
- `a2415bd` `chocomazapan-gpu-mode` (none/nvidia/hybrid), `uwsm/env` condicional
- `3d0d91f` `plymouth` a `PKGS_REPO` + tolerar bootloader != Limine
- `792924f` repo movido a `~/.dotfiles` (34 archivos con el path corregido)
- `de11a2f` `mako/config` symlink relativo (roto por el move)
- `5cc0d8d` `nautilus`, `xdg-terminal-exec`, deps de capturas y menús TUI
- `8af0465` `PKGS_APPS` (navegador, obsidian, keepassxc, mpv, ...)
- `fda7503` `sddm/conf.d/10-wayland.conf` vendorizado + instalado
- (este) `qt5-declarative qt5-wayland qt5-quickcontrols2 qt5-graphicaleffects`
  en `PKGS_REPO` — el greeter Qt5 de SDDM sin sus libs/plugin wayland dejaba
  la pantalla negra

## Comando de instalación completo (referencia)

```bash
sudo pacman -S --needed git paru base-devel
git clone https://github.com/Alfred0113/Chocodotfiles.git ~/.dotfiles
~/.dotfiles/install.sh          # 1ª pasada desde TTY; hibernación -> n
reboot                          # -> SDDM -> elegir "Hyprland (uwsm-managed)"
~/.dotfiles/install.sh          # 2ª pasada dentro de Hyprland
```
