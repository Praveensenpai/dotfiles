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

# Ensure unused plugins (AI agent navbar icon & weather) are disabled
omarchy plugin disable omarchy.agents >/dev/null 2>&1 || true
omarchy plugin disable omarchy.weather >/dev/null 2>&1 || true


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
    return root.bar ? root.bar.foreground : Color.foreground // high, charging, and full: default\
  }\
' "$POWER_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barBatteryColor
}' "$POWER_QML"
fi

if grep -q 'barBluetoothColor' "$BLUETOOTH_QML"; then
    sed -i '/readonly property color barBluetoothColor:/,/^  }/c\  readonly property color barBluetoothColor: {\n    if (!adapter || !adapter.enabled) return root.bar ? root.bar.foreground : "#ffffff" // off: default\n    if (connectedDevices.length > 0) return "#a9e790" // connected: green\n    return "#f5a97f" // enabled, no device: orange\n  }' "$BLUETOOTH_QML"
else
    sed -i '/^  property int phraseIndex:/i\
  readonly property color barBluetoothColor: {\
    if (!adapter || !adapter.enabled) return root.bar ? root.bar.foreground : "#ffffff" // off: default\
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
    if (kind === "wifi" || kind === "ethernet") return root.bar ? root.bar.foreground : Color.foreground // connected: default\
    if (Networking.wifiEnabled) return "#f5a97f" // enabled, disconnected: orange\
    return "#565f89" // disabled: gray\
  }\
' "$NETWORK_QML"
    sed -i '/^  BarIconButton {/,/^  }$/ { /^    bar: root.bar$/a\
    foreground: root.barNetworkColor
}' "$NETWORK_QML"
fi

# Ensure audio plugin has no custom colors (use default bar color)
if grep -q 'barAudioColor' "$AUDIO_QML"; then
    sed -i '/readonly property color barAudioColor:/,/^  }/d' "$AUDIO_QML"
    sed -i '/foreground: root.barAudioColor/d' "$AUDIO_QML"
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

# Setup System Resources (CPU & RAM) Plugin
SYS_RES_DIR="$PLUGINS_DIR/$USER_PREFIX.system-resources"
mkdir -p "$SYS_RES_DIR"

cat << EOF > "$SYS_RES_DIR/manifest.json"
{
  "schemaVersion": 1,
  "id": "$USER_PREFIX.system-resources",
  "name": "System Resources",
  "version": "1.0.0",
  "author": "$USER_PREFIX",
  "description": "CPU and RAM system resource usage monitor with detail popover",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "Panel.qml"
  },
  "barWidget": {
    "displayName": "System Resources",
    "description": "CPU and RAM system resource usage monitor with detail popover",
    "category": "System",
    "allowMultiple": false
  }
}
EOF

cat << 'EOF' > "$SYS_RES_DIR/stats.sh"
#!/bin/bash

# Reads live CPU load, Memory, Swap, and Temperature stats for Omarchy Shell

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
total=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_sum=$((idle + iowait))

prev_file="/tmp/omarchy_sys_stat.prev"
if [[ -r $prev_file ]]; then
  read -r prev_total prev_idle < "$prev_file"
  diff_total=$((total - prev_total))
  diff_idle=$((idle_sum - prev_idle))
  if (( diff_total > 0 )); then
    cpu_percent=$(( 100 * (diff_total - diff_idle) / diff_total ))
  else
    cpu_percent=0
  fi
else
  cpu_percent=0
fi
echo "$total $idle_sum" > "$prev_file"

printf "cpu_percent\t%d\n" "$cpu_percent"

awk '
  /^MemTotal:/ { total = $2 }
  /^MemAvailable:/ { avail = $2 }
  /^SwapTotal:/ { stotal = $2 }
  /^SwapFree:/ { sfree = $2 }
  END {
    used = total - avail
    sused = stotal - sfree
    printf "mem_used\t%.1f\nmem_total\t%.1f\nmem_percent\t%.0f\nswap_used\t%.1f\nswap_total\t%.1f\n",
      used/1024/1024, total/1024/1024, (used > 0 && total > 0 ? (used/total)*100 : 0), sused/1024/1024, stotal/1024/1024
  }
