-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME") or ""

-- Hyprland recommends require() for split Lua configs.
package.path = home .. "/.config/?.lua;" .. package.path

-- Core config (Fase 7a). Don't edit these directly — override in the
-- files below instead.
require("hypr.core.helpers")
require("hypr.core.autostart")
require("hypr.core.bindings.media")
require("hypr.core.bindings.clipboard")
require("hypr.core.bindings.tiling-v2")
require("hypr.core.bindings.utilities")
require("hypr.core.envs")
require("hypr.core.looknfeel")
require("hypr.core.input")
require("hypr.core.windows")

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("hypr.core.toggles")

-- Add any other personal Hyprland configuration below.
-- hl.window_rule({ match = { class = "qemu" }, workspace = "5" })

-- Save screenshots to a dedicated subfolder instead of ~/Imágenes.
hl.env("CHOCOMAZAPAN_SCREENSHOT_DIR", home .. "/Imágenes/Screenshots")

-- Force Steam games to launch on the primary gaming monitor (DP-2, 240Hz).
hl.window_rule({ match = { class = "steam_app_.*" }, monitor = "DP-2" })

-- Darktide: immediate rendering to avoid input stalls after alt-tab.
hl.window_rule({ match = { class = "steam_app_1361210" }, immediate = true })

-- DaVinci Resolve: prevent mouse confinement, shortcut inhibition, focus stealing, and black preview.
-- suppress_event="fullscreen" prevents overFullscreen state that blocks clicks on other windows.
hl.window_rule({ match = { class = "resolve" }, confine_pointer = false, no_shortcuts_inhibit = true, immediate = true, focus_on_activate = false, suppress_event = "fullscreen" })
