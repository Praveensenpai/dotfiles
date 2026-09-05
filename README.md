<div align="center">
  <img src="https://i.pinimg.com/originals/a0/6d/46/a06d460e5ff30e20ec42ea4ba127b140.gif" alt="Aesthetic Anime Banner" width="600"/>

  # 🌸 dotfiles ✨

  *My personal collection of cute, clean, and minimal configurations for an Arch-based (Omarchy) system.* 🎀
</div>

---

<br>

## 🍡 ⁺ . ⊹ Structure . ⁺ ☁️

Here's a peek into how the modern Rust codebase is organized!

```text
dotfiles/
├── Cargo.toml                          # Rust crate definition & dependencies
├── RULES.md                            # Hard rules (max lines, complexity, zero-unwrap)
├── remote-install.sh                   # The one-liner magic script (fetches Rust binary) 🪄
├── src/
│   ├── main.rs                         # Entry point & terminal setup
│   ├── app.rs                          # App state & interactive event loop
│   ├── cli.rs                          # CLI argument parsing
│   ├── domain.rs                       # Domain module declarations
│   ├── domain/
│   │   ├── catalog.rs                  # All 47 installation tasks catalog
│   │   ├── task.rs                     # Task, Category, and TaskStatus models
│   │   ├── executor.rs                 # Central task runner & dispatcher
│   │   ├── exec_core.rs                # 12 core native Rust installers
│   │   ├── exec_desktop.rs             # 8 desktop & window manager installers
│   │   ├── exec_shell_bar.rs           # Quickshell bar & widgets configuration
│   │   ├── exec_rice.rs                # 4 aesthetic & theming installers
│   │   ├── exec_media.rs               # 9 media & anime immersion installers
│   │   ├── exec_tools.rs               # 12 modern CLI tools installers
│   │   └── exec_maint.rs               # System maintenance & cleaner installers
│   ├── infra.rs                        # Infrastructure module declarations
│   ├── infra/
│   │   ├── cmd.rs                      # Subprocess runner with clean stdout/stderr streaming
│   │   ├── fs_util.rs                  # File and directory utilities
│   │   ├── runner.rs                   # Multi-task background worker engine
│   │   └── sudo.rs                     # Sudo keep-alive & credential check
│   ├── ui.rs                           # UI module declarations
│   └── ui/
│       ├── theme.rs                    # Pastel sakura & matcha color palette
│       ├── header.rs                   # Aesthetic ASCII banner & status headers
│       ├── selection_view.rs           # Interactive task & category selector
│       ├── running_view.rs             # Progress gauges, spinning spinners, & task progress
│       └── log_drawer.rs               # Expandable real-time log drawer (toggle with 'l')
└── wallpapers/                         # Curated aesthetic wallpapers 🖼️
```

<br>

## ✨ ⁺ . ⊹ Quick Start . ⁺ 🍓

Ready to make things pretty with just one command? 🚀

### 🪄 The One-Liner Magic

Paste this into your terminal to download and run the standalone Rust installer:

```bash
curl -LsSf -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Praveensenpai/dotfiles/main/remote-install.sh | bash
```

<br>

### 💌 Manual Build & Run

If you prefer building and running from source:

```bash
git clone https://github.com/Praveensenpai/dotfiles.git ~/dotfiles
cd ~/dotfiles
cargo run --release
```

Or use CLI flags:

```bash
# Run all default tasks immediately
./target/release/omarchy-dotfiles --all

# List all available tasks and exit
./target/release/omarchy-dotfiles --list

# Simulate execution (dry-run mode)
./target/release/omarchy-dotfiles --dry-run
```

<br>

### 🧹 Standalone Interactive System Cleanup