' /proc/meminfo

awk '{ printf "load_1\t%s\nload_5\t%s\nload_15\t%s\n", $1, $2, $3 }' /proc/loadavg
nproc | awk '{ printf "cpu_cores\t%s\n", $1 }'

if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
  temp=$(< /sys/class/thermal/thermal_zone0/temp)
  printf "cpu_temp\t%d\n" "$((temp / 1000))"
fi
EOF
chmod +x "$SYS_RES_DIR/stats.sh"

cat << EOF > "$SYS_RES_DIR/Panel.qml"
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "$USER_PREFIX.system-resources"
  ipcTarget: "$USER_PREFIX.system-resources"

  property var statsInfo: ({})

  readonly property int cpuPercent: parseInt(statsInfo["cpu_percent"] || "0")
  readonly property real memUsed: parseFloat(statsInfo["mem_used"] || "0")
  readonly property real memTotal: parseFloat(statsInfo["mem_total"] || "0")
  readonly property int memPercent: parseInt(statsInfo["mem_percent"] || "0")
  readonly property real swapUsed: parseFloat(statsInfo["swap_used"] || "0")
  readonly property real swapTotal: parseFloat(statsInfo["swap_total"] || "0")
  readonly property string load1: statsInfo["load_1"] || "0.00"
  readonly property string load5: statsInfo["load_5"] || "0.00"
  readonly property string load15: statsInfo["load_15"] || "0.00"
  readonly property string cpuCores: statsInfo["cpu_cores"] || "4"
  readonly property string cpuTemp: statsInfo["cpu_temp"] || "--"

  readonly property color barCpuColor: {
    if (cpuPercent > 85) return "#ff9eaf" // high: red
    if (cpuPercent >= 50) return "#f3d38c" // medium: yellow
    return root.bar ? root.bar.foreground : Color.foreground // normal
  }

  function refresh() {
    if (!statsProc.running) statsProc.running = true
  }

  function parseKeyValue(raw) {
    var next = {}
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var idx = lines[i].indexOf("\t")
      if (idx <= 0) continue
      next[lines[i].substring(0, idx)] = lines[i].substring(idx + 1).trim()
    }
    return next
  }

  function updateKeyValue(raw) {
    var next = parseKeyValue(raw)
    if (Object.keys(next).length > 0) statsInfo = next
  }

  function launchTaskContainer() {
    actionProc.command = ["omarchy-launch-terminal", "btop"]
    actionProc.running = true
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string statsScriptPath: Qt.resolvedUrl("stats.sh").toString().replace("file://", "")

  Process {
    id: statsProc
    command: [root.statsScriptPath]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateKeyValue(text) }
  }

  Process {
    id: actionProc
  }

  Timer {
    interval: 2000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    interval: 3000
    running: !root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    foreground: root.barCpuColor
    text: "󰍛"
    slotSize: Style.bar.iconSlot
    tooltipText: "System Resources"
    onPressed: function(b) {
      root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero Section ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroRight.implicitHeight)

          Text {
            id: heroIcon
            text: "󰍛"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: heroRight.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "System"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              text: "CPU & MEMORY LOAD"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }

          Column {
            id: heroRight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: root.cpuPercent + "% CPU"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              horizontalAlignment: Text.AlignRight
            }

            Text {
              text: root.memPercent + "% RAM"
              color: Qt.darker(root.bar.foreground, 1.3)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              horizontalAlignment: Text.AlignRight
            }
          }
        }

        // ---------- CPU Load Section ----------
        Column {
          width: parent.width
          spacing: Style.space(6)

          Item {
            width: parent.width
            implicitHeight: cpuLabelText.implicitHeight

            Text {
              id: cpuLabelText
              anchors.left: parent.left
              text: "CPU LOAD"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
            }

            Text {
              anchors.right: parent.right
              text: root.cpuPercent + "%"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          // CPU Progress Track
          Rectangle {
            width: parent.width
            height: Style.space(6)
            radius: Style.space(3)
            color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)

            Rectangle {
              width: parent.width * Math.min(1.0, Math.max(0.0, root.cpuPercent / 100.0))
              height: parent.height
              radius: parent.radius
              color: root.cpuPercent > 85 ? "#ff9eaf" : (root.cpuPercent > 60 ? "#f3d38c" : "#89b4fa")
            }
          }

          Text {
            text: root.cpuCores + " Cores  ·  Load: " + root.load1 + " " + root.load5 + "  ·  Temp: " + root.cpuTemp + "°C"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------- RAM Memory Section ----------
        Column {
          width: parent.width
          spacing: Style.space(6)

          Item {
            width: parent.width
            implicitHeight: ramLabelText.implicitHeight

            Text {
              id: ramLabelText
              anchors.left: parent.left
              text: "MEMORY (RAM)"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
            }

            Text {
              anchors.right: parent.right
              text: root.memUsed.toFixed(1) + " / " + root.memTotal.toFixed(1) + " GB"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          // RAM Progress Track
          Rectangle {
            width: parent.width
            height: Style.space(6)
            radius: Style.space(3)
            color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)

            Rectangle {
              width: parent.width * Math.min(1.0, Math.max(0.0, root.memPercent / 100.0))
              height: parent.height
              radius: parent.radius
              color: root.memPercent > 85 ? "#ff9eaf" : (root.memPercent > 70 ? "#f3d38c" : "#a6e3a1")
            }
          }

          Text {
            text: "Swap: " + root.swapUsed.toFixed(1) + " / " + root.swapTotal.toFixed(1) + " GB"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------- Launch Task Manager Button ----------
        Rectangle {
          width: parent.width
          height: Style.space(36)
          radius: Style.space(6)
          color: btnArea.containsMouse ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15) : Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)

          Row {
            anchors.centerIn: parent
            spacing: Style.space(8)

            Text {
              text: "󰄍"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
            }

            Text {
              text: "Open Task Manager (btop)"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
            }
          }

          MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.launchTaskContainer()
              root.close()
            }
          }
        }
      }
    }
  }
}
EOF

