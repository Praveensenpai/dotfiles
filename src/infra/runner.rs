use anyhow::{anyhow, Context, Result};
use chrono::Local;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Stdio;
use std::time::{Duration, Instant};
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use tokio::sync::mpsc;

use crate::domain::Task;

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
    temp_dir: PathBuf,
}

impl ProcessRunner {
    /// Creates a new runner with a dedicated log directory and PID-based temp dir.
    pub fn new() -> Result<Self> {
        let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
        let log_dir = Path::new(&home).join(".local/state/omarchy-dotfiles");
        fs::create_dir_all(&log_dir)?;
        let log_path = log_dir.join("install.log");

        let pid = std::process::id();
        let temp_dir = std::env::temp_dir().join(format!("omarchy-dotfiles-{pid}"));
        fs::create_dir_all(&temp_dir)?;

        Ok(Self { log_path, temp_dir })
    }

    /// Prepares the executable script path (local in scripts/ or extracted from embedded).
    fn prepare_script(&self, task: &Task) -> Result<PathBuf> {
        let local = Path::new("scripts").join(task.script_filename);
        if local.exists() {
            return Ok(local);
        }

        let temp_script = self.temp_dir.join(task.script_filename);
        fs::write(&temp_script, task.script_content)
            .with_context(|| format!("Failed to write embedded script {}", task.script_filename))?;

        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mut perms = fs::metadata(&temp_script)?.permissions();
            perms.set_mode(0o755);
            fs::set_permissions(&temp_script, perms)?;
        }

        Ok(temp_script)
    }

    /// Executes a single task, piping noisy stdout/stderr to disk and sending progress events.
    pub async fn run_task(&self, task: &Task, tx: mpsc::Sender<RunnerEvent>) -> Result<bool> {
        let script_path = self.prepare_script(task)?;
        let start_time = Instant::now();

        let _ = tx
            .send(RunnerEvent::TaskStarted {
                id: task.id.to_string(),
            })
            .await;
        self.write_log_header(task)?;

        let mut child = Command::new("bash")
            .arg(&script_path)
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .with_context(|| format!("Failed to spawn script {}", task.script_filename))?;

        let stdout = child
            .stdout
            .take()
            .ok_or_else(|| anyhow!("Failed to open stdout"))?;
        let stderr = child
            .stderr
            .take()
            .ok_or_else(|| anyhow!("Failed to open stderr"))?;

        let out_handle = spawn_stream_logger(
            stdout,
            tx.clone(),
            task.id.to_string(),
            self.log_path.clone(),
            "[out]",
        );
        let err_handle = spawn_stream_logger(
            stderr,
            tx.clone(),
            task.id.to_string(),
            self.log_path.clone(),
            "[err]",
        );

        let status = child.wait().await?;
        let _ = out_handle.await;
        let _ = err_handle.await;

        let duration = start_time.elapsed();
        let success = status.success();
        let error = if success {
            None
        } else {
            Some(format!("Exited with code {:?}", status.code()))
        };

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
            "\n=== [{}] Running: {} ({}) ===",
            time, task.name, task.script_filename
        )?;
        Ok(())
    }

    fn write_log_footer(&self, task: &Task, success: bool, duration: Duration) -> Result<()> {
        let mut f = OpenOptions::new().append(true).open(&self.log_path)?;
        let time = Local::now().format("%Y-%m-%d %H:%M:%S");
        writeln!(
            f,
            "=== [{}] Finished: {} (success: {}, duration: {:.2?}) ===",
            time, task.name, success, duration
        )?;
        Ok(())
    }
}

impl Drop for ProcessRunner {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.temp_dir);
    }
}

fn spawn_stream_logger<R>(
    reader: R,
    tx: mpsc::Sender<RunnerEvent>,
    task_id: String,
    log_path: PathBuf,
    prefix: &'static str,
) -> tokio::task::JoinHandle<()>
where
    R: tokio::io::AsyncRead + Unpin + Send + 'static,
{
    tokio::spawn(async move {
        let mut lines = BufReader::new(reader).lines();
        let mut log = OpenOptions::new().append(true).open(&log_path).ok();

        while let Ok(Some(line)) = lines.next_line().await {
            if let Some(ref mut f) = log {
                let _ = writeln!(f, "{prefix} {line}");
            }
            let clean = strip_ansi(&line);
            if !clean.is_empty() {
                let _ = tx
                    .send(RunnerEvent::TaskProgress {
                        id: task_id.clone(),
                        line: clean,
                    })
                    .await;
            }
        }
    })
}

fn strip_ansi(s: &str) -> String {
    let mut result = String::with_capacity(s.len());
    let mut in_escape = false;
    for c in s.chars() {
        if c == '\x1b' {
            in_escape = true;
        } else if in_escape {
            if c.is_ascii_alphabetic() {
                in_escape = false;
            }
        } else {
            result.push(c);
        }
    }
    result.trim().to_string()
}