Run the interactive system cleanup directly via [`Praveensenpai/arch-cleaner`](https://github.com/Praveensenpai/arch-cleaner):

```bash
curl -LsSf -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh | bash
```

<br>

## 🎀 ⁺ . ⊹ Native Installation Tasks . ⁺ 🌸

All 47 tasks are written in 100% native Rust logic with automated logging to `install.log` and live terminal drawer inspection:

| Task ID | Category | What it does (*´▽`*) |
| :--- | :--- | :--- |
| `setup_dns` | Core | Configures persistent Cloudflare, Quad9, and Google DNS servers via `systemd-resolved`. |
| `setup_mtu_fix` | Core | Applies MTU and creates NetworkManager dispatcher hook. |
| `setup_ufw` | Core | Configures UFW with sensible defaults (deny in, allow out, allow SSH) and enables service. |
| `setup_tcp_keepalive` | Core | Sets persistent TCP keepalive sysctl configurations. |
| `install_essential_apps` | Core | Installs essential software (`mpv`, `anki`, `qbittorrent`, `wget`, `neovim`, `firefox`, `yazi`, `zoxide`, `rust`, `google-chrome`). |
| `install_jdk` | Core | Installs OpenJDK 21 LTS, sets default via `archlinux-java`, and hides desktop entries. |
| `install_uv` | Core | Installs Astral `uv` Python package manager via official installer. |
| `setup_docker` | Core | Configures `docker.service`/`socket` and adds user to docker group. |
| `setup_editor` | Core | Sets `EDITOR=nvim` and `VISUAL=nvim` in shell configs. |
| `setup_git_config` | Core | Sets global Git name/email defaults. |
| `setup_github_ssh` | Core | Generates Ed25519 SSH key & sets up GitHub SSH authentication. |
| `setup_japanese_ime` | Core | Installs and configures Fcitx5 with Mozc for Japanese input. |
| `remove_omarchy_preinstalls`| Desktop | Purges default bloatware via [`omarchy-debloat`](https://github.com/Praveensenpai/omarchy-debloat). |
| `disable_bluetooth` | Desktop | Disables bluetooth auto-power on boot. |
| `disable_voxtype` | Desktop | Disables `voxtype` systemd user service and dictation keybinds. |
| `set_alacritty_font_size` | Desktop | Sets Alacritty terminal font size to 10. |
| `set_hyprland_gaps_and_borders` | Desktop | Sets Hyprland inner/outer gaps to 0 and custom border colors. |
| `set_hyprland_idle_and_keybinds` | Desktop | Configures Hyprland idle timeouts and keybindings. |
| `set_hyprland_monitor_scale` | Desktop | Configures Hyprland monitor resolution and scale. |
| `setup_omarchy_refined_menu`| Desktop | Configures refined, aesthetic application launcher menu. |
| `install_wallpapers` | Rice | Deploys custom wallpapers to active Omarchy theme directory. |
| `setup_starship` | Rice | Configures Starship prompt with Nerd Font symbols & language modules. |
| `setup_blesh` | Rice | Configures `ble.sh` for Bash live syntax highlighting & auto-suggestions. |
| `set_omarchy_shell_bar` | Rice | Configures live Quickshell bar widgets, Japanese calendar & System Resources monitor. |
| `install_anime4k` | Media | Downloads and configures Anime4K GLSL shaders for `mpv`. |
| `set_mpv_lang` | Media | Sets default Japanese audio & English subtitle priorities in `mpv.conf`. |
| `setup_mpv_resume` | Media | Enables saving playback position on quit in `mpv.conf`. |
| `setup_mpv_youtube` | Media | Configures yt-dlp high quality streaming playback in `mpv`. |
| `setup_mpd` | Media | Installs MPD, generates user `mpd.conf`, and enables user service. |
| `setup_ototune` | Media | Installs `ototune` minimal aesthetic Rust TUI MPD player. |
| `setup_otopod` | Media | Installs `otopod` anime audio condenser tool for language immersion. |
| `setup_subsink` | Media | Installs `subsink` automatic Japanese subtitle synchronizer. |
| `setup_kotonoha` | Media | Installs `kotonoha` Japanese $i+1$ sentence miner. |
| `setup_omo_anitrack` | Media | Installs `omo-anitrack` anime episode tracking utility. |
| `setup_cli_tools` | Tools | Installs `eza` and `bat` for modern icons, colors, and syntax-highlighted `cat`. |
| `setup_zoxide` | Tools | Configures `zoxide` smart directory navigation (`z`). |
| `setup_fzf_keybinds` | Tools | Configures `fzf` interactive fuzzy search shortcuts (`Ctrl+R`, `Ctrl+T`). |
| `setup_toss` | Tools | Installs `toss` Rust TUI trash manager with shell completions & alias. |
| `setup_vnstat_service` | Tools | Installs `vnstat` network monitor and enables `vnstat.service`. |
| `setup_tmux_resurrect` | Tools | Configures TPM, tmux-resurrect/continuum, & auto-restore daemon. |
| `setup_agym` | Tools | Installs `agym` Antigravity manager & configures shell environment. |
| `setup_cxm` | Tools | Installs `cxm` Codex account manager & switcher. |
| `install_antigravity_cli` | Tools | Installs official Google Antigravity CLI. |
| `install_codex` | Tools | Installs OpenAI Codex CLI package. |
| `setup_sys_chronicle` | Tools | Installs `sys-chronicle` system activity logger & TUI dashboard. |
| `setup_arch_cleaner` | Maintenance | Installs `arch-cleaner` package, log, & trash cleanup utility. |

<br>

<br>

## 🛠️ ⁺ . ⊹ Custom CLI Tools & Features . ⁺ ✨

Here are special standalone tools included in this repository to enhance your terminal workflow:

| Tool | Command | Description |
| :--- | :--- | :--- |
| 🎵 **ototune** | `ototune` | Minimal aesthetic Rust TUI MPD player tailored for audio immersion & daily playback. |
| 🚀 **Antigravity Manager** | `agym` | Unified CLI tool combining session picker (`agym`), account switcher (`agym accounts`), and quota stats (`agym stats`). |
| ⏱️ **System Activity Chronicle** | `sys-chronicle` | System activity, power state, & resource load logger with AI markdown exporter & Ratatui TUI (`Praveensenpai/sys-chronicle`). |
| 🧹 **System Cleaner** | `arch-cleaner` | Interactive Arch Linux package cache, systemd journal log, and trash cleanup utility (`Praveensenpai/arch-cleaner`). |
| 🎧 **otopod** | `otopod` | Anime audio condenser tool for language immersion ([`Praveensenpai/otopod`](https://github.com/Praveensenpai/otopod)). |
| ⛩️ **subsink** | `subsink` | Automatic Japanese anime subtitle synchronizer ([`Praveensenpai/subsink`](https://github.com/Praveensenpai/subsink)). |
| 🌸 **kotonoha** | `kotonoha` | Blazing-fast CLI Japanese $i+1$ sentence miner ([`Praveensenpai/kotonoha`](https://github.com/Praveensenpai/kotonoha)). |

<br>

## ⚡ ⁺ . ⊹ Enhanced Shell & Terminal Utilities . ⁺ 🌸

Modern CLI enhancements integrated into your shell environment:

| Tool | Feature | Description |
| :--- | :--- | :--- |
| 🎨 **`ble.sh`** | Bash Line Editor | Live syntax highlighting (green/red) and auto-suggestions (gray text) in Bash. |
| 🚀 **`zoxide`** | Smart Navigation | `z <folder>` jumps instantly to your most visited directories without full paths. |
| 📂 **`eza`** | Modern `ls` | Color-coded directory listings with file type icons and group-first layout. |
| 📄 **`bat`** | Modern `cat` | Syntax-highlighted file viewing with automatic line numbers & paging. |
| 🔍 **`fzf`** | Fuzzy Search | Interactive fuzzy history search (`Ctrl+R`) and file selection (`Ctrl+T`). |
| 🗑️ **`toss`** | Safe Deletion | FreeDesktop Rust TUI trash manager ([`Praveensenpai/toss-rs`](https://github.com/Praveensenpai/toss-rs)). |
| 📊 **`vnstat`** | Traffic Monitor | Background daemon logging hourly, daily, and monthly network bandwidth usage. |
| 📟 **`tmux`** | Session Resurrect | Terminal multiplexer with auto-save & auto-restore across reboots. |

<br>

<div align="center">
  Made with 💖 by Praveen
</div>
