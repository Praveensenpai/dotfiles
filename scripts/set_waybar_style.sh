#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_STYLE="$WAYBAR_DIR/style.css"

mkdir -p "$WAYBAR_DIR"

echo "Deploying Waybar style.css..."
cat << 'EOF' > "$WAYBAR_STYLE"
@import "../omarchy/current/theme/waybar.css";

* {
  background-color: @background;
  color: @foreground;

  border: none;
  border-radius: 0;
  min-height: 0;
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 12px;
}

.modules-left {
  margin-left: 8px;
}

.modules-right {
  margin-right: 8px;
}

#workspaces button {
  all: initial;
  padding: 0 6px;
  margin: 0 1.5px;
  min-width: 9px;
}

#workspaces button.empty {
  opacity: 0.5;
}

#cpu,
#battery,
#pulseaudio,
#custom-omarchy,
#custom-update {
  min-width: 12px;
  margin: 0 7.5px;
}

/* CPU percentage usage colors (soft pastels) */
#cpu.low {
  color: #a9e790; /* Soft Green (0-40%) */
}

#cpu.medium {
  color: #f3d38c; /* Soft Yellow (40-70%) */
}

#cpu.high {
  color: #f5a97f; /* Soft Orange (70-90%) */
}

#cpu.critical {
  color: #ff9eaf; /* Soft Red (> 90%) */
}

/* Charging battery colors (soft tinted pastel Red, Yellow, Green, Purple) */
#battery.charging.critical,
#battery.charging.warning,
#battery.charging.low {
  color: #ff9eaf; /* Low: Soft Tinted Red (0-30%) */
}

#battery.charging.medium {
  color: #f3d38c; /* Medium: Soft Tinted Yellow (31-70%) */
}

#battery.charging.high {
  color: #a9e790; /* High: Soft Tinted Green (71-95%) */
}

#battery.charging.full,
#battery.plugged,
#battery.full {
  color: #bb9af7; /* Full: Soft Lavender / Purple (100%) */
}

#tray {
  margin-right: 16px;
}

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

#custom-expand-icon {
  margin-right: 18px;
  color: #565f89; /* faded dark grey by default (no items) */
}

#custom-expand-icon.has-items {
  color: #89b4fa; /* blue accent when tray has items */
}

tooltip {
  padding: 2px;
}

#custom-update {
  font-size: 10px;
}

#clock {
  margin-left: 8.75px;
}

.hidden {
  opacity: 0;
}

#custom-screenrecording-indicator,
#custom-idle-indicator,
#custom-notification-silencing-indicator {
  min-width: 12px;
  margin-left: 5px;
  margin-right: 0;
  font-size: 10px;
  padding-bottom: 1px;
}

#custom-screenrecording-indicator.active {
  color: #a55555;
}

#custom-idle-indicator.active,
#custom-notification-silencing-indicator.active {
  color: #a55555;
}

#custom-voxtype {
  min-width: 12px;
  margin: 0 0 0 7.5px;
}

#custom-voxtype.recording {
  color: #a55555;
}
EOF
echo "✔ Waybar style.css deployed."
