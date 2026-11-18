use anyhow::Result;
use std::path::{Path, PathBuf};
use tokio::sync::mpsc;

use crate::domain::anime4k_assets::{INPUT_CONF, MPV_CONF, SHADERS};
use crate::infra::cmd;
use crate::infra::env_util::{config_dir, home_dir};
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

/// Executes a media task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "install_anime4k" => install_anime4k(),
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

const BLOCK_START: &str = "# >>> anime4k-managed-start >>>";
const BLOCK_END: &str = "# <<< anime4k-managed-end <<<";

fn mpv_dir() -> PathBuf {
    std::env::var_os("MPV_HOME").map_or_else(|| config_dir().join("mpv"), PathBuf::from)
}

fn managed_block(source: &str) -> &str {
    let start = source.find(BLOCK_START).unwrap_or(0);
    let end = source
        .find(BLOCK_END)
        .map_or(source.len(), |idx| idx + BLOCK_END.len());
    &source[start..end]
}

fn patch_conf(path: &Path, block: &str) -> Result<()> {
    let existing = std::fs::read_to_string(path).unwrap_or_default();
    let updated = fs_util::replace_managed_block(&existing, BLOCK_START, BLOCK_END, block);
    if updated != existing {
        fs_util::write_file(path, &updated)?;
    }
    Ok(())
}

fn install_anime4k_at(root: &std::path::Path) -> Result<()> {
    let shaders: Vec<(&str, &str, bool)> = SHADERS
        .iter()
        .map(|(name, body)| (*name, *body, false))
        .collect();
    fs_util::deploy_assets(&root.join("shaders"), &shaders)?;
    patch_conf(&root.join("input.conf"), INPUT_CONF.trim_end())?;
    patch_conf(&root.join("mpv.conf"), managed_block(MPV_CONF))
}

fn install_anime4k() -> Result<()> {
    install_anime4k_at(&mpv_dir())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn managed_block_is_extracted_from_bundled_conf() {
        let block = managed_block(MPV_CONF);
        assert!(block.starts_with(BLOCK_START));
        assert!(block.ends_with(BLOCK_END));
        assert!(block.contains("glsl-shaders="));
    }

    #[test]
    fn patching_managed_block_is_idempotent() {
        let block = managed_block(MPV_CONF);
        let once = fs_util::replace_managed_block("vo=gpu\n", BLOCK_START, BLOCK_END, block);
        let twice = fs_util::replace_managed_block(&once, BLOCK_START, BLOCK_END, block);
        assert_eq!(once, twice);
    }

    #[test]
    fn anime4k_install_deploys_shaders_and_config() {
        let dir = fs_util::test_dir("anime4k");
        assert!(install_anime4k_at(&dir).is_ok());
        assert_eq!(
            std::fs::read_dir(dir.join("shaders")).map_or(0, Iterator::count),
            SHADERS.len()
        );
        let conf = std::fs::read_to_string(dir.join("mpv.conf")).unwrap_or_default();
        assert!(conf.contains(BLOCK_START));
        assert!(conf.contains("glsl-shaders="));

        assert!(install_anime4k_at(&dir).is_ok());
        let again = std::fs::read_to_string(dir.join("mpv.conf")).unwrap_or_default();
        assert_eq!(conf, again);
        let _ = std::fs::remove_dir_all(&dir);
    }
}
