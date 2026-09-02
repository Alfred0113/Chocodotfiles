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
