o.bind("SUPER + SPACE", "Launch apps", { chocomazapan = "walker" })
o.bind("SUPER + CTRL + E", "Emoji picker", { chocomazapan = "walker -m symbols" })
o.bind_menu("SUPER + CTRL + C", "Capture menu", "capture")
o.bind_menu("SUPER + CTRL + O", "Toggle menu", "toggle")
-- Hardware menu dropped in Fase 4 (laptop-specific toggles not relevant here).
o.bind_menu("SUPER + SHIFT + code:201", "Menu", nil)
o.bind_menu("SUPER + ESCAPE", "System menu", "system")
o.bind_menu("XF86PowerOff", "Power menu", "system", { locked = true })
o.bind("SUPER + K", "Show key bindings", "chocomazapan-menu-keybindings")
o.bind("SUPER + ALT + K", "Show Tmux key bindings", "chocomazapan-menu-tmux-keybindings")
o.bind("XF86Calculator", "Calculator", "gnome-calculator")

o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "chocomazapan-toggle-waybar")
o.bind("SUPER + SHIFT + CTRL + UP", "Move Waybar to top", "chocomazapan-style-waybar-position top")
o.bind("SUPER + SHIFT + CTRL + DOWN", "Move Waybar to bottom", "chocomazapan-style-waybar-position bottom")
o.bind("SUPER + SHIFT + CTRL + LEFT", "Move Waybar to left", "chocomazapan-style-waybar-position left")
o.bind("SUPER + SHIFT + CTRL + RIGHT", "Move Waybar to right", "chocomazapan-style-waybar-position right")
o.bind("SUPER + CTRL + SPACE", "Wallpaper switcher", "chocomazapan-wallpaper-set")
-- Separate "theme menu" dropped — the wallpaper picker IS the theme now (Fase 1b).
o.bind("SUPER + BACKSPACE", "Toggle window transparency", "chocomazapan-hyprland-window-transparency-toggle")
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", "chocomazapan-hyprland-window-gaps-toggle")
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", "chocomazapan-hyprland-window-single-square-aspect-toggle")

o.bind("SUPER + COMMA", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + COMMA", "Dismiss all notifications", "makoctl dismiss --all")
o.bind("SUPER + CTRL + COMMA", "Toggle silencing notifications", "chocomazapan-toggle-notification-silencing")
o.bind("SUPER + ALT + COMMA", "Invoke last notification", "makoctl invoke")
o.bind("SUPER + SHIFT + ALT + COMMA", "Restore last notification", "makoctl restore")

o.bind_toggle("SUPER + CTRL + I", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
-- Laptop-only binds (display interno / lid switch) deferred a Fase 8: los
-- scripts que llaman (monitor-internal, monitor-internal-mirror) aún no
-- están vendorizados. Al descomentar, envolver en `if o.is_laptop() then`.
-- o.bind("SUPER + CTRL + Delete", "Toggle laptop display", "chocomazapan-hyprland-monitor-internal toggle")
-- o.bind("SUPER + CTRL + ALT + Delete", "Toggle laptop display mirroring", "chocomazapan-hyprland-monitor-internal-mirror toggle")
-- o.bind("switch:on:Lid Switch", nil, "chocomazapan-hw-external-monitors && chocomazapan-hyprland-monitor-internal off", { locked = true })
-- o.bind("switch:off:Lid Switch", nil, "chocomazapan-hyprland-monitor-internal on", { locked = true })

o.bind("PRINT", "Screenshot", "chocomazapan-capture-screenshot")
o.bind_menu("ALT + PRINT", "Screenrecording", "screenrecord")
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", "chocomazapan-capture-text-extraction")

-- Share menu dropped in Fase 4 (not used).

o.bind("SUPER + CTRL + PERIOD", "Transcode", "chocomazapan-transcode")

-- Reminders dropped in Fase 4 (not used).

o.bind("SUPER + CTRL + ALT + T", "Show time", "chocomazapan-notification-time")
o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "chocomazapan-notification-battery")
o.bind("SUPER + CTRL + ALT + W", "Show weather", "chocomazapan-notification-weather")

o.bind("SUPER + CTRL + A", "Audio controls", { chocomazapan = "audio" })
o.bind("SUPER + CTRL + B", "Bluetooth controls", { chocomazapan = "bluetooth" })
o.bind("SUPER + CTRL + W", "Wifi controls", { chocomazapan = "wifi" })
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

o.bind("SUPER + CTRL + L", "Lock system", "chocomazapan-system-lock")
