use anyhow::Result;
use chrono::Local;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};
use tokio::sync::mpsc;

use crate::domain::{execute_task, Task};

/// Events emitted during background execution of dotfiles setup tasks.
#[derive(Debug, Clone)]
pub enum RunnerEvent {
    TaskStarted {
        id: String,
    },
    TaskProgress {
        id: String,
        line: String,
    },
    TaskFinished {
        id: String,
        success: bool,
        duration: Duration,
        error: Option<String>,
    },
    AllFinished,
}

/// Executes tasks silently, redirecting raw output to disk and streaming clean events.
pub struct ProcessRunner {
    log_path: PathBuf,
}

impl ProcessRunner {
    /// Creates a new runner with a dedicated log directory.
    pub fn new() -> Result<Self> {
        let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
        let log_dir = Path::new(&home).join(".local/state/omarchy-dotfiles");
        std::fs::create_dir_all(&log_dir)?;
        let log_path = log_dir.join("install.log");

        Ok(Self { log_path })
    }

    /// Executes a single task, logging progress and emitting status events.
    pub async fn run_task(&self, task: &Task, tx: mpsc::Sender<RunnerEvent>) -> Result<bool> {
        let start_time = Instant::now();

        let _ = tx
            .send(RunnerEvent::TaskStarted {
                id: task.id.to_string(),
            })
            .await;
        self.write_log_header(task)?;

        let result = execute_task(task, &tx).await;

        let duration = start_time.elapsed();
        let success = result.is_ok();
        let error = result.err().map(|e| e.to_string());

        self.write_log_footer(task, success, duration)?;

        let _ = tx
            .send(RunnerEvent::TaskFinished {
                id: task.id.to_string(),
                success,
                duration,
                error,
            })
            .await;

        Ok(success)
    }

    fn write_log_header(&self, task: &Task) -> Result<()> {
        let mut f = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.log_path)?;
        let time = Local::now().format("%Y-%m-%d %H:%M:%S");
        writeln!(
            f,
            "\n=== [{time}] Running Task: {} ({}) ===",
            task.name, task.id
        )?;
        Ok(())
    }

    fn write_log_footer(&self, task: &Task, success: bool, duration: Duration) -> Result<()> {
        let mut f = OpenOptions::new().append(true).open(&self.log_path)?;
        let time = Local::now().format("%Y-%m-%d %H:%M:%S");
        writeln!(
            f,
            "=== [{time}] Finished Task: {} (success: {success}, duration: {duration:.2?}) ===",
            task.name
        )?;
        Ok(())
    }
}
