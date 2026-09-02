-- Volume, brightness, keyboard backlight, and touchpad controls.
o.bind("XF86AudioRaiseVolume", "Volume up", "chocomazapan-swayosd-client --output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "chocomazapan-swayosd-client --output-volume lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "chocomazapan-swayosd-client --output-volume mute-toggle", { locked = true, repeating = true })
o.bind("XF86AudioMicMute", "Mute microphone", "chocomazapan-audio-input-mute", { locked = true, repeating = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "chocomazapan-brightness-display +5%", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "chocomazapan-brightness-display 5%-", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", "chocomazapan-brightness-display 100%", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", "chocomazapan-brightness-display 1%", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "chocomazapan-brightness-keyboard up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "chocomazapan-brightness-keyboard down", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "chocomazapan-brightness-keyboard cycle", { locked = true })
o.bind("XF86TouchpadToggle", "Toggle touchpad", "chocomazapan-toggle-touchpad", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "chocomazapan-toggle-touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "chocomazapan-toggle-touchpad off", { locked = true })
o.bind("XF86RFKill", "Toggle airplane mode", "chocomazapan-toggle-airplane", { locked = true })

-- Precise volume and brightness controls.
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "chocomazapan-swayosd-client --output-volume +1", { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "chocomazapan-swayosd-client --output-volume -1", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", "chocomazapan-brightness-display +1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", "chocomazapan-brightness-display 1%-", { locked = true, repeating = true })

-- Media controls.
o.bind("XF86AudioNext", "Next track", "chocomazapan-swayosd-client --playerctl next", { locked = true })
o.bind("XF86AudioPause", "Pause", "chocomazapan-swayosd-client --playerctl play-pause", { locked = true })
o.bind("XF86AudioPlay", "Play", "chocomazapan-swayosd-client --playerctl play-pause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "chocomazapan-swayosd-client --playerctl previous", { locked = true })

o.bind("SUPER + XF86AudioMute", "Switch audio output", "chocomazapan-audio-output-switch", { locked = true })
