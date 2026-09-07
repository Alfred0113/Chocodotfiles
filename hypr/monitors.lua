-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

local gdk_scale = 1
local monitor_scale = 1

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
hl.monitor({ output = "DP-1", mode = "1920x1080@74.97", position = "1920x0", scale = monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°)
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Example for Framework 13 w/ 6K XDR Apple display.
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = 2 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = 2 })

-- Disable the second ghost monitor on an Apple 6K XDR over Thunderbolt.
-- hl.monitor({ output = "DP-2", disabled = true })

-- Deteccion de laptop en lua puro: no depende del PATH ni de os.execute, que
-- en el parser de Hyprland no siempre funcionan (o.is_laptop() sale falso).
local function is_laptop()
  local f = io.open("/sys/class/dmi/id/chassis_type", "r")
  if f then
    local t = tonumber((f:read("*a") or ""):match("%d+"))
    f:close()
    -- 8 Portable, 9 Laptop, 10 Notebook, 14 Sub-Notebook, 30/31/32 tablet/convertible
    if t == 8 or t == 9 or t == 10 or t == 14 or t == 30 or t == 31 or t == 32 then
      return true
    end
  end
  local b = io.open("/sys/class/power_supply/BAT0/type", "r")
  if b then b:close(); return true end
  return false
end

-- Workspace por defecto de cada monitor. En la laptop (solo eDP-1) las reglas
-- de DP-* no aplican y Hyprland arrancaba en un workspace cualquiera (2, 3...).
if is_laptop() then
  hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
else
  hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
  hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true })
end
