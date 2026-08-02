#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_SCRIPTS="$WAYBAR_DIR/scripts"
WAYBAR_CONFIG="$WAYBAR_DIR/config.jsonc"

mkdir -p "$WAYBAR_SCRIPTS"

echo "Setting Network (Wi-Fi) bandwidth speed display & vnstat tooltips in Waybar..."

cat << 'EOF' > "$WAYBAR_SCRIPTS/network-status.py"
#!/usr/bin/env python3
import sys
import os
import json
import time
import re
import subprocess
import datetime

def get_default_interface():
    try:
        with open('/proc/net/route') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2 and parts[1] == '00000000':
                    return parts[0]
    except Exception:
        pass
    for iface in os.listdir('/sys/class/net'):
        if iface != 'lo' and not iface.startswith('veth') and not iface.startswith('docker') and not iface.startswith('br-'):
            try:
                with open(f'/sys/class/net/{iface}/operstate') as f:
                    if f.read().strip() == 'up':
                        return iface
            except Exception:
                pass
    return 'wlan0'

def format_speed(bps):
    if bps < 1000:
        return f"{bps:.0f} B/s"
    elif bps < 1000 * 1000:
        return f"{bps / 1000:.1f} kB/s"
    elif bps < 1000 * 1000 * 1000:
        return f"{bps / (1000 * 1000):.1f} MB/s"
    else:
        return f"{bps / (1000 * 1000 * 1000):.1f} GB/s"

def format_bytes(b):
    if b < 1024:
        return f"{b} B"
    elif b < 1024 * 1024:
        return f"{b / 1024:.2f} KiB"
    elif b < 1024 * 1024 * 1024:
        return f"{b / (1024 * 1024):.2f} MiB"
    elif b < 1024 * 1024 * 1024 * 1024:
        return f"{b / (1024 * 1024 * 1024):.2f} GiB"
    else:
        return f"{b / (1024 * 1024 * 1024 * 1024):.2f} TiB"

