-- Baseline input config. hypr/input.lua (loaded after this) overrides
-- specific values (e.g. kb_options) without needing to repeat all of them.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "compose:caps",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,

    touchpad = {
      natural_scroll = false,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})
