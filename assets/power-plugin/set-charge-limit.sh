#!/bin/bash
set -euo pipefail
n="${1:?value required}"
path="/sys/class/power_supply/BAT0/charge_control_end_threshold"
cfg="/etc/battery-charge-limit.conf"
[[ "$n" =~ ^[0-9]+$ ]] || { echo "bad value: $n" >&2; exit 2; }
(( n >= 20 && n <= 100 )) || { echo "value out of range 20-100: $n" >&2; exit 2; }
printf '%s\n' "$n" > "$path"
printf '%s\n' "$n" > "$cfg"
chmod 0644 "$cfg"
