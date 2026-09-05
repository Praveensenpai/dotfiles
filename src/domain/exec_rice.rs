use anyhow::Result;
use std::path::PathBuf;
use tokio::sync::mpsc;

use crate::infra::cmd;
use crate::infra::fs_util;
use crate::infra::runner::RunnerEvent;

fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Executes a rice task by its unique task ID.
pub async fn execute(id: &str, tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    match id {
        "install_wallpapers" => install_wallpapers(),
        "setup_japanese_ime" => cmd::run_curl_bash(
            "https://raw.githubusercontent.com/Praveensenpai/paisen.japanese-ime/main/install.sh",
            tx,
            id,
        )
        .await,
        "setup_omo_anitrack" => {
            cmd::run_curl_bash(
                "https://raw.githubusercontent.com/Praveensenpai/omo-anitrack/main/install.sh",
                tx,
                id,
            )
            .await
        }
        "setup_starship" => setup_starship(tx).await,
        _ => Ok(()),
    }
}

fn install_wallpapers() -> Result<()> {
    let wallpapers_src = std::path::Path::new("wallpapers");
    if !wallpapers_src.exists() {
        return Ok(());
    }
    let target_dir = home_dir().join(".config/omarchy/current/theme/backgrounds");
    let state_dir = home_dir().join(".local/state/omarchy/current/theme/backgrounds");
    std::fs::create_dir_all(&target_dir)?;
    if home_dir()
        .join(".local/state/omarchy/current/theme")
        .exists()
    {
        std::fs::create_dir_all(&state_dir)?;
    }

    if let Ok(entries) = std::fs::read_dir(wallpapers_src) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(file_name) = path.file_name() {
                    let _ = std::fs::copy(&path, target_dir.join(file_name));
                    let _ = std::fs::copy(&path, state_dir.join(file_name));
                }
            }
        }
    }
    Ok(())
}

async fn setup_starship(tx: &mpsc::Sender<RunnerEvent>) -> Result<()> {
    let _ = cmd::run_pacman(&["starship"], tx, "setup_starship").await;
    let starship_config = home_dir().join(".config/starship.toml");
    let config_content = r#"add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status$rust$python$docker_context]($style)$character"

[character]
error_symbol = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$symbol$branch]($style) "
symbol = " "
style = "italic cyan"

[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""

[rust]
format = "[$symbol($version )]($style)"
symbol = "󱘗 "
style = "bold red"

[python]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold yellow"

[docker_context]
format = "[$symbol$context]($style) "
symbol = " "
style = "bold blue"
"#;
    fs_util::write_file(&starship_config, config_content)?;
    let bashrc = home_dir().join(".bashrc");
    fs_util::ensure_line(
        &bashrc,
        "if command -v starship &> /dev/null; then eval \"$(starship init bash)\"; fi",
    )?;
    Ok(())
}
