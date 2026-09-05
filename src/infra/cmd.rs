use anyhow::{anyhow, Context, Result};
use std::fs::OpenOptions;
use std::io::Write;
use std::path::PathBuf;
use std::process::Stdio;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use tokio::sync::mpsc;

use crate::infra::runner::RunnerEvent;

fn get_log_path() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(".local/state/omarchy-dotfiles/install.log")
}

/// Executes an external command silently, streaming logs to disk and emitting progress events.
pub async fn run(
    program: &str,
    args: &[&str],
    tx: &mpsc::Sender<RunnerEvent>,
    task_id: &str,
) -> Result<()> {
    let mut child = Command::new(program)
        .args(args)
        .current_dir(std::env::temp_dir())
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .with_context(|| format!("Failed to spawn {program}"))?;

    let stdout = child
        .stdout
        .take()
        .ok_or_else(|| anyhow!("Failed stdout"))?;
    let stderr = child
        .stderr
        .take()
        .ok_or_else(|| anyhow!("Failed stderr"))?;

    let log_path = get_log_path();
    let out_h = spawn_logger(stdout, tx.clone(), task_id.to_string(), log_path.clone());
    let err_h = spawn_logger(stderr, tx.clone(), task_id.to_string(), log_path);

    let status = child.wait().await?;
    let _ = out_h.await;
    let _ = err_h.await;

    if status.success() {
        Ok(())
    } else {
        Err(anyhow!("{program} exited with code {:?}", status.code()))
    }
}

/// Executes a command with elevated privileges using sudo.
pub async fn run_sudo(
    program: &str,
    args: &[&str],
    tx: &mpsc::Sender<RunnerEvent>,
    task_id: &str,
) -> Result<()> {
    let mut full_args = vec![program];
    full_args.extend_from_slice(args);
    run("sudo", &full_args, tx, task_id).await
}

/// Downloads and executes a remote bash installer script silently in a clean session.
pub async fn run_curl_bash(url: &str, tx: &mpsc::Sender<RunnerEvent>, task_id: &str) -> Result<()> {
    let cmd =
        format!("cd /tmp && curl -4 -fsSL -H 'Cache-Control: no-cache' \"{url}\" | setsid bash");
    run("bash", &["-c", &cmd], tx, task_id).await
}

/// Downloads and executes a remote bash installer script with arguments silently.
pub async fn run_curl_bash_args(
    url: &str,
    script_args: &str,
    tx: &mpsc::Sender<RunnerEvent>,
    task_id: &str,
) -> Result<()> {
    let cmd = format!(
        "cd /tmp && curl -4 -fsSL -H 'Cache-Control: no-cache' \"{url}\" | setsid bash -s -- {script_args}"
    );
    run("bash", &["-c", &cmd], tx, task_id).await
}

/// Checks whether a command is installed and executable in PATH.
pub async fn command_exists(name: &str) -> bool {
    Command::new("which")
        .arg(name)
        .output()
        .await
        .is_ok_and(|o| o.status.success())
}

/// Installs Arch Linux packages via pacman if they are not already installed.
pub async fn run_pacman(
    packages: &[&str],
    tx: &mpsc::Sender<RunnerEvent>,
    task_id: &str,
) -> Result<()> {
    let mut args = vec!["-S", "--needed", "--noconfirm"];
    args.extend_from_slice(packages);
    run_sudo("pacman", &args, tx, task_id).await
}

fn spawn_logger<R>(
    reader: R,
    tx: mpsc::Sender<RunnerEvent>,
    task_id: String,
    log_path: PathBuf,
) -> tokio::task::JoinHandle<()>
where
    R: tokio::io::AsyncRead + Unpin + Send + 'static,
{
    tokio::spawn(async move {
        let mut lines = BufReader::new(reader).lines();
        let mut log = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&log_path)
            .ok();

        while let Ok(Some(line)) = lines.next_line().await {
            if let Some(ref mut f) = log {
                let _ = writeln!(f, "{line}");
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
