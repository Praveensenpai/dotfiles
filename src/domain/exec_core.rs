use anyhow::Result;
use std::path::PathBuf;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Executes a core task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "install_essential_apps" => install_essential_apps(tx).await,
        "install_jdk" => install_jdk(tx).await,
        "install_uv" => cmd::run_curl_bash("https://astral.sh/uv/install.sh", tx, id).await,
        "setup_android_sdk" => setup_android_sdk(),
        "setup_docker" => setup_docker(tx).await,
        "setup_editor" => setup_editor(),
        "setup_blesh" => setup_blesh(tx).await,
        "setup_cli_tools" => setup_cli_tools(tx).await,
        "setup_fzf_keybinds" => setup_fzf_keybinds(tx).await,
        "setup_git_config" => setup_git_config(tx).await,
        "setup_github_ssh" => setup_github_ssh(tx).await,
        "setup_zoxide" => setup_zoxide(tx).await,
        _ => Ok(()),
    }
}

async fn install_essential_apps(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(
        &[
            "mpv",
            "anki",
            "qbittorrent",
            "wget",
            "neovim",
            "firefox",
            "yazi",
            "zoxide",
            "rust",
        ],
        tx,
        "install_essential_apps",
    )
    .await
}

async fn install_jdk(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(&["jdk21-openjdk"], tx, "install_jdk").await?;
    let jconsole = home_dir().join(".local/share/applications/openjdk-21-jconsole.desktop");
    let jshel = home_dir().join(".local/share/applications/openjdk-21-jshell.desktop");
    fs_util::ensure_line(&jconsole, "NoDisplay=true")?;
    fs_util::ensure_line(&jshel, "NoDisplay=true")?;
    Ok(())
}

fn setup_android_sdk() -> Result<()> {
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "export ANDROID_HOME=$HOME/Android/Sdk")?;
    fs_util::ensure_line(
        &bashrc,
        "export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools",
    )?;
    Ok(())
}

async fn setup_docker(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_sudo(
        "systemctl",
        &["enable", "--now", "docker.socket"],
        tx,
        "setup_docker",
    )
    .await?;
    let user = std::env::var("USER").unwrap_or_else(|_| "paisen".to_string());
    cmd::run_sudo("usermod", &["-aG", "docker", &user], tx, "setup_docker").await
}

fn setup_editor() -> Result<()> {
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "export EDITOR=nvim")?;
    fs_util::ensure_line(&bashrc, "export VISUAL=nvim")?;
    Ok(())
}

async fn setup_blesh(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_curl_bash(
        "https://raw.githubusercontent.com/akinomyoga/ble.sh/master/ble.sh",
        tx,
        "setup_blesh",
    )
    .await?;
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(
        &bashrc,
        "[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh",
    )?;
    Ok(())
}

async fn setup_cli_tools(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(&["eza", "bat"], tx, "setup_cli_tools").await?;
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "alias ll='eza -la --icons'")?;
    fs_util::ensure_line(&bashrc, "alias ls='eza --icons'")?;
    fs_util::ensure_line(&bashrc, "alias cat='bat'")?;
    Ok(())
}

async fn setup_fzf_keybinds(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(&["fzf"], tx, "setup_fzf_keybinds").await?;
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "eval \"$(fzf --bash)\"")?;
    Ok(())
}

async fn setup_git_config(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run(
        "git",
        &["config", "--global", "init.defaultBranch", "main"],
        tx,
        "setup_git_config",
    )
    .await?;
    cmd::run(
        "git",
        &["config", "--global", "user.name", "Praveen Senpai"],
        tx,
        "setup_git_config",
    )
    .await?;
    cmd::run(
        "git",
        &["config", "--global", "user.email", "pvnt20@gmail.com"],
        tx,
        "setup_git_config",
    )
    .await
}

async fn setup_github_ssh(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_curl_bash(
        "https://raw.githubusercontent.com/Praveensenpai/github-ssh-key-setup/main/install.sh",
        tx,
        "setup_github_ssh",
    )
    .await
}

async fn setup_zoxide(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    cmd::run_pacman(&["zoxide"], tx, "setup_zoxide").await?;
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(&bashrc, "eval \"$(zoxide init bash)\"")?;
    Ok(())
}
