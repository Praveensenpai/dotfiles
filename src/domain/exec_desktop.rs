use anyhow::Result;
use tokio::sync::mpsc;

use crate::domain::exec_ime;
use crate::domain::exec_shell_bar;
use crate::infra::cmd;
use crate::infra::env_util::home_dir;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

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
        "setup_japanese_ime" => setup_japanese_ime(tx).await,
        "setup_kitty_default_terminal" => setup_kitty_default_terminal(tx).await,
        "setup_omarchy_refined_menu" => cmd::run_curl_bash(
            "https://raw.githubusercontent.com/Praveensenpai/omarchy-refined-menu/main/install.sh",
            tx,
            id,
        )
        .await,
        "setup_poweroff_hibernation" => setup_poweroff_hibernation(tx).await,
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

async fn setup_poweroff_hibernation(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_sudo(
        "mkdir",
        &["-p", "/etc/UPower/UPower.conf.d"],
        tx,
        "setup_poweroff_hibernation",
    )
    .await?;
    let upower_conf = "[UPower]\nPercentageLow=20.0\nPercentageCritical=10.0\nPercentageAction=5.0\nCriticalPowerAction=Hibernate\n";
    let cmd_str = format!(
        "printf '%s' \"{upower_conf}\" > /etc/UPower/UPower.conf.d/99-critical-hibernate.conf"
    );
    cmd::run_sudo("sh", &["-c", &cmd_str], tx, "setup_poweroff_hibernation").await?;
    let _ = cmd::run_sudo(
        "systemctl",
        &["try-restart", "upower.service"],
        tx,
        "setup_poweroff_hibernation",
    )
    .await;

    let ext_dir = home_dir().join(".config/omarchy/extensions");
    if !ext_dir.exists() {
        std::fs::create_dir_all(&ext_dir)?;
    }
    let menu_jsonc = ext_dir.join("omarchy-menu.jsonc");
    let menu_item = "  \"system.shutdown\": {\n    \"icon\": \"󰐥\",\n    \"label\": \"Shutdown (Hibernate)\",\n    \"description\": \"Hibernate and save session state to disk\",\n    \"action\": \"systemctl hibernate\"\n  }\n";
    if menu_jsonc.exists() {
        let existing = std::fs::read_to_string(&menu_jsonc)?;
        if !existing.contains("system.shutdown") {
            let updated = if let Some(last_brace) = existing.rfind('}') {
                let (prefix, suffix) = existing.split_at(last_brace);
                format!("{prefix}{menu_item}{suffix}")
            } else {
                format!("{{\n{menu_item}}}\n")
            };
            std::fs::write(&menu_jsonc, updated)?;
        }
    } else {
        fs_util::write_file(&menu_jsonc, &format!("{{\n{menu_item}}}\n"))?;
    }

    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "alias poweroff='systemctl hibernate'")?;
    fs_util::ensure_line(&bashrc, "alias shutdown='systemctl hibernate'")?;
    fs_util::ensure_line(&bashrc, "alias cold-poweroff='command poweroff'")?;

    let _ = cmd::run(
        "omarchy",
        &["menu", "refresh"],
        tx,
        "setup_poweroff_hibernation",
    )
    .await;
    Ok(())
}

async fn setup_japanese_ime(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let fcitx_dir = home_dir().join(".config/fcitx5");
    let config_path = fcitx_dir.join("config");
    let profile_path = fcitx_dir.join("profile");
    let env_path = home_dir().join(".config/environment.d/im.conf");

    let fcitx_config = "[Hotkey/TriggerKeys]\n0=Zenkaku_Hankaku\n1=Control+space\n\n[Hotkey/EnumerateGroupForwardKeys]\n\n[Hotkey/EnumerateGroupBackwardKeys]\n\n[Behavior/DisabledAddons]\n0=notificationitem\n\n[Behavior]\nActiveByDefault=False\nShareInputState=All\nresetStateWhenFocusIn=No\n";
    fs_util::write_file(&config_path, fcitx_config)?;

    let fcitx_profile = "[Groups/0]\nName=Default\nDefault Layout=us\nDefaultIM=mozc\n\n[Groups/0/Items/0]\nName=keyboard-us\nLayout=\n\n[Groups/0/Items/1]\nName=mozc\nLayout=\n\n[GroupOrder]\n0=Default\n";
    if !profile_path.exists() {
        fs_util::write_file(&profile_path, fcitx_profile)?;
    }

    let im_env = "QT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx\nSDL_IM_MODULE=fcitx\nGTK_IM_MODULE=\n";
    fs_util::write_file(&env_path, im_env)?;

    patch_ime_keybinds()?;
    exec_ime::execute(tx, "setup_japanese_ime").await?;

    let _ = cmd::run(
        "systemctl",
        &["--user", "try-restart", "omarchy-fcitx5.service"],
        tx,
        "setup_japanese_ime",
    )
    .await;

    Ok(())
}

fn patch_ime_keybinds() -> Result<()> {
    let autostart_path = home_dir().join(".config/hypr/autostart.conf");
    if autostart_path.exists() {
        let content = std::fs::read_to_string(&autostart_path)?;
        if content.contains("\nexec-once = fcitx5 -d") {
            let updated = content.replace(
                "\nexec-once = fcitx5 -d",
                "\n# exec-once = fcitx5 -d # Managed by systemd user unit: omarchy-fcitx5.service",
            );
            std::fs::write(&autostart_path, updated)?;
        }
    }

    let bindings_conf = home_dir().join(".config/hypr/bindings.conf");
    if bindings_conf.exists() {
        let content = std::fs::read_to_string(&bindings_conf)?;
        if !content.contains("unbind = CTRL, SPACE") {
            let updated = content.replace(
                "bind = CTRL, SPACE",
                "unbind = CTRL, SPACE\nbind = CTRL, SPACE",
            );
            std::fs::write(&bindings_conf, updated)?;
        }
    }

    let bindings_lua = home_dir().join(".config/hypr/bindings.lua");
    if bindings_lua.exists() {
        let content = std::fs::read_to_string(&bindings_lua)?;
        if !content.contains("hl.unbind(\"CTRL + SPACE\")") {
            let updated = content.replace(
                "o.bind(\"CTRL + SPACE\"",
                "hl.unbind(\"CTRL + SPACE\")\no.bind(\"CTRL + SPACE\"",
            );
            std::fs::write(&bindings_lua, updated)?;
        }
    }
    Ok(())
}

async fn setup_kitty_default_terminal(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let kitty_conf = home_dir().join(".config/kitty/kitty.conf");
    let symbol_line = "symbol_map U+23E9-U+23FA Adwaita Mono";
    fs_util::ensure_line(&kitty_conf, symbol_line)?;

    let _ = cmd::run(
        "omarchy",
        &["default", "terminal", "kitty"],
        tx,
        "setup_kitty_default_terminal",
    )
    .await;

    let bindings_conf = home_dir().join(".config/hypr/bindings.conf");
    if bindings_conf.exists() {
        let content = std::fs::read_to_string(&bindings_conf)?;
        if content.contains("footclient -D \"$(omarchy-cmd-terminal-cwd)\" || ") {
            let updated = content.replace("footclient -D \"$(omarchy-cmd-terminal-cwd)\" || ", "");
            std::fs::write(&bindings_conf, updated)?;
        }
    }
    Ok(())
}
