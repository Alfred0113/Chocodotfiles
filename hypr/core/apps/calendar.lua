-- Popup calendar (gsimplecal), toggled from the calendar icon in waybar.
-- Se solapa un poco con la barra (que está en una capa por encima, layer
-- "top") para que el borde redondeado de arriba quede oculto detrás de
-- ella y se vea como una protuberancia que sale de la barra, sin hueco.
o.window("gsimplecal", {
  float = true,
  pin = true,
  border_size = 0,
  rounding = 14,
  move = { "(monitor_w/2-window_w/2)", "16" },
  animation = "slide",
})
