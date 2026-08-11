use chrono::{Datelike, Local};
use serde::Deserialize;
use std::fs;
use std::io::Write;
use std::path::Path;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Deserialize, Debug)]
struct VnstatDate {
    year: Option<i32>,
    month: Option<u32>,
    day: Option<u32>,
}

#[derive(Deserialize, Debug)]
struct VnstatRecord {
    date: Option<VnstatDate>,
    rx: Option<u64>,
    tx: Option<u64>,
}

#[derive(Deserialize, Debug)]
struct VnstatTraffic {
    day: Option<Vec<VnstatRecord>>,
    month: Option<Vec<VnstatRecord>>,
}

#[derive(Deserialize, Debug)]
struct VnstatInterface {
    traffic: Option<VnstatTraffic>,
}

#[derive(Deserialize, Debug)]
struct VnstatOutput {
    interfaces: Option<Vec<VnstatInterface>>,
}

fn get_default_interface() -> String {
    if let Ok(content) = fs::read_to_string("/proc/net/route") {
        for line in content.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 2 && parts[1] == "00000000" {
                return parts[0].to_string();
            }
        }
    }

    if let Ok(entries) = fs::read_dir("/sys/class/net") {
        for entry in entries.flatten() {
            let name = entry.file_name().to_string_lossy().to_string();
            if name != "lo"
                && !name.starts_with("veth")
                && !name.starts_with("docker")
                && !name.starts_with("br-")
            {
                let oper_path = format!("/sys/class/net/{}/operstate", name);
                if let Ok(oper) = fs::read_to_string(&oper_path) {
                    if oper.trim() == "up" {
                        return name;
                    }
                }
            }
        }
    }

    "wlan0".to_string()
}

fn format_speed(bps: f64) -> String {
    if bps < 1000.0 {
        format!("{:>5.0} B/s ", bps)
    } else if bps < 1000.0 * 1000.0 {
        format!("{:>5.1} kB/s", bps / 1000.0)
    } else if bps < 1000.0 * 1000.0 * 1000.0 {
        format!("{:>5.1} MB/s", bps / (1000.0 * 1000.0))
    } else {
        format!("{:>5.1} GB/s", bps / (1000.0 * 1000.0 * 1000.0))
    }
}

fn format_bytes(b: u64) -> String {
    let bf = b as f64;
    if b < 1024 {
        format!("{} B", b)
    } else if b < 1024 * 1024 {
        format!("{:.2} KiB", bf / 1024.0)
    } else if b < 1024 * 1024 * 1024 {
        format!("{:.2} MiB", bf / (1024.0 * 1024.0))
    } else if b < 1024 * 1024 * 1024 * 1024 {
        format!("{:.2} GiB", bf / (1024.0 * 1024.0 * 1024.0))
    } else {
        format!("{:.2} TiB", bf / (1024.0 * 1024.0 * 1024.0 * 1024.0))
    }
}