omarchy plugin enable "$USER_PREFIX.system-resources" >/dev/null 2>&1 || true

# Setup Input Method (Japanese & English) Plugin
IM_DIR="$PLUGINS_DIR/$USER_PREFIX.input-method"
mkdir -p "$IM_DIR"

cat << EOF > "$IM_DIR/manifest.json"
{
  "schemaVersion": 1,
  "id": "$USER_PREFIX.input-method",
  "name": "Input Method",
  "version": "1.0.0",
  "author": "$USER_PREFIX",
  "description": "Japanese and English Input Method Manager (Fcitx5 / Mozc)",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "Panel.qml"
  },
  "barWidget": {
    "displayName": "Input Method",
    "description": "Japanese and English Input Method Manager (Fcitx5 / Mozc)",
    "category": "Input",
    "allowMultiple": false
  }
}
EOF

cat << 'EOF' > "$IM_DIR/status.sh"
#!/bin/bash
im=$(fcitx5-remote -n 2>/dev/null || echo "keyboard-us")
state=$(fcitx5-remote 2>/dev/null || echo "1")
printf "im\t%s\nstate\t%s\n" "$im" "$state"
EOF
chmod +x "$IM_DIR/status.sh"

cat << 'EOF' > "$IM_DIR/action.sh"
#!/bin/bash
case "$1" in
  toggle)
    fcitx5-remote -t
    ;;
  mozc)
    fcitx5-remote -s mozc >/dev/null 2>&1 || true
    fcitx5-remote -o >/dev/null 2>&1 || true
    ;;
  us)
    fcitx5-remote -c >/dev/null 2>&1 || true
    ;;
  dict)
    /usr/lib/mozc/mozc_tool --mode=dictionary_tool >/dev/null 2>&1 &
    ;;
  word)
    /usr/lib/mozc/mozc_tool --mode=word_register_dialog >/dev/null 2>&1 &
    ;;
  config)
    fcitx5-configtool >/dev/null 2>&1 &
    ;;
  *)
    echo "Usage: $0 {toggle|mozc|us|dict|word|config}"
    exit 1
    ;;
