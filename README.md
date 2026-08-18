<div align="center">
  <img src="https://i.pinimg.com/originals/a0/6d/46/a06d460e5ff30e20ec42ea4ba127b140.gif" alt="Aesthetic Anime Banner" width="600"/>

  # 🌸 dotfiles ✨

  *My personal collection of cute, clean, and minimal configurations for an Arch-based (Omarchy) system.* 🎀
</div>

---

<br>

## 🍡 ⁺ . ⊹ Structure . ⁺ ☁️

Here's a little peek into how things are organized!

```text
dotfiles/
├── install.sh                          # The magic master script ✨
├── remote-install.sh                   # The one-liner magic script 🪄
└── scripts/
    ├── disable_bluetooth.sh            # No more annoying bluetooth on boot! 📶
    ├── disable_voxtype.sh              # Disables Voxtype service and dictation keybind 🎙️
    ├── install_anime4k.sh              # Makes videos look super pretty! 📺
    ├── install_antigravity_cli.sh      # Installs Antigravity CLI via official curl script 🚀
    ├── install_codex.sh                # Installs OpenAI Codex CLI package 🤖
    ├── install_essential_apps.sh       # Installs mpv, anki, qbittorrent, wget, neovim, firefox, yazi, zoxide, rust, & google-chrome 📦
    ├── install_jdk.sh                  # Installs OpenJDK 21 LTS & hides launcher entries ☕
    ├── install_uv.sh                   # Installs uv Python package manager via official installer 🐍
    ├── install_voicevox.sh             # VOICEVOX installer (disabled) 🎙️
    ├── install_wallpapers.sh           # Deploys custom wallpapers to active Omarchy theme 🖼️
    ├── remove_omarchy_preinstalls.sh   # Installs & runs omarchy-debloat Rust CLI tool 🗑️
    ├── set_alacritty_font_size.sh      # Sets Alacritty font size to 10 🔤
    ├── set_hyprland_gaps_and_borders.sh # Configures window gaps & border colors 🪟
    ├── set_hyprland_idle_and_keybinds.sh # Configures Hyprland idle timeouts & keybindings ⌨️
    ├── set_hyprland_monitor_scale.sh   # Sets monitor scale to 1.5 🖥️
    ├── set_mpv_lang.sh                 # Sets default mpv audio & subtitle languages 🔊
    ├── set_omarchy_shell_bar.sh        # Configures Omarchy 4 bar colors, System Resources widget & Japanese calendar 🎨
    ├── setup_mpv_resume.sh             # Enables saving playback position on quit in mpv ⏯️
    ├── setup_agym.sh                   # Deploys agym binary & sets up PATH/alias 👤
    ├── setup_arch_cleaner.sh           # Installs arch-cleaner package, log, & trash cleaner 🧹
    ├── setup_blesh.sh                  # Configures ble.sh for Bash live auto-suggestions 🎨
    ├── setup_cli_tools.sh              # Installs eza & bat for modern terminal icons & cat 📦
    ├── setup_cxm.sh                    # Installs the Codex account manager & switcher 🤖
    ├── setup_dns.sh                    # Configures persistent systemd-resolved DNS servers 🌐
    ├── setup_docker.sh                 # Enables docker.service/socket & adds user to docker group 🐳
    ├── setup_editor.sh                 # Sets EDITOR & VISUAL to neovim in shell configs ✏️
    ├── setup_fzf_keybinds.sh           # Configures fzf interactive fuzzy search shortcuts 🔍
    ├── setup_git_config.sh             # Configures global Git name/email with overwrite prompt ⚙️
    ├── setup_github_ssh.sh             # Generates Ed25519 SSH key & guides GitHub key setup 🔑
    ├── setup_mtu_fix.sh                # Applies and persists a NetworkManager MTU override 🔧
    ├── setup_otopod.sh                 # Installs otopod audio condenser for anime immersion 🎧
    ├── setup_subsink.sh                # Installs subsink automatic Japanese subtitle syncer ⛩️
    ├── setup_kotonoha.sh               # Installs kotonoha Japanese i+1 sentence miner 🌸
    ├── setup_mpd.sh                    # Installs MPD, generates mpd.conf, & enables user service 🎵
    ├── setup_tmux_resurrect.sh         # Configures TPM & tmux-resurrect auto-restore daemon 📟
    ├── setup_toss.sh                   # Installs toss (Rust TUI trash manager) 🗑️
    ├── setup_ufw.sh                    # Configures UFW firewall defaults & enables service 🛡️
    ├── setup_sys_chronicle.sh         # Installs sys-chronicle system activity logger & TUI dashboard ⏱️
    └── setup_zoxide.sh                 # Configures zoxide smart directory navigation 🚀
```

