#!/bin/bash

# Update Hyprland monitor scale to 1.5
HYPR_MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
if [ -f "$HYPR_MONITORS_CONF" ]; then
    echo "Updating Hyprland monitor scale in $HYPR_MONITORS_CONF..."
    if grep -q "^monitor=" "$HYPR_MONITORS_CONF"; then
        sed -i 's/^monitor=.*/monitor=,preferred,auto,1.5/' "$HYPR_MONITORS_CONF"
    else
        echo "monitor=,preferred,auto,1.5" >> "$HYPR_MONITORS_CONF"
    fi
    echo "✔ Hyprland monitor scale set to 1.5."
else
    echo "⚠ $HYPR_MONITORS_CONF not found. Creating..."
    mkdir -p "$(dirname "$HYPR_MONITORS_CONF")"
    cat << 'EOF' > "$HYPR_MONITORS_CONF"
monitor=,preferred,auto,1.5
EOF
    echo "✔ Hyprland monitor config created."
fi
