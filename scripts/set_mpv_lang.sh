#!/bin/bash

MPV_CONF="$HOME/.config/mpv/mpv.conf"

# Ensure the mpv directory exists
mkdir -p "$(dirname "$MPV_CONF")"

# Check if alang is already set in mpv.conf
if [ -f "$MPV_CONF" ] && grep -q "^#* *alang=" "$MPV_CONF" 2>/dev/null; then
    echo "Updating language settings in mpv.conf..."
    sed -i "s|^#* *alang=.*|alang=jpn,jp,ja,japanese|" "$MPV_CONF"
    sed -i "s|^#* *slang=.*|slang=enm,eng,en|" "$MPV_CONF"
    echo "Done."
else
    echo "Appending language settings to mpv.conf..."
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Default audio and subtitle language priorities
alang=jpn,jp,ja,japanese
slang=enm,eng,en
INNER_EOF
    echo "Done."
fi