<br>

## ✨ ⁺ . ⊹ Quick Start . ⁺ 🍓

Ready to make things pretty with just one command? 🚀

### 🪄 The One-Liner Magic

Paste this into your terminal to clone and install everything automatically:

```bash
curl -LsSf -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Praveensenpai/dotfiles/main/remote-install.sh | bash
```

<br>

### 🧹 Standalone Interactive System Cleanup (No cloning required)

Run the interactive system cleanup directly via [`Praveensenpai/arch-cleaner`](https://github.com/Praveensenpai/arch-cleaner):

```bash
curl -LsSf -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh | bash
```

<br>

### 💌 Manual Setup

If you prefer doing things by hand:

```bash
git clone https://github.com/Praveensenpai/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

<br>

## 🎀 ⁺ . ⊹ Utility Scripts . ⁺ 🌸

| Script | What it does (*´▽`*) |
| :--- | :--- |
| `setup_arch_cleaner.sh` | Installs `arch-cleaner` via [`Praveensenpai/arch-cleaner`](https://github.com/Praveensenpai/arch-cleaner) to clean package cache, journal logs, and trash. |
| `disable_bluetooth.sh` | Disables bluetooth auto-power on boot. |
| `disable_voxtype.sh` | Disables `voxtype` systemd user service and dictation keybindings. |
| `install_anime4k.sh` | Downloads and configures Anime4K GLSL shaders for `mpv` via [`Praveensenpai/anime4k-mpv-installer`](https://github.com/Praveensenpai/anime4k-mpv-installer). |
| `install_antigravity_cli.sh` | Installs Antigravity CLI via `https://antigravity.google/cli/install.sh`. |
| `install_codex.sh` | Installs OpenAI Codex CLI (`openai-codex`) via `pacman` / `yay`. |
| `install_essential_apps.sh` | Installs essential software (`mpv`, `anki`, `qbittorrent`, `wget`, `neovim`, `firefox`, `yazi`, `zoxide`, `rust`, `google-chrome`). |
| `install_jdk.sh` | Installs `jdk21-openjdk` (LTS) via pacman, sets it as default with `archlinux-java`, and hides the JDK desktop entries from the launcher. |
| `install_uv.sh` | Installs `uv` Python package manager via the official Astral installer. Skips if already installed. |
| `install_voicevox.sh` | Fetches and installs VOICEVOX Japanese TTS engine (disabled). |
| `install_wallpapers.sh` | Deploys custom wallpapers from `dotfiles/wallpapers/` to active Omarchy theme background directory. |
| `remove_omarchy_preinstalls.sh` | Purges default DHH/Omarchy bloatware via [`Praveensenpai/omarchy-debloat`](https://github.com/Praveensenpai/omarchy-debloat). |
| `set_alacritty_font_size.sh` | Sets Alacritty terminal font size to 10. |
| `set_hyprland_gaps_and_borders.sh` | Sets Hyprland inner/outer gaps to 0 and configures active/inactive border colors. |
| `set_hyprland_idle_and_keybinds.sh` | Configures Hyprland idle timeouts and applies the configured keybindings. |
| `set_hyprland_monitor_scale.sh` | Configures Hyprland monitor resolution and scale to 1.5. |
| `set_mpv_lang.sh` | Sets default audio & subtitle language priorities in `mpv.conf`. |
| `setup_mpv_resume.sh` | Enables saving playback position on quit in `mpv.conf`. |
| `set_omarchy_shell_bar.sh` | Configures live Quickshell bar widgets (battery, Bluetooth, Wi-Fi, audio, Japanese date/calendar, and System Resources CPU/RAM widget). |
| `setup_blesh.sh` | Configures `ble.sh` for Bash live auto-suggestions. |
| `setup_cli_tools.sh` | Installs `eza` and `bat` for modern icons, colors, and syntax-highlighted `cat`. |
| `setup_cxm.sh` | Installs `cxm`, the Codex account manager and account switcher, from GitHub. |
| `setup_dns.sh` | Configures persistent Cloudflare, Quad9, and Google DNS servers through `systemd-resolved`. |
| `setup_docker.sh` | Enables `docker.service` and `docker.socket`, adds current user to `docker` group. Skips gracefully if already configured. |
| `setup_editor.sh` | Sets `EDITOR=nvim` and `VISUAL=nvim` in `~/.bashrc` if not already configured. |
| `setup_fzf_keybinds.sh` | Configures `fzf` interactive fuzzy search shortcuts (`Ctrl+R`, `Ctrl+T`). |
| `setup_git_config.sh` | Sets global `user.name` and `user.email` defaults, with an overwrite confirmation prompt if credentials exist. |
| `setup_github_ssh.sh` | Generates Ed25519 SSH key & setup via [`Praveensenpai/github-ssh-key-setup`](https://github.com/Praveensenpai/github-ssh-key-setup). |
| `setup_mtu_fix.sh` | Applies an MTU immediately and creates a NetworkManager dispatcher hook to reapply it after reconnects. Defaults to `wlan0` and MTU `1400`; accepts `<interface> <mtu>`. |
| `setup_toss.sh` | Installs `toss` via [`Praveensenpai/toss-rs`](https://github.com/Praveensenpai/toss-rs) and configures shell completions & alias. |
| `setup_ufw.sh` | Configures UFW with sensible defaults (deny incoming, allow outgoing, allow SSH) and enables it. |
| `setup_vnstat_service.sh` | Installs `vnstat` network traffic monitor and enables `vnstat.service` systemd daemon. |
| `setup_zoxide.sh` | Configures `zoxide` smart directory navigation (`z` / `cd`). |
| `setup_otopod.sh` | Installs `otopod` anime audio condenser via [`Praveensenpai/otopod`](https://github.com/Praveensenpai/otopod). |
| `setup_subsink.sh` | Installs `subsink` Japanese subtitle synchronizer via [`Praveensenpai/subsink`](https://github.com/Praveensenpai/subsink). |
| `setup_kotonoha.sh` | Installs `kotonoha` Japanese $i+1$ sentence miner via [`Praveensenpai/kotonoha`](https://github.com/Praveensenpai/kotonoha). |
| `setup_tmux_resurrect.sh` | Configures TPM, tmux-resurrect/continuum, & systemd user daemon via [`Praveensenpai/tmux-resurrect-systemd`](https://github.com/Praveensenpai/tmux-resurrect-systemd). |
| `setup_agym.sh` | Installs `agym` from GitHub (`Praveensenpai/agym`) & configures shell environment. |
| `setup_mpd.sh` | Installs MPD (Music Player Daemon), generates default user `~/.config/mpd/mpd.conf`, and enables/starts `mpd` systemd user service. |
| `setup_ototune.sh` | Installs `ototune` minimal Rust TUI MPD player tailored for audio immersion. |
| `setup_sys_chronicle.sh` | Installs `sys-chronicle` system activity logger & TUI dashboard via [`Praveensenpai/sys-chronicle`](https://github.com/Praveensenpai/sys-chronicle). |

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
