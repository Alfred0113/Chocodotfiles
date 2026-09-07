#!/bin/bash
# Cicla la escala de la pantalla:  SUPER + /  avanza,  SUPER + ALT + /  retrocede.
#   1 -> 1.5 -> 2 -> 2.5 -> (vuelve a 1)
#
# NO reescribe el layout de monitores: solo parcha las dos variables `local`
# de monitors.lua y hace `hyprctl reload`, que relee el archivo entero (incluida
# la regla comodin para monitores externos). Asi funciona igual con la pantalla
# interna sola o con un monitor conectado.

set -euo pipefail

SCALES=(1 1.5 2 2.5)
# GDK_SCALE es entero (afecta apps GTK/Xwayland nuevas); se redondea hacia arriba.
GDK_SCALES=(1 2 2 3)

MONITOR_LUA="$HOME/.config/hypr/monitors.lua"

current_scale=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')

current_idx=0
for i in "${!SCALES[@]}"; do
  near=$(awk "BEGIN{d=${SCALES[$i]}-$current_scale; if(d<0)d=-d; print (d<0.05)}")
  if [[ $near == "1" ]]; then
    current_idx=$i
    break
  fi
done

if [[ ${1:-} == "--reverse" ]]; then
  new_idx=$(( (current_idx - 1 + ${#SCALES[@]}) % ${#SCALES[@]} ))
else
  new_idx=$(( (current_idx + 1) % ${#SCALES[@]} ))
fi

new_scale=${SCALES[$new_idx]}
new_gdk=${GDK_SCALES[$new_idx]}

sed -i -E \
  -e "s/^local gdk_scale = .*/local gdk_scale = $new_gdk/" \
  -e "s/^local monitor_scale = .*/local monitor_scale = $new_scale/" \
  "$MONITOR_LUA"

hyprctl reload >/dev/null

notify-send -u low "󰍹    Escala de pantalla: ${new_scale}x"
