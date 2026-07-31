#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_STYLE="$WAYBAR_DIR/style.css"

mkdir -p "$WAYBAR_DIR"

echo "Setting Bluetooth icon state colors in Waybar style..."

if [ -f "$WAYBAR_STYLE" ]; then
    # Ensure bluetooth styling rules exist
    if ! grep -q "#bluetooth.connected" "$WAYBAR_STYLE"; then
        cat << 'EOF' >> "$WAYBAR_STYLE"

#bluetooth.connected {
  margin-right: 17px;
  color: #a9e790;
}

#bluetooth,
#bluetooth.on {
  margin-right: 17px;
  color: #f5a97f;
}

#bluetooth.off,
#bluetooth.disabled {
  margin-right: 17px;
  color: #565f89;
}
EOF
    fi
    echo "✔ Bluetooth Waybar state colors updated."
fi
