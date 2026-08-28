-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME") or ""

-- Hyprland recommends require() for split Lua configs. These two roots let us
-- load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = home .. "/.config/?.lua;" .. (os.getenv("OMARCHY_PATH") or (home .. "/.local/share/omarchy")) .. "/?.lua;" .. package.path

local paths = require("default.hypr.paths")

-- Use Omarchy defaults, but don't edit these directly.
require("default.hypr.helpers")
require("default.hypr.autostart")
require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling-v2")
require("default.hypr.bindings.utilities")
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")

-- Current theme overrides.
do
  local theme = io.open(paths.config_home .. "/omarchy/current/theme/hyprland.lua", "r")
  if theme then
    theme:close()
    require("omarchy.current.theme.hyprland")
  end
end

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- hl.window_rule({ match = { class = "qemu" }, workspace = "5" })

-- Save screenshots to a dedicated subfolder instead of ~/Imágenes.
hl.env("OMARCHY_SCREENSHOT_DIR", home .. "/Imágenes/Screenshots")

-- Force Steam games to launch on the primary gaming monitor (DP-2, 240Hz).
hl.window_rule({ match = { class = "steam_app_.*" }, monitor = "DP-2" })

-- Darktide: immediate rendering to avoid input stalls after alt-tab.
hl.window_rule({ match = { class = "steam_app_1361210" }, immediate = true })

-- DaVinci Resolve: prevent mouse confinement, shortcut inhibition, focus stealing, and black preview.
-- suppress_event="fullscreen" prevents overFullscreen state that blocks clicks on other windows.
hl.window_rule({ match = { class = "resolve" }, confine_pointer = false, no_shortcuts_inhibit = true, immediate = true, focus_on_activate = false, suppress_event = "fullscreen" })
