# Arranque de la sesion grafica sin display manager.
#
# En el login de tty1 (tras el autologin de agetty) reemplaza el shell por
# Hyprland gestionado por uwsm. `uwsm check may-start` ya filtra: solo corre en
# un VT libre, sin sesion grafica previa y en un shell de login -- en cualquier
# otro shell (terminal dentro de Hyprland, SSH, etc.) esto es un no-op.
#
# Enlazado por install.sh a ~/.config/fish/conf.d/ (no se toca config.fish).

if status is-login
    if type -q uwsm; and uwsm check may-start
        exec uwsm start -g -1 -e -D Hyprland hyprland.desktop
    end
end
