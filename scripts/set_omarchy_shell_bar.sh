#!/bin/bash

# Omarchy 4 uses the Quickshell-based Omarchy Shell, not Waybar.  Keep the
# status-bar customisations in update-safe, user-owned plugin clones.
set -euo pipefail

CONFIG_DIR="$HOME/.config/omarchy"
PLUGINS_DIR="$CONFIG_DIR/plugins"
SHELL_CONFIG="$CONFIG_DIR/shell.json"
USER_PREFIX="$(id -un)"

if ! command -v omarchy >/dev/null 2>&1 || [ ! -f "$SHELL_CONFIG" ]; then
    echo "⏭ Omarchy Shell is not configured; skipping Quickshell bar customisation."
    exit 0
fi

if [ "$(omarchy version | cut -d. -f1)" -lt 4 ]; then
    echo "⏭ Omarchy $(omarchy version) still uses the legacy bar; Waybar scripts remain in effect."
    exit 0
fi

clone_widget() {
    local widget="$1"
    local plugin_id="$USER_PREFIX.$widget"

    if [ ! -d "$PLUGINS_DIR/$plugin_id" ]; then
        echo "Cloning omarchy.$widget into the user plugin directory..."
        omarchy plugin clone "omarchy.$widget"
    fi

    # Make existing clones active as well as newly-created ones.
    omarchy plugin enable "$plugin_id" >/dev/null
}

for widget in power bluetooth network audio clock; do
    clone_widget "$widget"
done

POWER_QML="$PLUGINS_DIR/$USER_PREFIX.power/Panel.qml"
BLUETOOTH_QML="$PLUGINS_DIR/$USER_PREFIX.bluetooth/Panel.qml"
NETWORK_QML="$PLUGINS_DIR/$USER_PREFIX.network/Panel.qml"
AUDIO_QML="$PLUGINS_DIR/$USER_PREFIX.audio/Panel.qml"
CLOCK_QML="$PLUGINS_DIR/$USER_PREFIX.clock/BarWidget.qml"
CLOCK_PANEL_QML="$PLUGINS_DIR/$USER_PREFIX.clock/Panel.qml"

if ! grep -q 'barBatteryColor' "$POWER_QML"; then
    sed -i '/^  readonly property var chargingPhrases:/i\
  // Charge state remains visible with every Omarchy theme.\
  readonly property color barBatteryColor: {\
    if (root.batteryFraction <= 0.30) return "#ff9eaf" // low: red\
    if (root.batteryFraction <= 0.70) return "#f3d38c" // medium: yellow\
    return "#a9e790" // high, charging, and full: green\
  }\
' "$POWER_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barBatteryColor
}' "$POWER_QML"
fi

if ! grep -q 'barBluetoothColor' "$BLUETOOTH_QML"; then
    sed -i '/^  property int phraseIndex:/i\
  readonly property color barBluetoothColor: {\
    if (!adapter || !adapter.enabled) return "#565f89" // off: gray\
    if (connectedDevices.length > 0) return "#a9e790" // connected: green\
    return "#f5a97f" // enabled, no device: orange\
  }\
' "$BLUETOOTH_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barBluetoothColor
}' "$BLUETOOTH_QML"
fi

if ! grep -q 'barNetworkColor' "$NETWORK_QML"; then
    sed -i '/^  \/\/ The share card is its own panel plugin/i\
  readonly property color barNetworkColor: {\
    if (kind === "wifi" || kind === "ethernet") return "#a9e790" // connected: green\
    if (Networking.wifiEnabled) return "#f5a97f" // enabled, disconnected: orange\
    return "#565f89" // disabled: gray\
  }\
' "$NETWORK_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barNetworkColor
}' "$NETWORK_QML"
fi

if ! grep -q 'barAudioColor' "$AUDIO_QML"; then
    sed -i '/^  onRawAudioSinksChanged:/i\
  readonly property color barAudioColor: {\
    if (!hasOutput || outputMuted) return "#565f89" // muted: gray\
    if (outputVolume < 0.34) return "#94e2d5" // quiet: cyan\
    if (outputVolume < 0.68) return "#a9e790" // normal: green\
    return "#f3d38c" // loud: yellow\
  }\
' "$AUDIO_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barAudioColor
}' "$AUDIO_QML"
fi

if ! grep -q 'Japanese formatter' "$CLOCK_QML"; then
    sed -i '/^  function formatted(date) {/,/^  }$/c\
  // Japanese formatter that does not depend on the graphical session locale.\
  function formatted(date) {\
    if (!vertical) {\
      var weekdays = ["日", "月", "火", "水", "木", "金", "土"]\
      var hours = ("0" + date.getHours()).slice(-2)\
      var minutes = ("0" + date.getMinutes()).slice(-2)\
      return date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate()\
        + "日（" + weekdays[date.getDay()] + "） " + hours + ":" + minutes\
    }\
    return Qt.formatDateTime(date, activeFormat.replace(/ww/g, Model.isoWeekLiteral(date.getFullYear(), date.getMonth(), date.getDate())))\
  }' "$CLOCK_QML"
fi

if ! grep -q 'japaneseMonths' "$CLOCK_PANEL_QML"; then
    sed -i 's|Model.normalizedWeekStart(setting("weekStartDay", null), Qt.locale().firstDayOfWeek)|Model.normalizedWeekStart(setting("weekStartDay", null), 0)|' "$CLOCK_PANEL_QML"
    sed -i 's|Qt.locale().dayName(Model.toggledWeekStart(weekStart), Locale.LongFormat)|Model.toggledWeekStart(weekStart) === 0 ? "日曜日" : "月曜日"|' "$CLOCK_PANEL_QML"
    sed -i '/^  readonly property var weeks:/a\
  readonly property var japaneseMonths: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]' "$CLOCK_PANEL_QML"
    sed -i '/^  function weekdayLabel(weekday) {/,/^  }$/c\
  function weekdayLabel(weekday) {\
    return ["日", "月", "火", "水", "木", "金", "土"][weekday]\
  }' "$CLOCK_PANEL_QML"
    sed -i 's|Qt.formatDate(root.today, "MMMM d")|root.japaneseMonths[root.today.getMonth()] + root.today.getDate() + "日"|' "$CLOCK_PANEL_QML"
    sed -i 's|Qt.formatDate(root.viewDate, "MMMM yyyy").toUpperCase()|root.viewYear + "年" + root.japaneseMonths[root.viewMonth]|' "$CLOCK_PANEL_QML"
fi

jq --arg clock "$USER_PREFIX.clock" '
  .bar.layout.center |= map(
    if .id == $clock then . + {
      format: "yyyy年M月d日（ddd） HH:mm",
      formatAlt: "yyyy年M月d日（dddd） HH:mm"
    } else . end
  )
' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"

omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.power"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.bluetooth"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.network"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.audio"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.clock"
omarchy restart shell

echo "✔ Omarchy Shell bar colours and Japanese clock configured."
