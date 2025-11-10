#!/bin/sh
set -e

LOG_FILE="/tmp/niri-wallpaper.log"

{
    echo "---- $(date) ----"
    echo "Starting wallpaper script"
} >>"$LOG_FILE" 2>&1 || true

WALL_DIR="/home/marcantoinewilly/.config/wallpaper"

if [ ! -d "$WALL_DIR" ]; then
    echo "Directory $WALL_DIR not found" >>"$LOG_FILE"
    exit 0
fi

image=$(find -L "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | shuf -n 1)
echo "Selected image: $image" >>"$LOG_FILE"

if [ -z "$image" ]; then
    echo "No image found" >>"$LOG_FILE"
    exit 0
fi

echo "Launching swaybg" >>"$LOG_FILE"
exec swaybg -m fill -i "$image"
