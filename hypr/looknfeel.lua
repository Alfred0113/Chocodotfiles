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

-- El core (core/apps/walker.lua) apagaba las animaciones de Walker con
-- no_anim = true; ahí quedó comentado (no_anim no se puede revertir con
-- una regla posterior). Aquí se define el estilo de Walker.
hl.layer_rule({ match = { namespace = "walker" }, animation = "slide" })
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

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Todo con estilo "slide" y curva easeOutExpo (cmzExpo), rápido (~200 ms).
-- Reactiva el slide entre workspaces (el core lo tiene apagado) y deja el
-- rebote (cmzBounce) solo en layersIn -> Walker/mako/swayosd al aparecer.
-- Redefinir un leaf/curva sobrescribe el valor del core.
hl.curve("cmzExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("cmzInOut", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })
-- Overshoot: pasa de largo (~y=1.6) y regresa a su sitio -> efecto rebote.
hl.curve("cmzBounce", { type = "bezier", points = { { 0.22, 1.6 }, { 0.5, 1 } } })

-- OJO: en Hyprland "speed" = DURACIÓN en decisegundos. Número más BAJO =
-- animación más rápida.
hl.animation({ leaf = "windows", enabled = true, speed = 2.2, bezier = "cmzExpo", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.2, bezier = "cmzExpo", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.85, bezier = "cmzExpo", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.4, bezier = "cmzExpo" })
hl.animation({ leaf = "border", enabled = true, speed = 2.9, bezier = "cmzExpo" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.65, bezier = "cmzExpo" })
-- layersIn con rebote para que Walker "rebote" al aparecer (también afecta
-- a mako/swayosd al aparecer; el resto de capas y la salida van sin rebote).
hl.animation({ leaf = "layers", enabled = true, speed = 2.3, bezier = "cmzExpo", style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.9, bezier = "cmzBounce", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.1, bezier = "cmzExpo", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.2, bezier = "cmzInOut", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.3, bezier = "cmzExpo", style = "slidevert" })

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
