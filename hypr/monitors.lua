-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all
--
-- Rama t14: config de laptop. La pantalla interna manda; cualquier monitor
-- externo entra a su resolucion nativa, colocado solo a la derecha.

-- Sube ambos a 1.25 si la UI se ve chica en la pantalla de 14" (1920x1200 nativo).
local gdk_scale = 1
local monitor_scale = 1

-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
-- local gdk_scale = 2
-- local monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(gdk_scale))

-- Pantalla interna: ancla en 0x0, resolucion preferida.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = monitor_scale })

-- Comodin: cualquier otro output (DP-1, HDMI-A-1, DP-3, un dock...) a su
-- resolucion nativa, colocado automaticamente a la derecha, escala 1.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Monitor externo en vertical: descomenta y ajusta el output real
-- (transform: 1 = 90 grados, 3 = 270).
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Workspace 1 siempre en la pantalla interna. Los demas monitores los coloca
-- Hyprland solo (no sabemos su nombre de antemano).
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
