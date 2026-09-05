use anyhow::Result;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::runner::RunnerEvent;

/// Executes a tool task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "install_antigravity_cli" => cmd::run_curl_bash("https://antigravity.google/install.sh", tx, id).await,
        "install_codex" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/codex-cli/main/install.sh", tx, id).await,
        "setup_agym" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/agym/main/install.sh", tx, id).await,
        "setup_cxm" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/cxm/main/install.sh", tx, id).await,
        "setup_dns" => setup_dns(tx).await,
        "setup_mtu_fix" => setup_mtu_fix(tx).await,
        "setup_sys_chronicle" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/sys-chronicle/main/install.sh", tx, id).await,
        "setup_tcp_keepalive" => setup_tcp_keepalive(tx).await,
        "setup_tmux_resurrect" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/tmux-resurrect-systemd/main/install.sh", tx, id).await,
        "setup_toss" => cmd::run_curl_bash("https://raw.githubusercontent.com/Praveensenpai/toss-rs/main/install.sh", tx, id).await,
        "setup_ufw" => setup_ufw(tx).await,
        "setup_vnstat_service" => cmd::run_sudo("systemctl", &["enable", "--now", "vnstat.service"], tx, id).await,
        _ => Ok(()),
    }
}

async fn setup_dns(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_sudo(
        "mkdir",
        &["-p", "/etc/systemd/resolved.conf.d"],
        tx,
        "setup_dns",
    )
    .await?;
    let content =
        "[Resolve]\nDNS=1.1.1.1 9.9.9.9 8.8.8.8\nFallbackDNS=1.0.0.1 8.8.4.4\nDomains=~.\n";
    let cmd =
        format!("printf '{content}' | sudo tee /etc/systemd/resolved.conf.d/dns.conf > /dev/null");
    cmd::run("bash", &["-c", &cmd], tx, "setup_dns").await?;
    cmd::run_sudo(
        "systemctl",
        &["restart", "systemd-resolved"],
        tx,
        "setup_dns",
    )
    .await
}

async fn setup_tcp_keepalive(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_sudo(
        "sysctl",
        &[
            "-w",
            "net.ipv4.tcp_keepalive_time=60",
            "net.ipv4.tcp_keepalive_intvl=10",
            "net.ipv4.tcp_keepalive_probes=6",
        ],
        tx,
        "setup_tcp_keepalive",
    )
    .await?;
    let content = "net.ipv4.tcp_keepalive_time = 60\nnet.ipv4.tcp_keepalive_intvl = 10\nnet.ipv4.tcp_keepalive_probes = 6\n";
    let cmd =
        format!("printf '{content}' | sudo tee /etc/sysctl.d/99-tcp-keepalive.conf > /dev/null");
    cmd::run("bash", &["-c", &cmd], tx, "setup_tcp_keepalive").await
}

async fn setup_mtu_fix(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let _ = cmd::run_sudo(
        "ip",
        &["link", "set", "wlan0", "mtu", "1400"],
        tx,
        "setup_mtu_fix",
    )
    .await;
    let dispatcher_script = "#!/bin/bash\nif [ \"$2\" = \"up\" ] && [ \"$1\" = \"wlan0\" ]; then\n  ip link set wlan0 mtu 1400\nfi\n";
    let cmd = format!("printf '{dispatcher_script}' | sudo tee /etc/NetworkManager/dispatcher.d/99-mtu.sh > /dev/null && sudo chmod +x /etc/NetworkManager/dispatcher.d/99-mtu.sh");
    let _ = cmd::run("bash", &["-c", &cmd], tx, "setup_mtu_fix").await;
    Ok(())
}

async fn setup_ufw(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(&["ufw"], tx, "setup_ufw").await?;
    cmd::run_sudo("ufw", &["default", "deny", "incoming"], tx, "setup_ufw").await?;
    cmd::run_sudo("ufw", &["default", "allow", "outgoing"], tx, "setup_ufw").await?;
    cmd::run_sudo("ufw", &["allow", "ssh"], tx, "setup_ufw").await?;
    cmd::run_sudo("ufw", &["--force", "enable"], tx, "setup_ufw").await
}
