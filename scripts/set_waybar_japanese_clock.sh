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
HYPR_ENVS_LUA="$HOME/.config/hypr/envs.lua"
HYPR_MAIN_LUA="$HOME/.config/hypr/hyprland.lua"
BASHRC="$HOME/.bashrc"

echo "Setting Japanese locale clock module & environment variables..."

if [ -f "$HYPR_MAIN_LUA" ] && ! grep -q "require(\"hypr.envs\")" "$HYPR_MAIN_LUA"; then
    sed -i '/require("hypr.monitors")/a require("hypr.envs")' "$HYPR_MAIN_LUA"
fi

if [ -f "$HYPR_ENVS_LUA" ]; then
    if ! grep -q 'LC_TIME' "$HYPR_ENVS_LUA"; then
        echo 'hl.env("LC_TIME", "ja_JP.UTF-8")' >> "$HYPR_ENVS_LUA"
    fi
else
    mkdir -p "$(dirname "$HYPR_ENVS_LUA")"
    echo 'hl.env("LC_TIME", "ja_JP.UTF-8")' > "$HYPR_ENVS_LUA"
fi

if ! grep -q 'LC_TIME' "$BASHRC"; then
    echo 'export LC_TIME="ja_JP.UTF-8"' >> "$BASHRC"
fi

if [ -f "$WAYBAR_CONFIG" ]; then
    sed -i 's/"locale": .*/"locale": "ja_JP.UTF-8",/' "$WAYBAR_CONFIG"
    echo "✔ Japanese clock module configured."
fi
