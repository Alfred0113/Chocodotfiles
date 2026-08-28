#!/bin/bash
FLAG="$HOME/.config/waybar/.clock-alt"
if [ -f "$FLAG" ]; then
    LC_TIME=es_MX.UTF-8 date +"%d %B W%V %Y"
else
    day=$(LC_TIME=es_MX.UTF-8 date +"%A")
    time=$(date +"%I:%M:%S")
    hour=$(date +"%H")
    if [ "$hour" -lt 12 ]; then ampm="AM"; else ampm="PM"; fi
    echo "$day $time $ampm"
fi
