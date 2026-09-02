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
