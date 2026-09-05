use anyhow::{bail, Context, Result};
use std::process::Command;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

/// Warms up sudo by prompting for credentials before terminal alternate screen.
pub fn warmup() -> Result<()> {
    println!("\x1b[1;35m🌸 ========================================= 🌸\x1b[0m");
    println!("\x1b[1m        Omarchy Dotfiles Setup (Rust)         \x1b[0m");
    println!("\x1b[1;35m🌸 ========================================= 🌸\x1b[0m\n");
    println!("\x1b[1;33m🔒 Sudo authentication required to proceed:\x1b[0m");

    let status = Command::new("sudo")
        .arg("-v")
        .status()
        .context("Failed to execute sudo -v")?;

    if !status.success() {
        bail!("Sudo authentication failed or was cancelled.");
    }

    Ok(())
}

/// Spawns a background task that keeps the sudo timestamp alive every 45s.
pub fn spawn_keepalive(running: Arc<AtomicBool>) {
    tokio::spawn(async move {
        while running.load(Ordering::Relaxed) {
            sleep(Duration::from_secs(45)).await;
            if !running.load(Ordering::Relaxed) {
                break;
            }
            let _ = Command::new("sudo").args(["-n", "true"]).output();
        }
    });
}
