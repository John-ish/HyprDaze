#!/bin/bash

WALLPAPER_DIR="/home/johnish/.config/wpg/wallpapers"
INDEX_FILE="$HOME/.scripts/.wallpaper_index"

# Enable safe globbing
shopt -s nullglob extglob

# Create index file if it doesn't exist
if [ ! -f "$INDEX_FILE" ]; then
    echo 0 > "$INDEX_FILE"
fi

# Read current index safely (default to 0 if empty)
index=$(cat "$INDEX_FILE" 2>/dev/null)
index=${index:-0}

# Collect all supported images
files=("$WALLPAPER_DIR"/*.@(png|jpg|jpeg|gif))

# If no wallpapers found, exit
if [ ${#files[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Ensure index wraps correctly (avoid out-of-range issues)
index=$(( index % ${#files[@]} ))

# Get current wallpaper file
file="${files[$index]}"

# Verify file exists before applying
if [ ! -f "$file" ]; then
    echo "Wallpaper not found: $file"
    exit 1
fi

# --- WPG INTEGRATION ---

# 1. Apply the WPG color scheme associated with the file.
# The 'wpg -s' command registers the wallpaper and applies the scheme
# that was previously saved/associated with that file (using the wpgtk UI or 'wpg -s <file> -A <scheme>').
# We use the -a flag to tell wpg *not* to set the wallpaper itself, as swww will handle that.
# The default WPG behavior is to apply the scheme it has saved for that file path.

if ! swww img "$file" --transition-fps 60 --transition-type any --transition-duration 2; then
    echo "Failed to set wallpaper using swww."
    exit 1
fi

if ! wpg -s "$file" -a "$file"; then
    echo "Failed to apply WPG color scheme for $file"
    exit 1
fi

# 2. Set the wallpaper using swww


# --- END WPG INTEGRATION ---

# Increment and wrap index
index=$(( (index + 1) % ${#files[@]} ))

# Save new index
echo "$index" > "$INDEX_FILE"
