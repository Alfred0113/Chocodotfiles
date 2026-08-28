#!/bin/bash
ID=$$
FIFO="/tmp/cava-waybar-${ID}.fifo"
CONF="/tmp/cava-waybar-${ID}.ini"
BARS=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█')

until pactl info &>/dev/null; do sleep 1; done

mkfifo "$FIFO"
sed "s|raw_target.*|raw_target = $FIFO|" ~/.config/cava/waybar.ini > "$CONF"

cava -p "$CONF" &
CAVA_PID=$!

cleanup() {
    kill $CAVA_PID 2>/dev/null
    rm -f "$FIFO" "$CONF"
}
trap cleanup EXIT INT TERM

while IFS=';' read -ra vals; do
    out=""
    for v in "${vals[@]}"; do
        v="${v//[^0-9]/}"
        [[ -n "$v" && "$v" -le 7 ]] && out+="${BARS[$v]}"
    done
    [[ -n "$out" ]] && echo "$out"
done < "$FIFO"
