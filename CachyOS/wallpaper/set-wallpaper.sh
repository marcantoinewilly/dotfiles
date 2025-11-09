#!/bin/sh
set -e

WALL_DIR="/home/marcantoinewilly/.config/wallpaper"

if [ ! -d "$WALL_DIR" ]; then
    exit 0
fi

image=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | shuf -n 1)

if [ -z "$image" ]; then
    exit 0
fi

exec swaybg -m fill -i "$image"
