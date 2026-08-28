-- Extra autostart processes.
hl.on("hyprland.start", function()
  hl.exec_cmd("bash -c 'sleep 2 && uwsm-app -- spotify'")
hl.exec_cmd("[workspace special:scratchpad silent] uwsm-app -- Telegram")
hl.exec_cmd("[workspace special:zapzap silent] uwsm-app -- zapzap")
hl.exec_cmd("~/dotfiles/bin/chocomazapan-wallpaper-set random")
end)