def main():
    iface = get_default_interface()

    # Check connection status
    operstate = 'down'
    try:
        with open(f'/sys/class/net/{iface}/operstate') as f:
            operstate = f.read().strip()
    except Exception:
        pass
    
    is_connected = (operstate == 'up')

    # IP address
    ip_addr = 'Disconnected'
    try:
        out = subprocess.check_output(['ip', '-4', 'addr', 'show', iface], text=True)
        m = re.search(r'inet\s+(\d+\.\d+\.\d+\.\d+)', out)
        if m:
            ip_addr = m.group(1)
    except Exception:
        pass

    # WiFi details
    ssid = ''
    freq = ''
    signal_dbm = -100
    is_wifi = os.path.exists(f'/sys/class/net/{iface}/wireless') or os.path.exists(f'/sys/class/net/{iface}/phy80211') or iface.startswith('w')
    
    if is_wifi:
        try:
            out = subprocess.check_output(['iw', 'dev', iface, 'link'], text=True)
            for line in out.splitlines():
                line = line.strip()
                if line.startswith('SSID:'):
                    ssid = line.split('SSID:', 1)[1].strip()
                elif line.startswith('freq:'):
                    f_val = float(line.split('freq:', 1)[1].strip()) / 1000.0
                    freq = f"{f_val:.1f} GHz"
                elif line.startswith('signal:'):
                    m = re.search(r'(-\d+)', line)
                    if m:
                        signal_dbm = int(m.group(1))
        except Exception:
            pass

    # Bandwidth speed calculation
    rx_bytes, tx_bytes = 0, 0
    try:
        with open(f'/sys/class/net/{iface}/statistics/rx_bytes') as f:
            rx_bytes = int(f.read().strip())
        with open(f'/sys/class/net/{iface}/statistics/tx_bytes') as f:
            tx_bytes = int(f.read().strip())
    except Exception:
        pass

    state_file = '/tmp/waybar_net_state.json'
    now = time.time()
    rx_speed, tx_speed = 0.0, 0.0
    try:
        if os.path.exists(state_file):
            with open(state_file) as f:
                state = json.load(f)
            dt = max(0.1, now - state.get('time', now))
            if state.get('iface') == iface and dt < 10:
                rx_speed = max(0, rx_bytes - state.get('rx', rx_bytes)) / dt
                tx_speed = max(0, tx_bytes - state.get('tx', tx_bytes)) / dt
    except Exception:
        pass

    try:
        with open(state_file, 'w') as f:
            json.dump({'time': now, 'rx': rx_bytes, 'tx': tx_bytes, 'iface': iface}, f)
    except Exception:
        pass

    # Icon selection
    if not is_connected:
        icon = '󰤮'
        css_class = 'disconnected'
    elif not is_wifi:
        icon = '󰀂'
        css_class = 'connected'
    else:
        css_class = 'connected'
        if signal_dbm >= -55:
            icon = '󰤨'
        elif signal_dbm >= -65:
            icon = '󰤥'
        elif signal_dbm >= -75:
            icon = '󰤢'
        elif signal_dbm >= -85:
            icon = '󰤟'
        else:
            icon = '󰤯'

    down_str = format_speed(rx_speed)
    up_str = format_speed(tx_speed)

    text = f"{icon}   <span foreground='#74c7ec'>󰇚</span> {down_str}  <span foreground='#b4befe'>󰕒</span> {up_str}"

    # vnstat data
    today_rx, today_tx, today_tot = 0, 0, 0
    month_rx, month_tx, month_tot = 0, 0, 0
    vnstat_available = False

    try:
        vn_raw = subprocess.check_output(['vnstat', '-i', iface, '--json'], text=True, stderr=subprocess.DEVNULL)
        vn_data = json.loads(vn_raw)
        if vn_data.get('interfaces'):
            traffic = vn_data['interfaces'][0].get('traffic', {})
            now_dt = datetime.datetime.now()
            
            for d in traffic.get('day', []):
                dt = d.get('date', {})
                if dt.get('year') == now_dt.year and dt.get('month') == now_dt.month and dt.get('day') == now_dt.day:
                    today_rx = d.get('rx', 0)
                    today_tx = d.get('tx', 0)
                    today_tot = today_rx + today_tx
                    vnstat_available = True
                    break
            else:
                if traffic.get('day'):
                    latest = traffic['day'][-1]
                    today_rx = latest.get('rx', 0)
                    today_tx = latest.get('tx', 0)
                    today_tot = today_rx + today_tx
                    vnstat_available = True

            for m in traffic.get('month', []):
                dt = m.get('date', {})
                if dt.get('year') == now_dt.year and dt.get('month') == now_dt.month:
                    month_rx = m.get('rx', 0)
                    month_tx = m.get('tx', 0)
                    month_tot = month_rx + month_tx
                    break
            else:
                if traffic.get('month'):
                    latest = traffic['month'][-1]
                    month_rx = latest.get('rx', 0)
                    month_tx = latest.get('tx', 0)
                    month_tot = month_rx + month_tx
    except Exception:
        pass

    # Build tooltip
    display_name = ssid if (is_wifi and ssid) else iface
    freq_str = f" ({freq})" if freq else ""

    if not is_connected:
        header = "<b><span color='#f5a97f'>󰤮  Disconnected</span></b>\n<span color='#7f849c'>No active connection</span>"
    else:
        header = f"<b><span color='#89b4fa'>{icon}  {display_name}</span></b>  <span color='#a6e3a1'>● Connected</span>\n<span color='#7f849c'>󰩟 {ip_addr}{freq_str} ({iface})</span>"

    if vnstat_available:
        today_rx_s = format_bytes(today_rx)
        today_tx_s = format_bytes(today_tx)
        today_tot_s = format_bytes(today_tot)
        
        month_rx_s = format_bytes(month_rx)
        month_tx_s = format_bytes(month_tx)
        month_tot_s = format_bytes(month_tot)

        vnstat_section = f"<span color='#cdd6f4'><b>󰚄  Data Usage (vnstat)</b></span>\n         <span color='#74c7ec'>󰇚 Down</span>       <span color='#b4befe'>󰕒 Up</span>         <span color='#f9e2af'>󰓅 Total</span>\n<b>Today </b> {today_rx_s:>9}    {today_tx_s:>9}    <b><span color='#a6e3a1'>{today_tot_s:>9}</span></b>\n<b>Month </b> {month_rx_s:>9}    {month_tx_s:>9}    <b><span color='#a6e3a1'>{month_tot_s:>9}</span></b>"
    else:
        vnstat_section = "<span color='#7f849c'>󰚄 Data Usage: vnstat unavailable</span>"

    tooltip = f"{header}\n\n{vnstat_section}"

    out_data = {
        "text": text,
        "tooltip": tooltip,
        "class": css_class
    }

    print(json.dumps(out_data))

if __name__ == '__main__':
    main()
EOF

chmod +x "$WAYBAR_SCRIPTS/network-status.py"

if [ -f "$WAYBAR_CONFIG" ]; then
    sed -i 's/"network"/"custom\/network"/' "$WAYBAR_CONFIG"
    echo "✔ Network bandwidth speed & vnstat tooltips configured."
fi
