use anyhow::Result;
use std::path::{Path, PathBuf};
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::env_util::{config_dir, home_dir};
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

const TASK: &str = "setup_opencode_config";
const TEMPLATE: &str = include_str!("../../assets/opencode/config/opencode.json.tmpl");
const API_KEY_TOKEN: &str = "__OPENROUTER_API_KEY__";
const PLACEHOLDER_KEY: &str = "CHANGE_ME";

const CONFIG_ASSETS: &[(&str, &str, bool)] = &[
    (
        "cli.json",
        include_str!("../../assets/opencode/config/cli.json"),
        false,
    ),
    (
        "package.json",
        include_str!("../../assets/opencode/config/package.json"),
        false,
    ),
    (
        "tui.json",
        include_str!("../../assets/opencode/config/tui.json"),
        false,
    ),
    (
        "plugins/background-tasks/index.js",
        include_str!("../../assets/opencode/plugins/background-tasks/index.js"),
        false,
    ),
    (
        "plugins/background-tasks/package.json",
        include_str!("../../assets/opencode/plugins/background-tasks/package.json"),
        false,
    ),
    (
        "plugins/background-tasks/tui.tsx",
        include_str!("../../assets/opencode/plugins/background-tasks/tui.tsx"),
        false,
    ),
    (
        "plugins/interval-ping/index.js",
        include_str!("../../assets/opencode/plugins/interval-ping/index.js"),
        false,
    ),
    (
        "plugins/interval-ping/package.json",
        include_str!("../../assets/opencode/plugins/interval-ping/package.json"),
        false,
    ),
    (
        "plugins/interval-ping/rpc.js",
        include_str!("../../assets/opencode/plugins/interval-ping/rpc.js"),
        false,
    ),
    (
        "plugins/interval-ping/tui.tsx",
        include_str!("../../assets/opencode/plugins/interval-ping/tui.tsx"),
        false,
    ),
    (
        "plugins/karakuri/package.json",
        include_str!("../../assets/opencode/plugins/karakuri/package.json"),
        false,
    ),
    (
        "plugins/karakuri/plugin.js",
        include_str!("../../assets/opencode/plugins/karakuri/plugin.js"),
        false,
    ),
    (
        "plugins/quota-fallback/index.js",
        include_str!("../../assets/opencode/plugins/quota-fallback/index.js"),
        false,
    ),
    (
        "plugins/quota-fallback/lib.js",
        include_str!("../../assets/opencode/plugins/quota-fallback/lib.js"),
        false,
    ),
    (
        "plugins/quota-fallback/package.json",
        include_str!("../../assets/opencode/plugins/quota-fallback/package.json"),
        false,
    ),
    (
        "plugins/quota-fallback/test.js",
        include_str!("../../assets/opencode/plugins/quota-fallback/test.js"),
        false,
    ),
];

const BIN_ASSETS: &[(&str, &str, bool)] = &[(
    "opencode2",
    include_str!("../../assets/opencode/bin/opencode2"),
    true,
)];

fn config_root() -> PathBuf {
    config_dir().join("opencode")
}

fn bin_dir() -> PathBuf {
    std::env::var_os("OPENCODE_HOME")
        .map_or_else(|| home_dir().join(".opencode"), PathBuf::from)
        .join("bin")
}

fn render_template(api_key: &str) -> String {
    TEMPLATE.replace(API_KEY_TOKEN, api_key)
}

fn install_config_at(target: &Path, api_key: &str) -> Result<()> {
    if api_key.is_empty() && target.exists() {
        return Ok(());
    }
    let key = if api_key.is_empty() {
        PLACEHOLDER_KEY
    } else {
        api_key
    };
    fs_util::write_private_file(target, &render_template(key))
}

fn install_config() -> Result<()> {
    let api_key = std::env::var("OPENROUTER_API_KEY").unwrap_or_default();
    install_config_at(&config_root().join("opencode.json"), &api_key)
}

fn install_assets_at(config: &Path, bin: &Path) -> Result<()> {
    fs_util::deploy_assets(config, CONFIG_ASSETS)?;
    fs_util::deploy_assets(bin, BIN_ASSETS)
}

fn install_assets() -> Result<()> {
    install_assets_at(&config_root(), &bin_dir())
}

fn notify(tx: &mpsc::Sender<RunnerEvent>, line: &str) {
    let _ = tx.try_send(RunnerEvent::TaskProgress {
        id: TASK.to_string(),
        line: line.to_string(),
    });
}

async fn install_plugin_deps(tx: &mpsc::Sender<RunnerEvent>) {
    if !config_root().join("package.json").exists() {
        return;
    }
    for program in ["bun", "npm"] {
        if cmd::command_exists(program).await {
            let _ = cmd::run_in(program, &["install", "--silent"], &config_root(), tx, TASK).await;
            return;
        }
    }
    notify(
        tx,
        "Neither bun nor npm found; skipping plugin dependency install",
    );
}

async fn sync_karakuri(tx: &mpsc::Sender<RunnerEvent>) {
    if std::env::var("SKIP_KARAKURI").as_deref() == Ok("1") {
        notify(tx, "SKIP_KARAKURI=1; skipping karakuri sync");
        return;
    }
    if !cmd::command_exists("karakuri").await {
        notify(tx, "karakuri not installed; skipping skill sync");
        return;
    }
    let _ = cmd::run("karakuri", &["sync"], tx, TASK).await;
}

/// Deploys the bundled `OpenCode` configuration, plugins, and wrapper script.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    install_config()?;
    install_assets()?;
    install_plugin_deps(tx).await;
    sync_karakuri(tx).await;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn template_renders_api_key() {
        let rendered = render_template("test-key");
        assert!(rendered.contains("\"apiKey\": \"test-key\""));
        assert!(!rendered.contains(API_KEY_TOKEN));
    }

    #[test]
    fn assets_cover_plugins_and_wrapper() {
        assert!(CONFIG_ASSETS
            .iter()
            .any(|(path, _, _)| path.starts_with("plugins/karakuri/")));
        assert!(BIN_ASSETS.iter().any(|(path, _, _)| *path == "opencode2"));
    }

    #[test]
    fn deploy_is_idempotent_and_preserves_existing_key() {
        let dir = fs_util::test_dir("opencode");
        let config = dir.join("config");
        let bin = dir.join("bin");
        let target = config.join("opencode.json");

        assert!(install_config_at(&target, "").is_ok());
        assert!(install_assets_at(&config, &bin).is_ok());
        let first = std::fs::read_to_string(&target).unwrap_or_default();
        assert!(first.contains(PLACEHOLDER_KEY));
        assert!(config.join("plugins/karakuri/plugin.js").exists());
        assert!(bin.join("opencode2").exists());

        assert!(std::fs::write(&target, "user-edited").is_ok());
        assert!(install_config_at(&target, "").is_ok());
        assert_eq!(
            std::fs::read_to_string(&target).unwrap_or_default(),
            "user-edited"
        );

        assert!(install_assets_at(&config, &bin).is_ok());
        assert!(config.join("plugins/karakuri/plugin.js").exists());
        let _ = std::fs::remove_dir_all(&dir);
    }
}
