#!/bin/bash

# 1. Update Alacritty font size to 10
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    echo "Updating Alacritty font size to 10 in $ALACRITTY_CONF..."
    if grep -q "^size =" "$ALACRITTY_CONF"; then
        sed -i 's/^size = .*/size = 10/' "$ALACRITTY_CONF"
    else
        # Append size setting to [font] section if present, or at the end
        echo "size = 10" >> "$ALACRITTY_CONF"
    fi
    echo "✔ Alacritty font size updated."
else
    echo "⚠ $ALACRITTY_CONF not found. Creating..."
    mkdir -p "$(dirname "$ALACRITTY_CONF")"
    cat << 'EOF' > "$ALACRITTY_CONF"
[font]
size = 10
EOF
    echo "✔ Alacritty config created."
fi

# 2. Update Hyprland monitor scale to 1.5
HYPR_MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
if [ -f "$HYPR_MONITORS_CONF" ]; then
    echo "Updating Hyprland monitor scale to 1.5 in $HYPR_MONITORS_CONF..."
    if grep -q "^monitor=" "$HYPR_MONITORS_CONF"; then
        sed -i 's/^monitor=.*/monitor=,preferred,auto,1.5/' "$HYPR_MONITORS_CONF"
    else
        echo "monitor=,preferred,auto,1.5" >> "$HYPR_MONITORS_CONF"
    fi
    echo "✔ Hyprland monitor scale updated."
else
    echo "⚠ $HYPR_MONITORS_CONF not found. Creating..."
    mkdir -p "$(dirname "$HYPR_MONITORS_CONF")"
    cat << 'EOF' > "$HYPR_MONITORS_CONF"
monitor=,preferred,auto,1.5
EOF
    echo "✔ Hyprland monitor config created."
fi