esac
EOF
chmod +x "$IM_DIR/action.sh"

cat << 'EOF' > "$IM_DIR/Panel.qml"
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "paisen.input-method"
  ipcTarget: "paisen.input-method"

  property var statusInfo: ({})

  readonly property string currentIm: statusInfo["im"] || "keyboard-us"
  readonly property int imState: parseInt(statusInfo["state"] || "1")
  readonly property bool isJapanese: currentIm === "mozc" || imState === 2
  readonly property string barIconText: isJapanese ? "あ" : "󰌌"
  readonly property string barTooltip: isJapanese ? "Input Method: Japanese (Mozc)" : "Input Method: English (US)"

  readonly property string statusScriptPath: Qt.resolvedUrl("status.sh").toString().replace("file://", "")
  readonly property string actionScriptPath: Qt.resolvedUrl("action.sh").toString().replace("file://", "")

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function triggerAction(actionName) {
    actionProc.command = [root.actionScriptPath, actionName]
    actionProc.running = true
    refreshTimer.restart()
  }

  function parseKeyValue(raw) {
    var next = {}
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var idx = lines[i].indexOf("\t")
      if (idx <= 0) continue
      next[lines[i].substring(0, idx)] = lines[i].substring(idx + 1).trim()
    }
    return next
  }

  function updateKeyValue(raw) {
    var next = parseKeyValue(raw)
    if (Object.keys(next).length > 0) statusInfo = next
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [root.statusScriptPath]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateKeyValue(text)
    }
  }

  Process {
    id: actionProc
    onRunningChanged: {
      if (!running) {
        root.refresh()
      }
    }
  }

  Timer {
    id: refreshTimer
    interval: 150
    onTriggered: root.refresh()
  }

  Timer {
    interval: 1500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.barIconText
    slotSize: Style.bar.iconSlot
    tooltipText: root.barTooltip
    onPressed: function(b) {
      if (b === Qt.RightButton || b === Qt.MiddleButton) {
        root.triggerAction("toggle")
      } else {
        root.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(370))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        // ---------- Hero Section ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)

          Text {
            id: heroIcon
            text: root.isJapanese ? "あ" : "󰌌"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          ToggleSwitch {
            id: powerSwitch
            checked: root.isJapanese
            foreground: root.bar.foreground
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onToggled: root.triggerAction("toggle")
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: powerSwitch.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "Input Method"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              text: root.isJapanese ? "MOZC (JAPANESE)" : "US KEYBOARD (ENGLISH)"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }
        }

        // ---------- Section: Input Methods ----------
        PanelSeparator {
          foreground: root.bar.foreground
        }

        PanelSectionHeader {
          text: "INPUT METHODS"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        // Japanese Mozc Selection Card
        Rectangle {
          width: parent.width
          height: Style.space(48)
          radius: Style.space(6)
          color: mozcArea.containsMouse
            ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
            : (root.isJapanese
                ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)
                : "transparent")

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(12)
            anchors.right: mozcBadge.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(12)

            Text {
              text: "あ"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(1)

              Text {
                text: "Mozc (Japanese / 日本語)"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                font.bold: root.isJapanese
              }

              Text {
                text: "Romaji · Hiragana / Katakana / Kanji"
                color: Qt.darker(root.bar.foreground, 1.3)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }
            }
          }

          Text {
            id: mozcBadge
            visible: root.isJapanese
            anchors.right: parent.right
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: "✔"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
          }

          MouseArea {
            id: mozcArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.triggerAction("mozc")
            }
          }
        }

        // English US Selection Card
        Rectangle {
          width: parent.width
          height: Style.space(48)
          radius: Style.space(6)
          color: usArea.containsMouse
            ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
            : (!root.isJapanese
                ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)
                : "transparent")

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(12)
            anchors.right: usBadge.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(12)

            Text {
              text: "EN"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(1)

              Text {
                text: "English (US)"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                font.bold: !root.isJapanese
              }

              Text {
                text: "Direct Input · Standard QWERTY"
                color: Qt.darker(root.bar.foreground, 1.3)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }
            }
          }

          Text {
            id: usBadge
            visible: !root.isJapanese
            anchors.right: parent.right
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: "✔"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
          }

          MouseArea {
            id: usArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.triggerAction("us")
            }
          }
        }

        // ---------- Section: Tools & Utilities ----------
        PanelSeparator {
          foreground: root.bar.foreground
        }

        PanelSectionHeader {
          text: "TOOLS & SETTINGS"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          // Mozc Dictionary Tool Button
          Rectangle {
            width: (parent.width - Style.space(16)) / 3
            height: Style.space(34)
            radius: Style.space(6)
            color: dictBtnArea.containsMouse
              ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
              : Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)

            Row {
              anchors.centerIn: parent
              spacing: Style.space(6)

              Text {
                text: "󰮯"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }

              Text {
                text: "Dictionary"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            MouseArea {
              id: dictBtnArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.triggerAction("dict")
                root.close()
              }
            }
          }

          // Mozc Word Register Button
          Rectangle {
            width: (parent.width - Style.space(16)) / 3
            height: Style.space(34)
            radius: Style.space(6)
            color: wordBtnArea.containsMouse
              ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
              : Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)

            Row {
              anchors.centerIn: parent
              spacing: Style.space(6)

              Text {
                text: "󰏫"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }

              Text {
                text: "Add Word"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            MouseArea {
              id: wordBtnArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.triggerAction("word")
                root.close()
              }
            }
          }

          // Fcitx5 Settings Button
          Rectangle {
            width: (parent.width - Style.space(16)) / 3
            height: Style.space(34)
            radius: Style.space(6)
            color: cfgBtnArea.containsMouse
              ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
              : Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)

            Row {
              anchors.centerIn: parent
              spacing: Style.space(6)

              Text {
                text: "󰒓"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }

              Text {
                text: "Settings"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }
            }

            MouseArea {
              id: cfgBtnArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.triggerAction("config")
                root.close()
              }
            }
          }
        }

        // ---------- Bottom Shortcut Hint ----------
        Item {
          width: parent.width
          height: Style.space(20)

          Text {
            anchors.centerIn: parent
            text: "Toggle shortcut: Ctrl + Space"
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }
}
EOF

