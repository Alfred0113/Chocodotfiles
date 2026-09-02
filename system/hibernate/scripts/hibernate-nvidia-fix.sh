#!/usr/bin/env bash
# Arregla la hibernación en este desktop (RTX 3080 + nvidia-open 610 + CachyOS/Limine).
# Modelo "viejo" de power-management NVIDIA + saca el driver del initramfs (early KMS).
# Fuentes: r/cachyos guide, r/hyprland thread, gist bmcbm, Arch Wiki Power management.
# NO reinicia. Al terminar reinicia a mano y sigue la verificación que imprime.

set -euo pipefail
die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo ">> $*"; }

[[ $EUID -eq 0 ]] && die "Corre esto como tu usuario (usa sudo adentro), no como root."
command -v sudo >/dev/null || die "no hay sudo."
sudo -v || die "sudo falló."

# ---------- Preflight ----------
info "Verificando prerequisitos..."
lspci_out="$(lspci 2>/dev/null || true)"
grep -qi nvidia <<<"$lspci_out" || die "No veo GPU NVIDIA — este fix es solo para el desktop."
[[ -x /usr/bin/nvidia-sleep.sh ]] || die "falta /usr/bin/nvidia-sleep.sh (nvidia-utils)."
for s in nvidia-suspend nvidia-hibernate nvidia-resume; do
  [[ -e "/usr/lib/systemd/system/$s.service" ]] || die "falta $s.service (nvidia-utils)."
done
command -v limine-mkinitcpio >/dev/null || die "falta limine-mkinitcpio."
grep -qw disk /sys/power/state || die "el kernel no ofrece hibernación (no hay 'disk' en /sys/power/state)."
[[ -n "$(swapon --show=NAME --noheadings)" ]] || die "no hay swap activo."
sw=$(awk '/^SwapTotal/{print $2}' /proc/meminfo); mm=$(awk '/^MemTotal/{print $2}' /proc/meminfo)
(( sw >= mm/2 )) || die "swap $((sw/1048576)) GiB parece chico vs RAM $((mm/1048576)) GiB."
grep -q 'resume=' /proc/cmdline || die "falta 'resume=' en la cmdline (configúralo en /etc/default/limine)."
[[ "$(findmnt -no FSTYPE --target /var/tmp)" != tmpfs ]] || die "/var/tmp es tmpfs; no sirve para NVreg_TemporaryFilePath."
info "Prerequisitos OK."; echo

# ---------- Rollback ----------
RB="$HOME/hibernate-nvidia-fix-rollback.sh"
cat > "$RB" <<'ROLL'
#!/usr/bin/env bash
set -e
echo ">> Revirtiendo el fix de hibernación NVIDIA..."
sudo rm -f /etc/modprobe.d/nvidia-hibernate.conf /etc/modprobe.d/nvidia-sleep.conf \
           /etc/mkinitcpio.conf.d/99-nvidia-hibernate-fix.conf
[[ -f /etc/mkinitcpio.conf.d/resume.conf.disabled ]] && \
  sudo mv /etc/mkinitcpio.conf.d/resume.conf.disabled /etc/mkinitcpio.conf.d/resume.conf
sudo systemctl disable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service || true
sudo install -Dm644 /dev/null /etc/modprobe.d/gsr-nvidia.conf   # re-enmascara gsr (estado previo)
sudo limine-mkinitcpio
echo ">> Listo. Reinicia. Vuelve al estado previo (hibernación rota, usa Suspender)."
ROLL
chmod +x "$RB"
info "Rollback -> $RB"; echo

# ---------- 1. modprobe ----------
info "1/4  modprobe: Preserve=1 + UseKernelSuspendNotifiers=0"
sudo rm -f /etc/modprobe.d/nvidia-hibernate-fix.conf   # nuestro viejo (Preserve=0)
sudo rm -f /etc/modprobe.d/gsr-nvidia.conf             # des-enmascara gsr
sudo tee /etc/modprobe.d/nvidia-hibernate.conf >/dev/null <<'EOF'
# Hibernación NVIDIA: preservar la VRAM y guardarla en disco (no tmpfs).
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
EOF
sudo tee /etc/modprobe.d/nvidia-sleep.conf >/dev/null <<'EOF'
# Shadow de /usr/lib/modprobe.d/nvidia-sleep.conf: modelo viejo, sin kernel
# notifiers -> se usan los servicios nvidia-* + /proc/driver/nvidia/suspend.
options nvidia NVreg_UseKernelSuspendNotifiers=0 NVreg_TemporaryFilePath=/var/tmp
EOF

# ---------- 2. servicios ----------
info "2/4  habilitando nvidia-{suspend,hibernate,resume}.service"
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# ---------- 3. sacar nvidia del initramfs ----------
info "3/4  99-nvidia-hibernate-fix.conf -> MODULES=() (override de 10-chwd.conf)"
sudo tee /etc/mkinitcpio.conf.d/99-nvidia-hibernate-fix.conf >/dev/null <<'EOF'
# Corre DESPUÉS de 10-chwd.conf (sort -V): vacía MODULES para que NVIDIA no
# entre al initramfs. Early-KMS + PreserveVideoMemoryAllocations rompe el
# resume desde hibernación (pci_pm_freeze -5 / Xid 13).
MODULES=()
EOF

# ---------- 4. hook resume redundante ----------
info "4/4  desactivando el hook 'resume' (el hook systemd lo reemplaza)"
[[ -f /etc/mkinitcpio.conf.d/resume.conf ]] && \
  sudo mv /etc/mkinitcpio.conf.d/resume.conf /etc/mkinitcpio.conf.d/resume.conf.disabled

# ---------- regenerar ----------
info "Regenerando initramfs + UKI (limine-mkinitcpio)..."
sudo limine-mkinitcpio

cat <<EOF

==========================================================
 LISTO.  Ahora:   sudo reboot
==========================================================

 Al volver, ANTES de probar:
   grep -iE 'Preserve|Notifier|Temporary' /proc/driver/nvidia/params
       -> Preserve: 1  |  Notifiers: 0  |  Temporary: /var/tmp
   ls /proc/driver/nvidia/suspend                    # debe existir
   systemctl is-enabled nvidia-hibernate.service     # enabled
   journalctl -b 0 | grep -nE "Inserted module 'nvidia|Switching root"
       -> 'nvidia' DESPUÉS de 'Switching root' (o no aparece)

 Si todo bien: abre 2-3 apps y  systemctl hibernate
 Espera apagado total, prende. Debe volver con las apps.

 Rollback:  $RB   (o bootear un snapshot en el menú de Limine)
EOF
