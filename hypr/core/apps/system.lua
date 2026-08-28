o.window({ tag = "floating-window" }, { float = true, center = true, size = { 875, 600 } })

o.window("(org.chocomazapan.bluetui|org.chocomazapan.impala|org.chocomazapan.wiremix|org.chocomazapan.btop|org.chocomazapan.terminal|org.chocomazapan.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|TUI.float|imv|mpv)", { tag = "+floating-window" })
o.window({ class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)", title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)" }, { tag = "+floating-window" })
o.window("org.gnome.Calculator", { float = true })

-- Screen saver should always cover the screen and not be tiled.
o.window("org.chocomazapan.screensaver", { fullscreen = true, float = true, animation = "slide" })

-- Media/image/video apps should be opaque.
o.window("^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$", { tag = "-default-opacity", opacity = "1 1" })

-- Common app-controlled tags.
o.window({ tag = "pop" }, { rounding = 8 })
o.window({ tag = "noidle" }, { idle_inhibit = "always" })
