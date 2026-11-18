use anyhow::Result;
use tokio::sync::mpsc;

use crate::domain::exec_plugins;
use crate::infra::env_util::user_name;
use crate::infra::runner::RunnerEvent;

const ASSETS: &[(&str, &str, bool)] = &[
    (
        "manifest.json",
        include_str!("../../assets/refined-menu/plugin/manifest.json"),
        false,
    ),
    (
        "Menu.qml",
        include_str!("../../assets/refined-menu/plugin/Menu.qml"),
        false,
    ),
    (
        "BarWidget.qml",
        include_str!("../../assets/refined-menu/plugin/BarWidget.qml"),
        false,
    ),
    (
        "MenuModel.js",
        include_str!("../../assets/refined-menu/plugin/MenuModel.js"),
        false,
    ),
    (
        "AppSearch.js",
        include_str!("../../assets/refined-menu/plugin/AppSearch.js"),
        false,
    ),
];

/// Deploys and enables the refined application menu plugin.
pub async fn execute(tx: &mpsc::Sender<RunnerEvent>, task_id: &str) -> Result<()> {
    let user = user_name();
    exec_plugins::deploy_plugin("menu", ASSETS, &user)?;
    exec_plugins::enable_plugin(&format!("{user}.menu"), tx, task_id).await
}
