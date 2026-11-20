use anyhow::Result;
use std::path::Path;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::env_util::{home_dir, user_name};
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

/// Configures Omarchy Quickshell bar themes, widgets, and Japanese calendar.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let config_dir = home_dir().join(".config/omarchy");
    let shell_config = config_dir.join("shell.json");
    if !shell_config.exists() {
        return Ok(());
    }

    let user = user_name();
    clone_and_enable_widgets(tx).await?;
    disable_unused_widgets(tx).await?;
    ensure_center_layout(&config_dir, &user)?;
    patch_bar_qml_files(&config_dir)?;
    deploy_system_resources_plugin(&config_dir)?;
    enable_system_resources(tx).await?;

    Ok(())
}

async fn clone_and_enable_widgets(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let user = user_name();
    let plugins = ["bluetooth", "network", "audio", "clock"];
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
    let user = user_name();
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

const PANEL_QML_TEMPLATE: &str = include_str!("../../assets/system-resources/Panel.qml");
const STATS_SH: &str = include_str!("../../assets/system-resources/stats.sh");

fn deploy_system_resources_plugin(config_dir: &Path) -> Result<()> {
    let user = user_name();
    let sys_dir = config_dir
        .join("plugins")
        .join(format!("{user}.system-resources"));

    write_system_resources_manifest(&sys_dir, &user)?;
    write_system_resources_assets(&sys_dir, &user)?;
    Ok(())
}

fn write_system_resources_manifest(sys_dir: &Path, user: &str) -> Result<()> {
    let manifest = format!(
        r#"{{
  "schemaVersion": 1,
  "id": "{user}.system-resources",
  "name": "System Resources",
  "version": "1.0.0",
  "author": "{user}",
  "description": "CPU and RAM system resource usage monitor with detail popover",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {{
    "barWidget": "Panel.qml"
  }},
  "barWidget": {{
    "displayName": "System Resources",
    "description": "CPU and RAM system resource usage monitor with detail popover",
    "category": "System",
    "allowMultiple": false
  }}
}}"#
    );
    fs_util::write_file(&sys_dir.join("manifest.json"), &manifest)
}

fn write_system_resources_assets(sys_dir: &Path, user: &str) -> Result<()> {
    let panel_qml = PANEL_QML_TEMPLATE.replace("__USER__", user);
    fs_util::write_file(&sys_dir.join("Panel.qml"), &panel_qml)?;
    fs_util::write_executable_file(&sys_dir.join("stats.sh"), STATS_SH)?;

    let old_bar_widget = sys_dir.join("BarWidget.qml");
    if old_bar_widget.exists() {
        let _ = std::fs::remove_file(old_bar_widget);
    }
    Ok(())
}

async fn enable_system_resources(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let user = user_name();
    let plugin_id = format!("{user}.system-resources");
    let _ = cmd::run(
        "omarchy",
        &["plugin", "enable", &plugin_id],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    let _ = cmd::run(
        "omarchy",
        &["bar", "put", &plugin_id, "--after", "omarchy.monitor"],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    let _ = cmd::run(
        "omarchy",
        &["restart", "shell"],
        tx,
        "set_omarchy_shell_bar",
    )
    .await;
    Ok(())
}

/// Partitions center modules so indicators sits in centerBegin, clock in center, and others in centerEnd.
pub fn ensure_center_layout(config_dir: &Path, user: &str) -> Result<()> {
    let shell_json_path = config_dir.join("shell.json");
    if !shell_json_path.exists() {
        return Ok(());
    }

    let content = std::fs::read_to_string(&shell_json_path)?;
    let mut val: serde_json::Value = serde_json::from_str(&content)?;

    if partition_center_layout(&mut val, user) {
        let pretty = serde_json::to_string_pretty(&val)?;
        fs_util::write_file(&shell_json_path, &pretty)?;
    }

    Ok(())
}

fn partition_center_layout(val: &mut serde_json::Value, user: &str) -> bool {
    let Some(layout) = val.get_mut("bar").and_then(|b| b.get_mut("layout")) else {
        return false;
    };
    let Some(center_arr) = layout.get("center").and_then(|c| c.as_array()).cloned() else {
        return false;
    };

    let clock_id = format!("{user}.clock");
    let mut indicators = None;
    let mut clock = None;
    let mut trailing = Vec::new();

    for item in center_arr {
        let id = item.get("id").and_then(|v| v.as_str()).unwrap_or("");
        if id == "omarchy.indicators" {
            indicators = Some(item);
        } else if id == clock_id
            || id == "omarchy.clock"
            || id.split('.').next_back() == Some("clock")
        {
            clock = Some(item);
        } else {
            trailing.push(item);
        }
    }

    if indicators.is_none() && trailing.is_empty() {
        return false;
    }

    let Some(layout_obj) = layout.as_object_mut() else {
        return false;
    };

    if let Some(ind) = indicators {
        append_if_missing(layout_obj, "centerBegin", ind);
    }
    if let Some(clk) = clock {
        layout_obj.insert("center".to_string(), serde_json::json!([clk]));
    }
    for item in trailing {
        append_if_missing(layout_obj, "centerEnd", item);
    }

    true
}

fn append_if_missing(
    layout_obj: &mut serde_json::Map<String, serde_json::Value>,
    section: &str,
    entry: serde_json::Value,
) {
    let arr = layout_obj
        .entry(section.to_string())
        .or_insert_with(|| serde_json::json!([]));
    let entry_id = entry.get("id").and_then(|v| v.as_str()).unwrap_or("");
    if let Some(list) = arr.as_array_mut() {
        let exists = list
            .iter()
            .any(|item| item.get("id").and_then(|i| i.as_str()) == Some(entry_id));
        if !exists {
            list.push(entry);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn partitions_indicators_and_trailing_from_center() {
        let mut sample = serde_json::json!({
            "bar": {
                "layout": {
                    "center": [
                        { "id": "omarchy.indicators" },
                        { "id": "paisen.clock" },
                        { "id": "omarchy.elsewhen" }
                    ],
                    "centerBegin": [],
                    "centerEnd": []
                }
            }
        });

        assert!(partition_center_layout(&mut sample, "paisen"));

        let center = sample["bar"]["layout"]["center"]
            .as_array()
            .cloned()
            .unwrap_or_default();
        let center_begin = sample["bar"]["layout"]["centerBegin"]
            .as_array()
            .cloned()
            .unwrap_or_default();
        let center_end = sample["bar"]["layout"]["centerEnd"]
            .as_array()
            .cloned()
            .unwrap_or_default();

        assert_eq!(center.len(), 1);
        assert_eq!(center[0]["id"], "paisen.clock");
        assert_eq!(center_begin.len(), 1);
        assert_eq!(center_begin[0]["id"], "omarchy.indicators");
        assert_eq!(center_end.len(), 1);
        assert_eq!(center_end[0]["id"], "omarchy.elsewhen");
    }

    #[test]
    fn partition_is_idempotent_when_already_separated() {
        let mut sample = serde_json::json!({
            "bar": {
                "layout": {
                    "center": [
                        { "id": "paisen.clock" }
                    ],
                    "centerBegin": [
                        { "id": "omarchy.indicators" }
                    ],
                    "centerEnd": [
                        { "id": "omarchy.elsewhen" }
                    ]
                }
            }
        });

        assert!(!partition_center_layout(&mut sample, "paisen"));
    }
}
