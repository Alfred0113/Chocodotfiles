-- Pantalla de login: sin display manager, Hyprland arranca bloqueado y la
-- contrasena se escribe en hyprlock (ver fish/conf.d/chocomazapan-login.fish).
o.exec_on_start("hyprlock")

o.launch_on_start("hypridle")
o.launch_on_start("mako")
o.exec_on_start("! chocomazapan-toggle-enabled waybar-off && " .. o.launch("waybar"))
-- Wallpaper is set by hypr/autostart.lua (chocomazapan-wallpaper-set random), not here.
o.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- TODO Fase 7b/8: vendorizar chocomazapan-powerprofiles-init y
-- chocomazapan-hyprland-monitor-watch (perfiles de energía + auto
-- disable/recover del monitor interno). Al descomentar, envolver en
-- `if o.is_laptop() then` — en desktop no aplican.
-- o.exec_on_start("chocomazapan-powerprofiles-init")
-- o.launch_on_start("chocomazapan-hyprland-monitor-watch")

-- Slow app launch fix -- set systemd vars.
o.exec_on_start("systemctl --user import-environment $(env | cut -d'=' -f 1)")
o.exec_on_start("dbus-update-activation-environment --systemd --all")
