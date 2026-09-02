-- Config minima de Hyprland para el greeter Wayland de SDDM.
-- SDDM arranca el greeter cuando el compositor esta listo.
-- install.sh la copia a /usr/share/sddm/hyprland.lua
-- (referenciada por /etc/sddm.conf.d/10-wayland.conf: CompositorCommand).
hl.config({
  -- Teclado latam (igual que la sesion real). Sin esto el greeter usa 'us'.
  input = {
    kb_layout = "latam",
    kb_variant = "",
    kb_options = "",
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },
})