omarchy plugin enable "$USER_PREFIX.input-method" >/dev/null 2>&1 || true

jq --arg sysres "$USER_PREFIX.system-resources" --arg im "$USER_PREFIX.input-method" --arg clock "$USER_PREFIX.clock" '
  .bar.layout.center |= (
    map(
      if .id == $clock then . + {
        format: "yyyy年M月d日（ddd） HH:mm",
        formatAlt: "yyyy年M月d日（dddd） HH:mm"
      } else . end
    )
    | map(select(.id != "omarchy.keyboard-layout" and .id != $im))
  )
  | if (.bar.layout.right | map(.id) | index($im)) == null then
      .bar.layout.right |= (
        if (map(.id) | index("omarchy.tray")) != null then
          map(if .id == "omarchy.tray" then ., { "id": $im } else . end)
        else
          [{ "id": $im }] + .
        end
      )
    else
      .
    end
  | if (.bar.layout.right | map(.id) | index($sysres)) == null then
      .bar.layout.right |= map(
        if .id == "omarchy.monitor" then
          ., { "id": $sysres }
        else
          .
        end
      )
    else
      .
    end
' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"

omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.power"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.bluetooth"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.network"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.audio"
omarchy plugin validate "$PLUGINS_DIR/$USER_PREFIX.clock"
omarchy plugin validate "$SYS_RES_DIR"
omarchy plugin validate "$IM_DIR"
omarchy restart shell

echo "✔ Omarchy Shell bar colours, Japanese clock, System Resources, and Input Method widgets configured."

