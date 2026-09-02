#!/usr/bin/env bash
# Fix v2 de hibernación (encima del v1, que ya arregló NVIDIA).
# Ataca los 2 blockers nuevos que se vieron en los logs:
#   1) cuelgue de ~5 min: nvidia guardando VRAM con las apps sin congelar
#      (drop-in de nvidia-utils pone SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false).
#      -> se re-activa el freeze SOLO para hibernate/suspend-then-hibernate.
#   2) la WiFi MediaTek MT7921 falla el ciclo suspend/resume interno de la
#      hibernación (pci_pm_restore -> -110) y aborta la escritura de la imagen.
#      -> hook system-sleep que descarga mt7921e antes y lo recarga después.
# NO reinicia. Genera ~/hibernate-nvidia-fix-v2-rollback.sh

set -euo pipefail
die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo ">> $*"; }

[[ $EUID -eq 0 ]] && die "Corre esto como tu usuario (usa sudo adentro), no como root."
command -v sudo >/dev/null || die "no hay sudo."
sudo -v || die "sudo falló."

# ---------- Preflight ----------
info "Verificando..."
mods_out="$(lsmod || true)"
grep -q '^mt7921e' <<<"$mods_out" || info "AVISO: mt7921e no está cargado ahora (¿otra WiFi?). El hook igual se instala; no estorba."
[[ -f /usr/lib/systemd/system/systemd-hibernate.service.d/10-nvidia-no-freeze-session.conf ]] \
  || info "AVISO: no encontré el drop-in de nvidia FREEZE_USER_SESSIONS; el override se pone igual."
info "OK."; echo

# ---------- Rollback ----------
RB="$HOME/hibernate-nvidia-fix-v2-rollback.sh"
cat > "$RB" <<'ROLL'
#!/usr/bin/env bash
set -e
echo ">> Revirtiendo fix v2 de hibernación..."
sudo rm -f /etc/systemd/system/systemd-hibernate.service.d/20-freeze-user-sessions.conf \
           /etc/systemd/system/systemd-suspend-then-hibernate.service.d/20-freeze-user-sessions.conf \
           /etc/systemd/system-sleep/50-mt7921-reload
sudo rmdir --ignore-fail-on-non-empty \
  /etc/systemd/system/systemd-hibernate.service.d \
  /etc/systemd/system/systemd-suspend-then-hibernate.service.d 2>/dev/null || true
sudo systemctl daemon-reload
echo ">> Listo. (El fix v1 de NVIDIA sigue puesto; para quitarlo: ~/hibernate-nvidia-fix-rollback.sh)"
ROLL
chmod +x "$RB"
info "Rollback -> $RB"; echo

# ---------- 1. re-activar freeze de sesiones (solo hibernate) ----------
info "1/2  override SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=true para hibernate"
for svc in systemd-hibernate.service systemd-suspend-then-hibernate.service; do
  d="/etc/systemd/system/${svc}.d"
  sudo mkdir -p "$d"
  sudo tee "$d/20-freeze-user-sessions.conf" >/dev/null <<'EOF'
# Override del drop-in 10-nvidia-no-freeze-session.conf de nvidia-utils.
# En el modelo viejo (nvidia-sleep.sh hace chvt 63) el compositor ya está
# fuera de la GPU, así que congelar las sesiones es seguro y evita el
# cuelgue de ~5 min guardando VRAM con las apps activas.
[Service]
Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=true
EOF
done

# ---------- 2. hook: descargar mt7921e alrededor de la hibernación ----------
info "2/2  /etc/systemd/system-sleep/50-mt7921-reload"
sudo mkdir -p /etc/systemd/system-sleep
sudo tee /etc/systemd/system-sleep/50-mt7921-reload >/dev/null <<'EOF'
#!/bin/bash
# La WiFi MediaTek MT7921 (mt7921e) no sobrevive el ciclo suspend/resume
# interno de la hibernación: pci_pm_restore -> -110 y aborta la imagen.
# Se descarga antes de hibernar y se recarga al volver. Solo hibernación.

case "$2" in
  hibernate|suspend-then-hibernate) ;;
  *) exit 0 ;;
esac

case "$1" in
  pre)
    for n in /sys/class/net/*/; do
      [[ -e "${n}wireless" || -e "${n}phy80211" ]] && ip link set "$(basename "$n")" down 2>/dev/null || true
    done
    modprobe -r mt7921e 2>/dev/null || true
    modprobe -r mt7921_common mt792x_lib mt76_connac_lib mt76 2>/dev/null || true
    ;;
  post)
    modprobe mt7921e 2>/dev/null || true
    ;;
esac
exit 0
EOF
sudo chmod +x /etc/systemd/system-sleep/50-mt7921-reload

sudo systemctl daemon-reload

cat <<EOF

==========================================================
 LISTO v2.  Ahora:   sudo reboot
==========================================================

 Al volver, verifica:
   systemctl show systemd-hibernate.service -p Environment | grep -o 'FREEZE_USER_SESSIONS=[a-z]*'
       -> FREEZE_USER_SESSIONS=true
   test -x /etc/systemd/system-sleep/50-mt7921-reload && echo "hook mt7921 OK"

 Prueba (con 2-3 apps abiertas):  systemctl hibernate
   - Ya NO debería tardar 5 min ni abortar.
   - Debe apagarse del todo. Al prender, reanuda con las apps.

 Si funciona pero la WiFi no reconecta sola al volver:
   sudo modprobe mt7921e      (y iwd la retoma)

 Rollback v2:  $RB
EOF
