use anyhow::Result;
use tokio::sync::mpsc;

use crate::domain::task::{Task, TaskCategory};
use crate::domain::{exec_core, exec_desktop, exec_maint, exec_media, exec_rice, exec_tools};
use crate::infra::runner::RunnerEvent;

/// Dispatches execution of a task to its category-specific native Rust executor.
pub async fn execute_task(task: &Task, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match task.category {
        TaskCategory::Core => exec_core::execute(task.id, tx).await,
        TaskCategory::Desktop => exec_desktop::execute(task.id, tx).await,
        TaskCategory::Rice => exec_rice::execute(task.id, tx).await,
        TaskCategory::Media => exec_media::execute(task.id, tx).await,
        TaskCategory::Tools => exec_tools::execute(task.id, tx).await,
        TaskCategory::Maintenance => exec_maint::execute(task.id, tx).await,
    }
}
