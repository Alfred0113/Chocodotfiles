#!/bin/bash
mapfile -t sinks < <(pactl list sinks short | awk '{print $2}' | grep -v cava_combined)
current=$(pactl get-default-sink)

idx=0
for i in "${!sinks[@]}"; do
    [[ "${sinks[$i]}" == "$current" ]] && idx=$i && break
done

next="${sinks[$(( (idx + 1) % ${#sinks[@]} ))]}"
pactl set-default-sink "$next"

desc=$(pactl list sinks | grep -A2 "Name: $next" | grep "Description:" | sed 's/.*Description: //')
notify-send -u low -t 2000 "🔊 $desc"
