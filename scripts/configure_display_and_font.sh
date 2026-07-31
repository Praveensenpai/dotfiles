#!/bin/bash

# 1. Update Alacritty font size to 10 and window padding to 14
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    echo "Updating Alacritty font size and padding in $ALACRITTY_CONF..."
    if grep -q "^size =" "$ALACRITTY_CONF"; then
        sed -i 's/^size = .*/size = 10/' "$ALACRITTY_CONF"
    else
        echo "size = 10" >> "$ALACRITTY_CONF"
    fi
    if grep -q "^padding.x =" "$ALACRITTY_CONF"; then
        sed -i 's/^padding.x = .*/padding.x = 14/' "$ALACRITTY_CONF"
    fi
    if grep -q "^padding.y =" "$ALACRITTY_CONF"; then
        sed -i 's/^padding.y = .*/padding.y = 14/' "$ALACRITTY_CONF"
    fi
    echo "✔ Alacritty font size & padding updated."
else
    echo "⚠ $ALACRITTY_CONF not found. Creating..."
    mkdir -p "$(dirname "$ALACRITTY_CONF")"
    cat << 'EOF' > "$ALACRITTY_CONF"
[font]
size = 10

[window]
padding.x = 14
padding.y = 14
decorations = "None"
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

# 3. Update Hyprland border colors in looknfeel.conf
HYPR_LOOK_CONF="$HOME/.config/hypr/looknfeel.conf"
if [ -f "$HYPR_LOOK_CONF" ]; then
    echo "Updating Hyprland border colors in $HYPR_LOOK_CONF..."
    if grep -q "col.active_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/col.active_border = .*/col.active_border = rgba(7aa2f755)/' "$HYPR_LOOK_CONF"
    fi
    if grep -q "col.inactive_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/col.inactive_border = .*/col.inactive_border = rgba(59595922)/' "$HYPR_LOOK_CONF"
    fi
    echo "✔ Hyprland border colors updated."
fi
