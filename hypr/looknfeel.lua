-- Look'n'feel overrides.

hl.config({
  decoration = {
    active_opacity = 0.90,
    inactive_opacity = 0.80,
    rounding = 8,
    blur = {
      size = 4,
      passes = 2,
      vibrancy = 0.35,
      contrast = 1.0,
      noise = 0.02,
    },
  },
})

-- Translucent, blurred waybar (macOS-style).
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.2 })

-- Same blur treatment for menus (Walker launcher, Mako notifications) and
-- the calendar popup (should look like it's literally part of the bar).
hl.layer_rule({ match = { namespace = "walker" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "chocomazapan-calendar" }, blur = true, ignore_alpha = 0.2 })

-- Reduce top gap to visually match waybar's margin-top/margin-bottom.
hl.config({
  general = {
    gaps_out = { top = 2, right = 10, bottom = 10, left = 10 },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
