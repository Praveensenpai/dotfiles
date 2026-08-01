#!/bin/bash

MPV_CONF="$HOME/.config/mpv/mpv.conf"

# Ensure the mpv directory exists
mkdir -p "$(dirname "$MPV_CONF")"

# Check if alang is already set to prevent duplicate entries
if grep -q "alang=enm" "$MPV_CONF" 2>/dev/null; then
    echo "mpv language tracks already set."
else
    echo "Appending language settings to mpv.conf..."
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Default audio and subtitle language priorities
alang=enm,eng,en,jpn,jp
slang=enm,eng,en
INNER_EOF
    echo "Done."
fi
