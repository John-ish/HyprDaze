#!/bin/bash

# Desired terminal size
WIDTH=750
HEIGHT=500

# Get cursor position
POS=$(hyprctl cursorpos -j | jq -r '.x,.y')
CURSOR_X=$(echo "$POS" | sed -n 1p)
CURSOR_Y=$(echo "$POS" | sed -n 2p)

# Calculate top-left corner so terminal is centered
X=$((CURSOR_X - WIDTH / 2))
Y=$((CURSOR_Y - HEIGHT / 2))

# Launch terminal
kitty --class floating_kitty &

# Wait a moment for it to appear, then move it
sleep 0.2
hyprctl dispatch movewindowpixel exact $X $Y
