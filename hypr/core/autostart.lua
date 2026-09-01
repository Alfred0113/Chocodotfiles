o.launch_on_start("hypridle")
o.launch_on_start("mako")
o.exec_on_start("! chocomazapan-toggle-enabled waybar-off && " .. o.launch("waybar"))
-- Wallpaper is set by hypr/autostart.lua (chocomazapan-wallpaper-set random), not here.
o.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- TODO Fase 7b/8: vendorizar chocomazapan-powerprofiles-init (depende de
-- battery-present/ac-present/powerprofiles-set — más relevante en laptop).
-- o.exec_on_start("chocomazapan-powerprofiles-init")

-- TODO Fase 8: vendorizar chocomazapan-hyprland-monitor-watch (auto
-- disable/recover del monitor interno al conectar/desconectar uno externo —
-- feature de laptop, no aplica hoy en este desktop).
-- o.launch_on_start("chocomazapan-hyprland-monitor-watch")

-- Slow app launch fix -- set systemd vars.
o.exec_on_start("systemctl --user import-environment $(env | cut -d'=' -f 1)")
o.exec_on_start("dbus-update-activation-environment --systemd --all")
