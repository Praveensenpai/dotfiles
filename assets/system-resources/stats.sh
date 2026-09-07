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
