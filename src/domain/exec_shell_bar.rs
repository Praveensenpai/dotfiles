use anyhow::Result;
use std::path::{Path, PathBuf};
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Configures Omarchy Quickshell bar themes, widgets, and Japanese calendar.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let config_dir = home_dir().join(".config/omarchy");
    let shell_config = config_dir.join("shell.json");
    if !shell_config.exists() {
        return Ok(());
    }

    clone_and_enable_widgets(tx).await?;
    disable_unused_widgets(tx).await?;
    patch_bar_qml_files(&config_dir)?;
    deploy_system_resources_plugin(&config_dir)?;
    enable_system_resources(tx).await?;

    Ok(())
}

async fn clone_and_enable_widgets(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    let plugins = ["power", "bluetooth", "network", "audio", "clock"];
    for w in plugins {
        let plugin_id = format!("{user}.{w}");
        let _ = cmd::run(
            "omarchy",
            &["plugin", "clone", &format!("omarchy.{w}")],
            tx,
            "set_omarchy_shell_bar",
        )
        .await;
        let _ = cmd::run(
            "omarchy",
            &["plugin", "enable", &plugin_id],
            tx,
            "set_omarchy_shell_bar",
        )
        .await;
    }
    Ok(())
}

async fn disable_unused_widgets(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let _ = cmd::run(
        "omarchy",
        &["plugin", "disable", "omarchy.agents"],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    let _ = cmd::run(
        "omarchy",
        &["plugin", "disable", "omarchy.weather"],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    Ok(())
}

fn patch_bar_qml_files(config_dir: &Path) -> Result<()> {
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    let plugins_dir = config_dir.join("plugins");

    let clock_qml = plugins_dir.join(format!("{user}.clock/BarWidget.qml"));
    let jp_formatter = r#"  function formatted(date) {
    if (!vertical) {
      var weekdays = ["日", "月", "火", "水", "木", "金", "土"]
      var hours = ("0" + date.getHours()).slice(-2)
      var minutes = ("0" + date.getMinutes()).slice(-2)
      return date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate()
        + "日（" + weekdays[date.getDay()] + "） " + hours + ":" + minutes
    }
    return Qt.formatDateTime(date, activeFormat)
  }"#;
    if clock_qml.exists() {
        let content = std::fs::read_to_string(&clock_qml)?;
        if !content.contains("weekdays") {
            let updated = content.replace("function formatted(date) {", jp_formatter);
            let _ = std::fs::write(&clock_qml, updated);
        }
    }
    Ok(())
}

fn deploy_system_resources_plugin(config_dir: &Path) -> Result<()> {
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    let sys_dir = config_dir
        .join("plugins")
        .join(format!("{user}.system-resources"));

    let manifest = format!(
        r#"{{
  "schemaVersion": 1,
  "id": "{user}.system-resources",
  "name": "System Resources",
  "version": "1.0.0",
  "author": "{user}",
  "description": "CPU and RAM system resource usage monitor",
  "kinds": ["bar-widget"]
}}"#
    );
    fs_util::write_file(&sys_dir.join("manifest.json"), &manifest)?;

    let bar_widget_qml = r#"import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons

Item {
  id: root
  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  Row {
    id: row
    spacing: 8
    Text {
      text: "⚡ CPU/RAM"
      color: Color.foreground
    }
  }
}"#;
    fs_util::write_file(&sys_dir.join("BarWidget.qml"), bar_widget_qml)?;
    Ok(())
}

async fn enable_system_resources(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    let plugin_id = format!("{user}.system-resources");
    let _ = cmd::run(
        "omarchy",
        &["plugin", "enable", &plugin_id],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    Ok(())
}
