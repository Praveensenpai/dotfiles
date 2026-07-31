#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_STYLE="$WAYBAR_DIR/style.css"

mkdir -p "$WAYBAR_DIR"

echo "Setting Battery state colors in Waybar style..."

if [ -f "$WAYBAR_STYLE" ]; then
    # Remove old battery charging rules if present and replace with unconditional rules
    sed -i '/#battery\.charging/d' "$WAYBAR_STYLE"
    sed -i '/#battery\.full/d' "$WAYBAR_STYLE"
    sed -i '/#battery\.plugged/d' "$WAYBAR_STYLE"

    cat << 'EOF' >> "$WAYBAR_STYLE"

/* Battery state colors (always active: discharging, charging, full) */
#battery.critical,
#battery.warning,
#battery.low {
  color: #ff9eaf; /* Low: Soft Red (0-30%) */
}

#battery.medium {
  color: #f3d38c; /* Medium: Soft Yellow (31-70%) */
}

#battery.high,
#battery.full,
#battery.plugged {
  color: #a9e790; /* High / Full (100%): Soft Green (71-100%) */
}
EOF
    echo "✔ Battery Waybar state colors updated."
fi
