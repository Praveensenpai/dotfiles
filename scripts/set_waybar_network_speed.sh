#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_CONFIG="$WAYBAR_DIR/config.jsonc"

mkdir -p "$WAYBAR_DIR"

echo "Setting Network (Wi-Fi) bandwidth speed display & tooltips in Waybar config..."

if [ -f "$WAYBAR_CONFIG" ]; then
    # Update network module formats to include download/upload bandwidth and clean disconnected/disabled state
    sed -i 's/"format-wifi": .*/"format-wifi": "{icon}   <span foreground=\x27#74c7ec\x27>󰇚<\/span> {bandwidthDownBytes}  <span foreground=\x27#b4befe\x27>󰕒<\/span> {bandwidthUpBytes}",/' "$WAYBAR_CONFIG"
    sed -i 's/"format-ethernet": .*/"format-ethernet": "󰀂   <span foreground=\x27#74c7ec\x27>󰇚<\/span> {bandwidthDownBytes}  <span foreground=\x27#b4befe\x27>󰕒<\/span> {bandwidthUpBytes}",/' "$WAYBAR_CONFIG"
    sed -i 's/"format-disconnected": .*/"format-disconnected": "󰤮",/' "$WAYBAR_CONFIG"
    echo "✔ Network bandwidth speed & tooltips configured."
fi
