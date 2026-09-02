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
