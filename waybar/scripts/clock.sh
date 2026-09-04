#!/bin/bash
FLAG="$HOME/.config/waybar/.clock-alt"
if [ -f "$FLAG" ]; then
    week=$(date +"%V")
    year=$(date +"%Y")
    echo "Semana $week · $year"
else
    day=$(LC_TIME=es_MX.UTF-8 date +"%a")
    day="${day^}"
    month=$(LC_TIME=es_MX.UTF-8 date +"%b" | tr -d '.')
    month="${month^}"
    dnum=$(date +"%d")
    time=$(date +"%I:%M:%S")
    hour=$(date +"%H")
    if [ "$hour" -lt 12 ]; then ampm="AM"; else ampm="PM"; fi
    echo "$day-$dnum-$month $time $ampm"
fi
