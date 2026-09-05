use anyhow::Result;
use std::path::PathBuf;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Executes a media task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "install_anime4k" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/anime4k-cli/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "set_mpv_lang" => set_mpv_lang(),
        "setup_kotonoha" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/kotonoha/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "setup_mpd" => setup_mpd(tx).await,
        "setup_mpv_resume" => setup_mpv_resume(),
        "setup_mpv_youtube" => setup_mpv_youtube(),
        "setup_otopod" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/otopod/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "setup_ototune" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/ototune/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "setup_subsink" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/subsink/main/install.sh",
                tx,
                id,
            )
            .await
        }
        _ => Ok(()),
    }
}

fn set_mpv_lang() -> Result<()> {
    let mpv_conf = home_dir().join(".config/mpv/mpv.conf");
    fs_util::ensure_line(&mpv_conf, "alang=jpn,jp,ja,japanese")?;
    fs_util::ensure_line(&mpv_conf, "slang=enm,eng,en")?;
    Ok(())
}

fn setup_mpv_resume() -> Result<()> {
    let mpv_conf = home_dir().join(".config/mpv/mpv.conf");
    fs_util::ensure_line(&mpv_conf, "save-position-on-quit=yes")?;
    Ok(())
}

fn setup_mpv_youtube() -> Result<()> {
    let mpv_conf = home_dir().join(".config/mpv/mpv.conf");
    fs_util::ensure_line(
        &mpv_conf,
        "ytdl-format=bestvideo[height<=?1080]+bestaudio/best",
    )?;
    Ok(())
}

async fn setup_mpd(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let _ = cmd::run_pacman(&["mpd"], tx, "setup_mpd").await;
    let mpd_dir = home_dir().join(".config/mpd");
    let mpd_conf = mpd_dir.join("mpd.conf");
    let content = r#"music_directory    "~/Music"
playlist_directory "~/.local/share/mpd/playlists"
db_file            "~/.local/share/mpd/database"
log_file           "syslog"
pid_file           "~/.local/share/mpd/pid"
state_file         "~/.local/share/mpd/state"
sticker_file       "~/.local/share/mpd/sticker.sql"

auto_update "yes"

audio_output {
    type "pipewire"
    name "PipeWire Sound Server"
}
"#;
    fs_util::write_file(&mpd_conf, content)?;
    let _ = cmd::run(
        "systemctl",
        &["--user", "enable", "--now", "mpd"],
        tx,
        "setup_mpd",
    )
    .await;
    Ok(())
}
