#!/usr/bin/env bash
# Fix v3 de hibernación — intento final. Encima de v1 (NVIDIA) y v2.
#   1) Revierte HibernateMode a default (platform shutdown). El modo 'shutdown'
#      forzado parece cambiar el ciclo interno de devices y romper la wifi.
#   2) Blacklist real de mt7921e: se carga con un service tras el boot, así
#      NUNCA está bindeada durante la hibernación -> no más pci_pm_restore -110.
#   3) Hook de sleep: descarga mt7921e y apaga el wakeup del dongle 2.4G antes
#      de hibernar; los restaura al volver (solo hibernación).
# NO reinicia. Genera ~/hibernate-fix-NUKE-rollback.sh que borra TODO (v1+v2+v3).

set -euo pipefail
die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo ">> $*"; }

[[ $EUID -eq 0 ]] && die "corre como tu usuario, no root."
command -v sudo >/dev/null || die "no hay sudo."
sudo -v || die "sudo falló."
command -v limine-mkinitcpio >/dev/null || die "falta limine-mkinitcpio."

info "Aplicando v3..."

# ---------- rollback total (v1+v2+v3) ----------
NUKE="$HOME/hibernate-fix-NUKE-rollback.sh"
cat > "$NUKE" <<'ROLL'
#!/usr/bin/env bash
# Borra TODO lo de hibernación (v1 NVIDIA + v2 + v3) y deja el sistema bone-stock.
set -e
echo ">> Quitando toda la config de hibernación..."
sudo rm -f /etc/modprobe.d/nvidia-hibernate.conf /etc/modprobe.d/nvidia-sleep.conf \
           /etc/modprobe.d/nvidia-hibernate-fix.conf /etc/modprobe.d/gsr-nvidia.conf \
           /etc/modprobe.d/mt7921e-hibernate.conf
sudo rm -f /etc/mkinitcpio.conf.d/99-nvidia-hibernate-fix.conf
[[ -f /etc/mkinitcpio.conf.d/resume.conf.disabled ]] && \
  sudo mv /etc/mkinitcpio.conf.d/resume.conf.disabled /etc/mkinitcpio.conf.d/resume.conf
sudo rm -f /etc/systemd/sleep.conf.d/hibernate-mode.conf \
           /etc/systemd/system/systemd-hibernate.service.d/20-freeze-user-sessions.conf \
           /etc/systemd/system/systemd-suspend-then-hibernate.service.d/20-freeze-user-sessions.conf \
           /etc/systemd/system-sleep/50-mt7921-reload \
           /etc/systemd/system-sleep/50-mt7921-hibernate \
           /etc/systemd/system/mt7921e-load.service
sudo rmdir --ignore-fail-on-non-empty \
  /etc/systemd/system/systemd-hibernate.service.d \
  /etc/systemd/system/systemd-suspend-then-hibernate.service.d 2>/dev/null || true
sudo systemctl disable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service \
                       mt7921e-load.service 2>/dev/null || true
sudo systemctl daemon-reload
sudo modprobe mt7921e 2>/dev/null || true
sudo limine-mkinitcpio
echo ">> Listo. Reinicia. Todo vuelve a stock; la hibernación queda sin configurar."
ROLL
chmod +x "$NUKE"
info "Rollback total -> $NUKE"; echo

# ---------- 1. revertir HibernateMode ----------
info "1/3  quitando HibernateMode=shutdown (vuelve a 'platform shutdown')"
sudo rm -f /etc/systemd/sleep.conf.d/hibernate-mode.conf

# ---------- 2. blacklist mt7921e + service de carga ----------
info "2/3  blacklist mt7921e + mt7921e-load.service"
sudo tee /etc/modprobe.d/mt7921e-hibernate.conf >/dev/null <<'EOF'
# La WiFi MediaTek MT7921 no sobrevive el ciclo interno de la hibernación
# (pci_pm_restore -> -110). Se blacklistea para que udev NO la cargue sola,
# y se carga con mt7921e-load.service tras el boot. Así nunca está bindeada
# durante la hibernación.
blacklist mt7921e
EOF
sudo tee /etc/systemd/system/mt7921e-load.service >/dev/null <<'EOF'
[Unit]
Description=Cargar la WiFi MT7921 (blacklisteada por la hibernación)
After=multi-user.target
ConditionPathExists=/sys/bus/pci/devices/0000:09:00.0

[Service]
Type=oneshot
ExecStart=/sbin/modprobe mt7921e
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable mt7921e-load.service

# ---------- 3. hook de sleep (reemplaza el de v2) ----------
info "3/3  /etc/systemd/system-sleep/50-mt7921-hibernate"
sudo rm -f /etc/systemd/system-sleep/50-mt7921-reload
sudo mkdir -p /etc/systemd/system-sleep
sudo tee /etc/systemd/system-sleep/50-mt7921-hibernate >/dev/null <<'EOF'
#!/bin/bash
# Solo hibernación: descarga la WiFi MT7921 y apaga el wakeup del dongle 2.4G
# antes; los restaura después. Con mt7921e blacklisteada, udev no la recarga
# a media hibernación.
case "$2" in hibernate|suspend-then-hibernate) ;; *) exit 0 ;; esac

dongle_wakeup() {  # $1 = enabled|disabled
  for d in /sys/bus/usb/devices/*/; do
    [ -f "$d/idVendor" ] || continue
    [ "$(cat "$d/idVendor")" = "260d" ] && [ "$(cat "$d/idProduct")" = "1114" ] || continue
    [ -w "$d/power/wakeup" ] && echo "$1" > "$d/power/wakeup" 2>/dev/null || true
  done
}

case "$1" in
  pre)
    dongle_wakeup disabled
    modprobe -r mt7921e 2>/dev/null || true
    ;;
  post)
    modprobe mt7921e 2>/dev/null || true
    dongle_wakeup enabled
    ;;
esac
exit 0
EOF
sudo chmod +x /etc/systemd/system-sleep/50-mt7921-hibernate

sudo systemctl daemon-reload

cat <<EOF

==========================================================
 LISTO v3.  Ahora:   sudo reboot
==========================================================

 Al volver, verifica:
   lsmod | grep -q '^mt7921e' && echo "wifi cargada (por el service)"
   systemctl show systemd-hibernate.service -p Environment | grep -o 'FREEZE_USER_SESSIONS=[a-z]*'
   grep -H . /sys/power/disk         # -> platform [shutdown] (sin el override, default)

 Prueba con 2-3 apps:  systemctl hibernate
   - Puede tardar ~1-3 min guardando VRAM (NVIDIA), es normal.
   - Debe apagarse DEL TODO. Al prender, reanuda con las apps.
   - La wifi reconecta sola unos segundos después.

 Si NO se apaga / aborta otra vez:
   bash ~/hibernate-fix-NUKE-rollback.sh   &&  sudo reboot
   -> borra todo, hibernación sin configurar, empezamos de cero.

 Logs si falla:
   journalctl -b -1 -k | grep -iE "PM: |hibernation|mt7921|nvidia|Xid|wakeup"
   journalctl -b 0  -k | grep -iE "PM: Image|resume"
EOF
