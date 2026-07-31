#!/bin/bash

# Ensure Japanese locale (ja_JP.UTF-8) is enabled and generated in the system
if ! grep -q "^ja_JP.UTF-8 UTF-8" /etc/locale.gen 2>/dev/null; then
    echo "Uncommenting ja_JP.UTF-8 in /etc/locale.gen..."
    sudo sed -i 's/^#*ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
    echo "Generating locales..."
    sudo locale-gen
else
    echo "✔ ja_JP.UTF-8 locale is already enabled in /etc/locale.gen"
fi

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_CONFIG="$WAYBAR_DIR/config.jsonc"

mkdir -p "$WAYBAR_DIR"

echo "Setting Japanese locale clock module in Waybar config..."

if [ -f "$WAYBAR_CONFIG" ]; then
    # Ensure clock module has Japanese locale and format
    sed -i 's/"locale": .*/"locale": "ja_JP.UTF-8",/' "$WAYBAR_CONFIG"
    echo "✔ Japanese clock module configured."
fi
