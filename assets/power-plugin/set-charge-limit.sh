#!/bin/bash
set -euo pipefail

cfg="/etc/battery-charge-limit.conf"

if [[ "${1:-}" == "--restore" ]] || [[ -z "${1:-}" ]]; then
  if [[ -f "$cfg" ]]; then
    n=$(tr -d ' \n\r' < "$cfg")
  else
    n="80"
  fi
else
  n="$1"
fi

[[ "$n" =~ ^[0-9]+$ ]] || { echo "bad value: $n" >&2; exit 2; }
(( n >= 20 && n <= 100 )) || { echo "value out of range 20-100: $n" >&2; exit 2; }

# Write to all available battery threshold sysfs nodes
shopt -s nullglob
paths=(/sys/class/power_supply/BAT*/charge_control_end_threshold)
if [[ ${#paths[@]} -gt 0 ]]; then
  for path in "${paths[@]}"; do
    printf '%s\n' "$n" > "$path"
  done
fi

printf '%s\n' "$n" > "$cfg"
chmod 0644 "$cfg"
