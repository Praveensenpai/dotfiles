use anyhow::Result;
use std::path::{Path, PathBuf};
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

const POWER_PANEL_QML: &str = include_str!("../../assets/power-plugin/Panel.qml");
const POWER_MODEL_JS: &str = include_str!("../../assets/power-plugin/Model.js");
const POWER_MANIFEST: &str = include_str!("../../assets/power-plugin/manifest.json");
const CHARGE_LIMIT_HELPER: &str = include_str!("../../assets/power-plugin/set-charge-limit.sh");
const CHARGE_LIMIT_POLICY: &str = include_str!("../../assets/power-plugin/charge-limit.policy");
const CHARGE_LIMIT_SERVICE: &str =
    include_str!("../../assets/power-plugin/battery-charge-limit.service");

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Sets up the battery charge limiter service, polkit action, and power plugin.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    let config_dir = home_dir().join(".config/omarchy");

    deploy_power_plugin(&config_dir, &user)?;
    install_system_binaries(tx).await?;
    install_system_configs(tx).await?;
    enable_service(tx).await?;
    patch_power_in_shell_json(&config_dir, &user)?;

    Ok(())
}

fn deploy_power_plugin(config_dir: &Path, user: &str) -> Result<()> {
    let plugin_dir = config_dir.join("plugins").join(format!("{user}.power"));

    let manifest = POWER_MANIFEST.replace("__USER__", user);
    fs_util::write_file(&plugin_dir.join("manifest.json"), &manifest)?;
    fs_util::write_file(&plugin_dir.join("Panel.qml"), POWER_PANEL_QML)?;
    fs_util::write_file(&plugin_dir.join("Model.js"), POWER_MODEL_JS)?;

    Ok(())
}

async fn install_system_binaries(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let task = "setup_battery_charge_limit";
    let tmp_helper = std::env::temp_dir().join("omarchy-set-charge-limit.sh");
    fs_util::write_file(&tmp_helper, CHARGE_LIMIT_HELPER)?;

    let helper_str = tmp_helper.to_string_lossy();
    cmd::run_sudo(
        "install",
        &[
            "-Dm",
            "0755",
            &helper_str,
            "/usr/local/bin/omarchy-set-charge-limit",
        ],
        tx,
        task,
    )
    .await?;

    let tmp_policy = std::env::temp_dir().join("org.omarchy.charge-limit.policy");
    fs_util::write_file(&tmp_policy, CHARGE_LIMIT_POLICY)?;

    let policy_str = tmp_policy.to_string_lossy();
    cmd::run_sudo(
        "install",
        &[
            "-Dm",
            "0644",
            &policy_str,
            "/usr/share/polkit-1/actions/org.omarchy.charge-limit.policy",
        ],
        tx,
        task,
    )
    .await
}

async fn install_system_configs(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let task = "setup_battery_charge_limit";
    let tmp_service = std::env::temp_dir().join("battery-charge-limit.service");
    fs_util::write_file(&tmp_service, CHARGE_LIMIT_SERVICE)?;

    let service_str = tmp_service.to_string_lossy();
    cmd::run_sudo(
        "install",
        &[
            "-Dm",
            "0644",
            &service_str,
            "/etc/systemd/system/battery-charge-limit.service",
        ],
        tx,
        task,
    )
    .await?;

    let cfg = Path::new("/etc/battery-charge-limit.conf");
    if !cfg.exists() {
        let tmp_cfg = std::env::temp_dir().join("battery-charge-limit.conf");
        fs_util::write_file(&tmp_cfg, "80\n")?;
        let cfg_str = tmp_cfg.to_string_lossy();
        cmd::run_sudo(
            "install",
            &["-Dm", "0644", &cfg_str, "/etc/battery-charge-limit.conf"],
            tx,
            task,
        )
        .await?;
    }

    Ok(())
}

async fn enable_service(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let task = "setup_battery_charge_limit";
    cmd::run_sudo("systemctl", &["daemon-reload"], tx, task).await?;
    cmd::run_sudo(
        "systemctl",
        &["enable", "--now", "battery-charge-limit.service"],
        tx,
        task,
    )
    .await
}

fn patch_power_in_shell_json(config_dir: &Path, user: &str) -> Result<()> {
    let shell_json = config_dir.join("shell.json");
    if !shell_json.exists() {
        return Ok(());
    }

    let content = std::fs::read_to_string(&shell_json)?;
    if content.contains("\"omarchy.power\"") {
        let replacement = format!("\"{user}.power\"");
        let updated = content.replace("\"omarchy.power\"", &replacement);
        std::fs::write(&shell_json, updated)?;
    }

    Ok(())
}
