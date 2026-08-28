-- Application bindings.
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(chocomazapan-cmd-terminal-cwd)"]]), { description = "Terminal" })
hl.bind("SUPER + ALT + RETURN", hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(chocomazapan-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s Work"]]), { description = "Tmux" })
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd("chocomazapan-launch-browser"), { description = "Browser" })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"), { description = "File manager" })
hl.bind("SUPER + ALT + SHIFT + F", hl.dsp.exec_cmd([[uwsm-app -- nautilus --new-window "$(chocomazapan-cmd-terminal-cwd)"]]), { description = "File manager (cwd)" })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("chocomazapan-launch-browser"), { description = "Browser" })
hl.bind("SUPER + SHIFT + ALT + B", hl.dsp.exec_cmd("chocomazapan-launch-browser --private"), { description = "Browser (private)" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("chocomazapan-launch-or-focus spotify"), { description = "Music" })
hl.bind("SUPER + SHIFT + ALT + M", hl.dsp.exec_cmd("chocomazapan-launch-or-focus-tui cliamp"), { description = "Music TUI" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("chocomazapan-launch-editor"), { description = "Editor" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("chocomazapan-launch-tui lazydocker"), { description = "Docker" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd([[chocomazapan-launch-or-focus ^signal$ "uwsm-app -- signal-desktop"]]), { description = "Signal" })
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd([[chocomazapan-launch-or-focus ^obsidian$ "uwsm-app -- obsidian"]]), { description = "Obsidian" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("uwsm-app -- typora --enable-wayland-ime"), { description = "Typora" })
hl.bind("SUPER + SHIFT + SLASH", hl.dsp.exec_cmd("uwsm-app -- 1password"), { description = "Passwords" })

-- Web app bindings.
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://chatgpt.com"]]), { description = "ChatGPT" })
hl.bind("SUPER + SHIFT + ALT + A", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://grok.com"]]), { description = "Grok" })
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://app.hey.com/calendar/weeks/"]]), { description = "Calendar" })
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://app.hey.com"]]), { description = "Email" })
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://youtube.com/"]]), { description = "YouTube" })
hl.bind("SUPER + SHIFT + ALT + G", hl.dsp.exec_cmd([[chocomazapan-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"]]), { description = "WhatsApp" })
hl.bind("SUPER + SHIFT + CTRL + G", hl.dsp.exec_cmd([[chocomazapan-launch-or-focus-webapp "Google Messages" "https://messages.google.com/web/conversations"]]), { description = "Google Messages" })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd([[chocomazapan-launch-or-focus-webapp "Google Photos" "https://photos.google.com/"]]), { description = "Google Photos" })
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://x.com/"]]), { description = "X" })
hl.bind("SUPER + SHIFT + ALT + X", hl.dsp.exec_cmd([[chocomazapan-launch-webapp "https://x.com/compose/post"]]), { description = "X Post" })

-- Add extra bindings below.
-- hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("alacritty -e ssh your-server"), { description = "SSH" })

-- Overwrite existing bindings with hl.unbind() first if needed.
-- hl.unbind("SUPER + SPACE")
-- hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("chocomazapan-menu"), { description = "Menu" })

-- Own menu binding, replacing the previous default SUPER+ALT+SPACE binding
-- (that default lives in a separate bindings tree, not in this file — see README).
hl.unbind("SUPER + ALT + SPACE")
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("chocomazapan-menu"), { description = "Menu" })

-- Override monitor scaling cycle to preserve monitor positions
hl.unbind("SUPER + code:61")
hl.unbind("SUPER + ALT + code:61")
hl.bind("SUPER + code:61",       hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/monitor-scaling-cycle.sh"),            { description = "Cycle monitor scaling" })
hl.bind("SUPER + ALT + code:61", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/monitor-scaling-cycle.sh --reverse"), { description = "Cycle monitor scaling backwards" })

-- Logitech MX Keys examples:
-- hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("chocomazapan-capture-screenshot"))
-- hl.bind("SUPER + H", hl.dsp.exec_cmd("voxtype record toggle"))
-- hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("chocomazapan-launch-walker -m symbols"))

-- Named scratchpads per app
hl.window_rule({ match = { class = "^(Spotify)$" }, workspace = "special:spotify silent", focus_on_activate = false })
hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("spotify"), { description = "Toggle Spotify scratchpad" })

hl.window_rule({ match = { class = "^(com.rtosta.zapzap)$" }, workspace = "special:zapzap silent" })
hl.bind("SUPER + Z", hl.dsp.workspace.toggle_special("zapzap"), { description = "Toggle ZapZap scratchpad" })
