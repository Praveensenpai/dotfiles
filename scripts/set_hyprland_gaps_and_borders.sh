#!/bin/bash

# Update Hyprland window gaps & border colors in looknfeel.conf
HYPR_LOOK_CONF="$HOME/.config/hypr/looknfeel.conf"
if [ -f "$HYPR_LOOK_CONF" ]; then
    echo "Updating Hyprland gaps & border colors in $HYPR_LOOK_CONF..."
    
    # Gaps between windows (inner gaps) & outer gaps
    if grep -q "^[[:space:]]*gaps_in =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*gaps_in = .*/    gaps_in = 0/' "$HYPR_LOOK_CONF"
    fi
    if grep -q "^[[:space:]]*gaps_out =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*gaps_out = .*/    gaps_out = 0/' "$HYPR_LOOK_CONF"
    fi

    # Border colors
    if grep -q "^[[:space:]]*col.active_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*col.active_border = .*/    col.active_border = rgba(7aa2f755)/' "$HYPR_LOOK_CONF"
    fi
    if grep -q "^[[:space:]]*col.inactive_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*col.inactive_border = .*/    col.inactive_border = rgba(59595922)/' "$HYPR_LOOK_CONF"
    fi
    echo "✔ Hyprland gaps & border colors updated."
fi
