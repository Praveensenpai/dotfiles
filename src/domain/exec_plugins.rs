use anyhow::Result;
use std::path::Path;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::env_util::config_dir;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

/// Renders embedded assets for the current user, replacing the `paisen` placeholder.
fn render_assets(assets: &[(&str, &str, bool)], user: &str) -> Vec<(String, String, bool)> {
    assets
        .iter()
        .map(|(path, content, executable)| {
            (
                path.to_string(),
                content.replace("paisen", user),
                *executable,
            )
        })
        .collect()
}

fn as_entries(assets: &[(String, String, bool)]) -> Vec<(&str, &str, bool)> {
    assets
        .iter()
        .map(|(path, content, executable)| (path.as_str(), content.as_str(), *executable))
        .collect()
}

/// Deploys plugin assets into `target`, rendering the user placeholder.
pub fn deploy_plugin_at(target: &Path, assets: &[(&str, &str, bool)], user: &str) -> Result<()> {
    let rendered = render_assets(assets, user);
    fs_util::deploy_assets(target, &as_entries(&rendered))
}

/// Deploys a user-owned Omarchy plugin into `~/.config/omarchy/plugins/<user>.<name>`.
pub fn deploy_plugin(name: &str, assets: &[(&str, &str, bool)], user: &str) -> Result<()> {
    let target = config_dir()
        .join("omarchy")
        .join("plugins")
        .join(format!("{user}.{name}"));
    deploy_plugin_at(&target, assets, user)
}

/// Enables an Omarchy plugin and restarts the shell so QML changes take effect.
pub async fn enable_plugin(
    plugin_id: &str,
    tx: &mpsc::Sender<RunnerEvent>,
    task_id: &str,
) -> Result<()> {
    let _ = cmd::run("omarchy", &["plugin", "enable", plugin_id], tx, task_id).await;
    let _ = cmd::run("omarchy", &["restart", "shell"], tx, task_id).await;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn render_assets_replaces_user_placeholder() {
        let assets = [("manifest.json", "id: paisen.menu", false)];
        let rendered = render_assets(&assets, "alice");
        assert_eq!(rendered[0].1, "id: alice.menu");
        assert!(!rendered[0].2);
    }

    #[test]
    fn entries_borrow_rendered_assets() {
        let rendered = vec![("a".to_string(), "body".to_string(), true)];
        let entries = as_entries(&rendered);
        assert_eq!(entries[0], ("a", "body", true));
    }
}
