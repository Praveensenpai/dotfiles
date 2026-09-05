use anyhow::Result;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::runner::RunnerEvent;

/// Executes a maintenance task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    if id == "setup_arch_cleaner" {
        cmd::run_curl_bash(
            "https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh",
            tx,
            id,
        )
        .await
    } else {
        Ok(())
    }
}
