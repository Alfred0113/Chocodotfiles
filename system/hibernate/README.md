# system/hibernate/

Config para que la **hibernación** funcione en el desktop: **RTX 3080** (`nvidia-open`
~610) + **WiFi MediaTek MT7921**. `install.sh` la aplica solo si detecta NVIDIA
(`lspci | grep -qi nvidia`) y previo `[y/N]`. **La T14 Gen 5 AMD no necesita nada de
esto** (sin NVIDIA, hibernación funciona sola).

## El problema (y por qué cada archivo)

| Síntoma | Causa | Fix |
|---|---|---|
| `pci_pm_freeze -5` / `Xid 13` al reanudar | `nvidia-open` en early-KMS es incompatible con `PreserveVideoMemoryAllocations`. CachyOS mete NVIDIA al initramfs con `10-chwd.conf` (`MODULES+=`). | `mkinitcpio.conf.d/99-nvidia-hibernate-fix.conf` → `MODULES=()` (corre después de `10-chwd.conf`) |
| lo mismo | falta la interfaz `/proc/driver/nvidia/suspend` (la dan los servicios, no los kernel-notifiers) | `modprobe.d/nvidia-sleep.conf` (`UseKernelSuspendNotifiers=0`) + habilitar `nvidia-{suspend,hibernate,resume}.service` |
| corrupción de VRAM al volver | — | `modprobe.d/nvidia-hibernate.conf` (`PreserveVideoMemoryAllocations=1`, `TemporaryFilePath=/var/tmp`) |
| cuelgue de ~5 min guardando VRAM | `nvidia-utils` pone `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false` | `systemd-system/systemd-*.service.d/20-freeze-user-sessions.conf` lo pone en `true` (seguro: `nvidia-sleep.sh` ya hace `chvt 63`) |
| `mt7921e ... pci_pm_restore -110`, aborta la imagen | la MT7921 no sobrevive el ciclo interno suspend/resume de la hibernación | `modprobe.d/mt7921e-hibernate.conf` (`blacklist mt7921e`) + `systemd-system/mt7921e-load.service` la carga tras el boot + `system-sleep/50-mt7921-hibernate` la descarga/recarga alrededor de la hibernación |
| `hyprlock` transparente al reanudar hasta el primer input | NVIDIA deja el page-flip pegado | `hypr/hypridle.conf`: `after_sleep_cmd` termina en `hyprctl dispatch forcerendererreload` |

También hace falta `resume=`/`resume_offset=` en la cmdline (CachyOS lo pone al instalar
con swap) y quitar el hook `resume` de mkinitcpio (el hook `systemd` lo reemplaza) —
`install.sh` mueve `resume.conf` → `resume.conf.disabled`.

## Rollback

```
sudo rm /etc/modprobe.d/{nvidia-hibernate,nvidia-sleep,mt7921e-hibernate}.conf \
        /etc/mkinitcpio.conf.d/99-nvidia-hibernate-fix.conf \
        /etc/systemd/system/mt7921e-load.service \
        /etc/systemd/system/systemd-{hibernate,suspend-then-hibernate}.service.d/20-freeze-user-sessions.conf \
        /etc/systemd/system-sleep/50-mt7921-hibernate
sudo mv /etc/mkinitcpio.conf.d/resume.conf.disabled /etc/mkinitcpio.conf.d/resume.conf
sudo systemctl disable nvidia-{suspend,hibernate,resume}.service mt7921e-load.service
sudo modprobe mt7921e
sudo limine-mkinitcpio && sudo reboot
```

## `scripts/`

Los scripts iterativos con que se llegó a este fix (el diagnóstico fue en 3 rondas).
`install.sh` ya aplica el resultado final; estos quedan para re-aplicar a mano si un
update de driver/kernel lo rompe, y para el rollback:

| Script | Qué hace |
|---|---|
| `hibernate-nvidia-fix.sh` (v1) | modelo viejo de power-mgmt NVIDIA + `MODULES=()` + servicios |
| `hibernate-nvidia-fix-v2.sh` | `FREEZE_USER_SESSIONS=true` + primer intento del hook mt7921 |
| `hibernate-fix-v3.sh` | blacklist real de `mt7921e` + service + revierte `HibernateMode` |
| `hibernate-*-rollback.sh` | deshacen su versión |
| **`hibernate-fix-NUKE-rollback.sh`** | **borra TODO (v1+v2+v3) y deja el sistema en stock** |

Fuentes: guía de hibernación en r/cachyos, hilo de hibernación NVIDIA en r/hyprland,
gist bmcbm, Arch Wiki (Power management, NVIDIA).
