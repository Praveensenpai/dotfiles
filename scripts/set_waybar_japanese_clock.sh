#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_CONFIG="$WAYBAR_DIR/config.jsonc"

mkdir -p "$WAYBAR_DIR"

echo "Setting Japanese locale clock module in Waybar config..."

if [ -f "$WAYBAR_CONFIG" ]; then
    # Ensure clock module has Japanese locale and format
    sed -i 's/"locale": .*/"locale": "ja_JP.UTF-8",/' "$WAYBAR_CONFIG"
    echo "✔ Japanese clock module configured."
fi