fn main() {
    let iface = get_default_interface();

    // Connection status
    let oper_path = format!("/sys/class/net/{}/operstate", iface);
    let operstate = fs::read_to_string(&oper_path)
        .unwrap_or_default()
        .trim()
        .to_string();
    let is_connected = operstate == "up";

    // IPv4 address
    let mut ip_addr = "Disconnected".to_string();
    if let Ok(output) = Command::new("ip")
        .args(&["-4", "addr", "show", &iface])
        .output()
    {
        let out_str = String::from_utf8_lossy(&output.stdout);
        for line in out_str.lines() {
            if let Some(pos) = line.find("inet ") {
                let rest = &line[pos + 5..].trim_start();
                if let Some(end) = rest.find('/') {
                    ip_addr = rest[..end].to_string();
                    break;
                } else if let Some(end) = rest.find(' ') {
                    ip_addr = rest[..end].to_string();
                    break;
                }
            }
        }
    }

    // Wi-Fi details
    let is_wifi = Path::new(&format!("/sys/class/net/{}/wireless", iface)).exists()
        || Path::new(&format!("/sys/class/net/{}/phy80211", iface)).exists()
        || iface.starts_with('w');

    let mut ssid = String::new();
    let mut freq = String::new();
    let mut signal_dbm: i32 = -100;

    if is_wifi {
        if let Ok(output) = Command::new("iw").args(&["dev", &iface, "link"]).output() {
            let out_str = String::from_utf8_lossy(&output.stdout);
            for line in out_str.lines() {
                let l = line.trim();
                if l.starts_with("SSID:") {
                    ssid = l["SSID:".len()..].trim().to_string();
                } else if l.starts_with("freq:") {
                    if let Ok(f_val) = l["freq:".len()..].trim().parse::<f64>() {
                        freq = format!("{:.1} GHz", f_val / 1000.0);
                    }
                } else if l.starts_with("signal:") {
                    if let Some(idx) = l.find("dBm") {
                        let parts: Vec<&str> = l[..idx].split_whitespace().collect();
                        if let Some(last) = parts.last() {
                            if let Ok(sig) = last.parse::<i32>() {
                                signal_dbm = sig;
                            }
                        }
                    }
                }
            }
        }
    }

    // Read rx/tx bytes
    let rx_bytes: u64 = fs::read_to_string(format!("/sys/class/net/{}/statistics/rx_bytes", iface))
        .unwrap_or_default()
        .trim()
        .parse()
        .unwrap_or(0);
    let tx_bytes: u64 = fs::read_to_string(format!("/sys/class/net/{}/statistics/tx_bytes", iface))
        .unwrap_or_default()
        .trim()
        .parse()
        .unwrap_or(0);

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64();

    let state_file = "/tmp/waybar_net_state.txt";
    let mut rx_speed: f64 = 0.0;
    let mut tx_speed: f64 = 0.0;

    if let Ok(state_str) = fs::read_to_string(state_file) {
        let parts: Vec<&str> = state_str.trim().split(',').collect();
        if parts.len() >= 4 {
            let prev_time: f64 = parts[0].parse().unwrap_or(now);
            let prev_rx: u64 = parts[1].parse().unwrap_or(rx_bytes);
            let prev_tx: u64 = parts[2].parse().unwrap_or(tx_bytes);
            let prev_iface = parts[3];

            let dt = (now - prev_time).max(0.1);
            if prev_iface == iface && dt < 10.0 {
                if rx_bytes >= prev_rx {
                    rx_speed = (rx_bytes - prev_rx) as f64 / dt;
                }
                if tx_bytes >= prev_tx {
                    tx_speed = (tx_bytes - prev_tx) as f64 / dt;
                }
            }
        }
    }

    // Write current state
    if let Ok(mut f) = fs::File::create(state_file) {
        let _ = writeln!(f, "{:.3},{},{},{}", now, rx_bytes, tx_bytes, iface);
    }

    // Icon selection
    let (icon, css_class) = if !is_connected {
        ("󰤮", "disconnected")
    } else if !is_wifi {
        ("󰀂", "connected")
    } else if signal_dbm >= -55 {
        ("󰤨", "connected")
    } else if signal_dbm >= -65 {
        ("󰤥", "connected")
    } else if signal_dbm >= -75 {
        ("󰤢", "connected")
    } else if signal_dbm >= -85 {
        ("󰤟", "connected")
    } else {
        ("󰤯", "connected")
    };

    let down_str = format_speed(rx_speed);
    let up_str = format_speed(tx_speed);

    let text = format!(
        "{}   <span foreground='#74c7ec'>󰇚</span> {}  <span foreground='#b4befe'>󰕒</span> {}",
        icon, down_str, up_str
    );

    // vnstat parsing
    let mut today_rx: u64 = 0;
    let mut today_tx: u64 = 0;
    let mut month_rx: u64 = 0;
    let mut month_tx: u64 = 0;
    let mut vnstat_available = false;

    if let Ok(output) = Command::new("vnstat")
        .args(&["-i", &iface, "--json"])
        .output()
    {
        if output.status.success() {
            if let Ok(vn_data) = serde_json::from_slice::<VnstatOutput>(&output.stdout) {
                if let Some(ifaces) = vn_data.interfaces {
                    if let Some(first_iface) = ifaces.get(0) {
                        if let Some(traffic) = &first_iface.traffic {
                            let now_local = Local::now();
                            let cur_year = now_local.year();
                            let cur_month = now_local.month();
                            let cur_day = now_local.day();

                            // Day
                            if let Some(days) = &traffic.day {
                                for d in days {
                                    if let Some(dt) = &d.date {
                                        if dt.year == Some(cur_year)
                                            && dt.month == Some(cur_month)
                                            && dt.day == Some(cur_day)
                                        {
                                            today_rx = d.rx.unwrap_or(0);
                                            today_tx = d.tx.unwrap_or(0);
                                            vnstat_available = true;
                                            break;
                                        }
                                    }
                                }
                                if !vnstat_available {
                                    if let Some(latest) = days.last() {
                                        today_rx = latest.rx.unwrap_or(0);
                                        today_tx = latest.tx.unwrap_or(0);
                                        vnstat_available = true;
                                    }
                                }
                            }

                            // Month
                            if let Some(months) = &traffic.month {
                                for m in months {
                                    if let Some(dt) = &m.date {
                                        if dt.year == Some(cur_year) && dt.month == Some(cur_month)
                                        {
                                            month_rx = m.rx.unwrap_or(0);
                                            month_tx = m.tx.unwrap_or(0);
                                            break;
                                        }
                                    }
                                }
                                if month_rx == 0 && month_tx == 0 {
                                    if let Some(latest) = months.last() {
                                        month_rx = latest.rx.unwrap_or(0);
                                        month_tx = latest.tx.unwrap_or(0);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Build tooltip
    let display_name = if is_wifi && !ssid.is_empty() {
        &ssid
    } else {
        &iface
    };
    let freq_str = if !freq.is_empty() {
        format!(" ({})", freq)
    } else {
        String::new()
    };

    let header = if !is_connected {
        "<b><span color='#f5a97f'>󰤮  Disconnected</span></b>\n<span color='#7f849c'>No active connection</span>".to_string()
    } else {
        format!(
            "<b><span color='#89b4fa'>{}  {}</span></b>  <span color='#a6e3a1'>● Connected</span>\n<span color='#7f849c'>󰩟 {}{} ({})</span>",
            icon, display_name, ip_addr, freq_str, iface
        )
    };

    let vnstat_section = if vnstat_available {
        let today_tot = today_rx + today_tx;
        let month_tot = month_rx + month_tx;

        format!(
            "<span color='#cdd6f4'><b>󰚄  Data Usage (vnstat)</b></span>\n         <span color='#74c7ec'>󰇚 Down</span>       <span color='#b4befe'>󰕒 Up</span>         <span color='#f9e2af'>󰓅 Total</span>\n<b>Today </b> {:>9}    {:>9}    <b><span color='#a6e3a1'>{:>9}</span></b>\n<b>Month </b> {:>9}    {:>9}    <b><span color='#a6e3a1'>{:>9}</span></b>",
            format_bytes(today_rx),
            format_bytes(today_tx),
            format_bytes(today_tot),
            format_bytes(month_rx),
            format_bytes(month_tx),
            format_bytes(month_tot)
        )
    } else {
        "<span color='#7f849c'>󰚄 Data Usage: vnstat unavailable</span>".to_string()
    };

    let tooltip = format!("{}\n\n{}", header, vnstat_section);

    let out_obj = serde_json::json!({
        "text": text,
        "tooltip": tooltip,
        "class": css_class
    });

    println!("{}", serde_json::to_string(&out_obj).unwrap());
}
