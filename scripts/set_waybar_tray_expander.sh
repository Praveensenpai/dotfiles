#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
TRAY_SCRIPT="$WAYBAR_DIR/tray-expander-icon.sh"

mkdir -p "$WAYBAR_DIR"

echo "Creating Waybar tray expander icon script..."
cat << 'EOF' > "$TRAY_SCRIPT"
#!/bin/bash

# The expand icon character (U+F053, fa-chevron-left)
icon=$(printf '\uf053')

# Count registered tray items via StatusNotifierWatcher
count=$(dbus-send --session --print-reply \
  --dest=org.kde.StatusNotifierWatcher \
  /StatusNotifierWatcher \
  org.freedesktop.DBus.Properties.Get \
  string:org.kde.StatusNotifierWatcher \
  string:RegisteredStatusNotifierItems 2>/dev/null \
  | grep -c '"')

if [ "$count" -gt 0 ]; then
  echo "{\"text\": \"$icon\", \"class\": \"has-items\"}"
else
  echo "{\"text\": \"$icon\", \"class\": \"no-items\"}"
fi
EOF

chmod +x "$TRAY_SCRIPT"
echo "✔ Waybar tray expander script deployed."
