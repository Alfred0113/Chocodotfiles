#!/bin/bash
FLAG="$HOME/.config/waybar/.clock-alt"
if [ -f "$FLAG" ]; then rm "$FLAG"; else touch "$FLAG"; fi
