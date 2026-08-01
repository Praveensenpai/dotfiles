#!/bin/bash

MPV_CONF="$HOME/.config/mpv/mpv.conf"

# Ensure the mpv directory exists
mkdir -p "$(dirname "$MPV_CONF")"

# Check if alang is already set to prevent duplicate entries
if ! grep -q "alang=enm" "$MPV_CONF" 2>/dev/null; then
    echo "Appending language settings to mpv.conf..."
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Default audio and subtitle language priorities
alang=enm,eng,en,jpn,jp
slang=enm,eng,en
INNER_EOF
fi

# Check if save-position-on-quit is already set
if ! grep -q "save-position-on-quit" "$MPV_CONF" 2>/dev/null; then
    echo "Enabling save-position-on-quit in mpv.conf..."
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Save playback position when quitting mpv
save-position-on-quit=yes
INNER_EOF
fi

echo "mpv configuration updated successfully."

