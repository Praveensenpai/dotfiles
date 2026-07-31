#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_STYLE="$WAYBAR_DIR/style.css"

mkdir -p "$WAYBAR_DIR"

echo "Setting Network (Wi-Fi) icon state colors in Waybar style..."

if [ -f "$WAYBAR_STYLE" ]; then
    if ! grep -q "#network.disabled" "$WAYBAR_STYLE"; then
        cat << 'EOF' >> "$WAYBAR_STYLE"

#network {
  margin-right: 13px;
  color: #a9e790;
}

#network.disconnected {
  color: #f5a97f;
}

#network.disabled {
  color: #565f89;
}
EOF
    fi
    echo "✔ Network (Wi-Fi) Waybar state colors updated."
fi
