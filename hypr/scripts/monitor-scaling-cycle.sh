#!/bin/bash

SCALES=(1 1.25 1.6 2 3 4)
GDK_SCALES=(1 1.25 1.75 2 3 4)
CURRENT_SCALE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')

CURRENT_IDX=0
for i in "${!SCALES[@]}"; do
  match=$(awk "BEGIN{d=${SCALES[$i]}-$CURRENT_SCALE; if(d<0)d=-d; print (d<0.05)}")
  if [[ $match == "1" ]]; then
    CURRENT_IDX=$i
    break
  fi
done

if [[ $1 == "--reverse" ]]; then
  NEW_IDX=$(( (CURRENT_IDX - 1 + ${#SCALES[@]}) % ${#SCALES[@]} ))
else
  NEW_IDX=$(( (CURRENT_IDX + 1) % ${#SCALES[@]} ))
fi

NEW_SCALE=${SCALES[$NEW_IDX]}
NEW_GDK=${GDK_SCALES[$NEW_IDX]}
NEW_POS=$(awk "BEGIN{printf \"%d\", 1920/$NEW_SCALE}")

# Aplicar ambos monitores en una sola llamada para evitar overlap momentáneo
hyprctl eval "hl.monitor({ output = \"DP-2\", mode = \"1920x1080@240\", position = \"0x0\", scale = $NEW_SCALE }); hl.monitor({ output = \"DP-1\", mode = \"1920x1080@74.97\", position = \"${NEW_POS}x0\", scale = $NEW_SCALE })" >/dev/null

# Persistir en monitors.lua en una sola escritura atómica
MONITOR_LUA="$HOME/.config/hypr/monitors.lua"
cat > "$MONITOR_LUA" << LUAEOF
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

local gdk_scale = $NEW_GDK
local monitor_scale = $NEW_SCALE

-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
-- local gdk_scale = 2
-- local monitor_scale = "auto"

-- Good compromise for 27" or 32" 4K monitors (but fractional!): monitor scale 1.6, GDK scale 1.75.
-- local gdk_scale = 1.75
-- local monitor_scale = 1.6

-- Straight 1x setup for low-resolution displays like 1080p, 1440p, or ultrawides: both 1.
-- local gdk_scale = 1
-- local monitor_scale = 1

hl.env("GDK_SCALE", tostring(gdk_scale))

-- LG ULTRAGEAR 240Hz (izquierda física)
hl.monitor({ output = "DP-2", mode = "1920x1080@240",   position = "0x0",          scale = monitor_scale })
-- LG FHD 75Hz (derecha física)
hl.monitor({ output = "DP-1", mode = "1920x1080@74.97", position = "${NEW_POS}x0", scale = monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°)
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Example for Framework 13 w/ 6K XDR Apple display.
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = 2 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = 2 })

-- Disable the second ghost monitor on an Apple 6K XDR over Thunderbolt.
-- hl.monitor({ output = "DP-2", disabled = true })

hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true })
LUAEOF

notify-send -u low "󰍹    Display scaling set to ${NEW_SCALE}x"
