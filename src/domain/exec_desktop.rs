use anyhow::Result;
use std::path::PathBuf;
use tokio::sync::mpsc;

use crate::domain::exec_shell_bar;
use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Executes a desktop task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "disable_bluetooth" => {
            cmd::run_sudo("systemctl", &["disable", "bluetooth.service"], tx, id).await
        }
        "disable_voxtype" => cmd::run(
            "systemctl",
            &["--user", "disable", "--now", "voxtype.service"],
            tx,
            id,
        )
        .await
        .or(Ok(())),
        "remove_omarchy_preinstalls" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/omarchy-debloat/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "set_alacritty_font_size" => set_alacritty_font_size(),
        "set_hyprland_gaps_and_borders" => set_hyprland_gaps_and_borders(),
        "set_hyprland_idle_and_keybinds" => set_hyprland_idle_and_keybinds(),
        "set_hyprland_monitor_scale" => set_hyprland_monitor_scale(),
        "set_omarchy_shell_bar" => exec_shell_bar::execute(tx).await,
        "setup_omarchy_refined_menu" => cmd::run_curl_bash(
            "https://raw.githubusercontent.com/Praveensenpai/omarchy-refined-menu/main/install.sh",
            tx,
            id,
        )
        .await,
        _ => Ok(()),
    }
}

fn set_alacritty_font_size() -> Result<()> {
    let conf = home_dir().join(".config/alacritty/alacritty.toml");
    if conf.exists() {
        let content = std::fs::read_to_string(&conf)?;
        if content.contains("size =") {
            let updated = content
                .lines()
                .map(|line| {
                    if line.trim_start().starts_with("size =") {
                        "size = 10"
                    } else {
                        line
                    }
                })
                .collect::<Vec<_>>()
                .join("\n");
            std::fs::write(&conf, updated)?;
        } else {
            fs_util::ensure_line(&conf, "size = 10")?;
        }
    } else {
        fs_util::write_file(&conf, "[font]\nsize = 10\n")?;
    }
    Ok(())
}

fn set_hyprland_gaps_and_borders() -> Result<()> {
    let lua_path = home_dir().join(".config/hypr/looknfeel.lua");
    let conf_path = home_dir().join(".config/hypr/looknfeel.conf");
    let lua_content = r#"hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,
    col = {
      active_border = "rgba(7aa2f755)",
      inactive_border = "rgba(59595922)",
    },
  },
})"#;
    let conf_content = r"general {
    gaps_in = 0
    gaps_out = 0
    border_size = 1
    col.active_border = rgba(7aa2f755)
    col.inactive_border = rgba(59595922)
}";
    fs_util::write_file(&lua_path, lua_content)?;
    fs_util::write_file(&conf_path, conf_content)?;
    Ok(())
}

fn set_hyprland_monitor_scale() -> Result<()> {
    let conf = home_dir().join(".config/hypr/monitors.conf");
    fs_util::write_file(&conf, "monitor=,preferred,auto,1.5\n")?;
    let lua = home_dir().join(".config/hypr/monitors.lua");
    if lua.exists() {
        let content = std::fs::read_to_string(&lua)?;
        if content.contains("omarchy_monitor_scale =") {
            let updated =
                content.replace("omarchy_monitor_scale = 1.0", "omarchy_monitor_scale = 1.5");
            std::fs::write(&lua, updated)?;
        }
    }
    Ok(())
}

fn set_hyprland_idle_and_keybinds() -> Result<()> {
    let hypridle = home_dir().join(".config/hypr/hypridle.conf");
    let idle_content = r"general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 1800
    on-timeout = loginctl lock-session
}

listener {
    timeout = 1802
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}";
    fs_util::write_file(&hypridle, idle_content)?;

    let bindings = home_dir().join(".config/hypr/bindings.conf");
    fs_util::ensure_line(
        &bindings,
        "bindd = SHIFT, XF86MonBrightnessDown, Set brightness to 0%, exec, brightnessctl -q s 0%",
    )?;
    fs_util::ensure_line(
        &bindings,
        "bindd = SUPER, XF86MonBrightnessDown, Set brightness to 0%, exec, brightnessctl -q s 0%",
    )?;
    Ok(())
}
