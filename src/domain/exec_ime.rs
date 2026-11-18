use anyhow::Result;
use tokio::sync::mpsc;

use crate::domain::exec_plugins;
use crate::infra::env_util::user_name;
#[cfg(test)]
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

const ASSETS: &[(&str, &str, bool)] = &[
    (
        "manifest.json",
        include_str!("../../assets/japanese-ime/manifest.json"),
        false,
    ),
    (
        "Panel.qml",
        include_str!("../../assets/japanese-ime/Panel.qml"),
        false,
    ),
    (
        "status.sh",
        include_str!("../../assets/japanese-ime/status.sh"),
        true,
    ),
    (
        "action.sh",
        include_str!("../../assets/japanese-ime/action.sh"),
        true,
    ),
];

/// Deploys and enables the Japanese IME bar widget.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>, task_id: &str) -> Result<()> {
    let user = user_name();
    exec_plugins::deploy_plugin("japanese-ime", ASSETS, &user)?;
    exec_plugins::enable_plugin(&format!("{user}.japanese-ime"), tx, task_id).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn deploying_plugin_twice_is_idempotent() {
        let dir = fs_util::test_dir("ime");
        assert!(exec_plugins::deploy_plugin_at(&dir, ASSETS, "alice").is_ok());
        let manifest = std::fs::read_to_string(dir.join("manifest.json")).unwrap_or_default();
        assert!(manifest.contains("alice.japanese-ime"));

        assert!(exec_plugins::deploy_plugin_at(&dir, ASSETS, "alice").is_ok());
        let again = std::fs::read_to_string(dir.join("manifest.json")).unwrap_or_default();
        assert_eq!(manifest, again);
        let _ = std::fs::remove_dir_all(&dir);
    }
}
