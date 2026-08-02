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
    ├── agym                            # Unified Antigravity CLI session & account manager 🚀
    ├── clean_system_cache.sh           # Interactive menu to clean pacman cache, logs, & trash 🧹
    ├── disable_bluetooth.sh            # No more annoying bluetooth on boot! 📶
    ├── install_anime4k.sh              # Makes videos look super pretty! 📺
    ├── install_antigravity_cli.sh      # Installs Antigravity CLI via official curl script 🚀
    ├── install_essential_apps.sh       # Installs mpv, anki, qbittorrent, wget, neovim, firefox, yazi, & google-chrome 📦
    ├── install_uv.sh                   # Installs uv Python package manager via official installer 🐍
    ├── install_voicevox.sh             # Fetches latest VOICEVOX release & creates desktop entry 🎙️
    ├── install_wallpapers.sh           # Deploys custom wallpapers to active Omarchy theme 🖼️
    ├── remove_omarchy_preinstalls.sh   # Purges default Omarchy/DHH packages, web apps, & stubs 🗑️
    ├── set_alacritty_font_size.sh      # Sets Alacritty font size to 10 🔤
    ├── set_hyprland_gaps_and_borders.sh# Configures window gaps & border colors 🪟
    ├── set_hyprland_monitor_scale.sh   # Sets monitor scale to 1.5 🖥️
    ├── set_mpv_lang.sh                 # Sets default mpv audio & subtitle languages 🔊
    ├── set_waybar_battery_colors.sh    # Dynamic state colors for battery 🔋
    ├── set_waybar_bluetooth_colors.sh  # State colors for Bluetooth indicator 󰂯
    ├── set_waybar_config.sh            # Deploys Waybar config.jsonc layout ⚙️
    ├── set_waybar_japanese_clock.sh    # Enables ja_JP locale & Japanese clock 🎌
    ├── set_waybar_network_speed.sh     # Network download/upload speed indicator & tooltips 🌐
    ├── set_waybar_style.sh             # Deploys Waybar style.css theme 🎨
    ├── set_waybar_tray_expander.sh     # Dynamic tray expander icon helper 🪶
    ├── set_waybar_wifi_colors.sh       # State colors for Wi-Fi indicator 󰤨
    ├── setup_agym.sh                   # Deploys agym binary & sets up PATH/alias 👤
    ├── setup_blesh.sh                  # Configures ble.sh for Bash live auto-suggestions 🎨
    ├── setup_cli_tools.sh              # Installs eza & bat for modern terminal icons & cat 📦
    ├── setup_docker.sh                 # Enables docker.service/socket & adds user to docker group 🐳
    ├── setup_editor.sh                 # Sets EDITOR & VISUAL to neovim in shell configs ✏️
    ├── setup_fzf_keybinds.sh           # Configures fzf interactive fuzzy search shortcuts 🔍
    ├── setup_git_config.sh             # Configures global Git name/email with overwrite prompt ⚙️
    ├── setup_github_ssh.sh             # Generates Ed25519 SSH key & guides GitHub key setup 🔑
    ├── setup_immersionpod.sh           # Configures MPD & ImmersionPod for audio language immersion 🎧
    ├── setup_tmux_resurrect.sh         # Configures TPM & tmux-resurrect auto-restore daemon 📟
    ├── setup_trash_cli_alias.sh        # Replaces rm with safe trash-cli (trash-put) 🗑️
    ├── setup_ufw.sh                    # Configures UFW firewall defaults & enables service 🛡️
    ├── setup_vnstat_service.sh         # Installs & enables vnstat data tracking daemon 📊
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

Run the interactive system cleanup directly without keeping or cloning dotfiles:

```bash
curl -LsSf -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Praveensenpai/dotfiles/main/scripts/clean_system_cache.sh | bash
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
| `clean_system_cache.sh` | Cleans Arch package cache, systemd journal logs, and trash. |
| `disable_bluetooth.sh` | Disables bluetooth auto-power on boot. |
| `install_anime4k.sh` | Downloads and configures Anime4K GLSL shaders for `mpv` via [`Praveensenpai/anime4k-mpv-installer`](https://github.com/Praveensenpai/anime4k-mpv-installer). |
| `install_antigravity_cli.sh` | Installs Antigravity CLI via `https://antigravity.google/cli/install.sh`. |
| `install_essential_apps.sh` | Installs essential software (`mpv`, `anki`, `qbittorrent`, `wget`, `neovim`, `firefox`, `yazi`, `zoxide`, `google-chrome`). |
| `install_uv.sh` | Installs `uv` Python package manager via the official Astral installer. Skips if already installed. |
| `install_voicevox.sh` | Fetches latest VOICEVOX release from GitHub, extracts to `~/.local/share/voicebox`, and installs desktop entry. |
| `install_wallpapers.sh` | Deploys custom wallpapers from `dotfiles/wallpapers/` to active Omarchy theme background directory. |
| `remove_omarchy_preinstalls.sh` | Purges default DHH/Omarchy packages (Chromium, LocalSend, Spotify, 1Password, Obsidian, Typora, etc.), web apps, and NPX stubs. |
| `set_alacritty_font_size.sh` | Sets Alacritty terminal font size to 10. |
| `set_hyprland_gaps_and_borders.sh` | Sets Hyprland inner/outer gaps to 0 and configures active/inactive border colors. |
| `set_hyprland_monitor_scale.sh` | Configures Hyprland monitor resolution and scale to 1.5. |
| `set_mpv_lang.sh` | Sets default audio & subtitle language priorities in `mpv.conf`. |
| `set_waybar_battery_colors.sh` | Sets battery icon colors for all charge levels (100% green). |
| `set_waybar_bluetooth_colors.sh` | Sets Waybar Bluetooth colors (connected green, on orange, off grey). |
| `set_waybar_config.sh` | Configures Waybar `config.jsonc` modules and layout. |
| `set_waybar_japanese_clock.sh` | Enables system `ja_JP.UTF-8` locale and sets Japanese date/time in Waybar (`土曜日 01:59`). |
| `set_waybar_network_speed.sh` | Configures network download/upload bandwidth speed display (`󰇚 46.0kB/s  󰕒 3.9kB/s`) and hover tooltips. |
| `set_waybar_style.sh` | Configures Waybar base CSS styles. |
| `set_waybar_tray_expander.sh` | Deploys dynamic tray expander arrow icon helper. |
| `set_waybar_wifi_colors.sh` | Sets Waybar Wi-Fi colors (connected green, disconnected/disabled grey). |
| `setup_blesh.sh` | Configures `ble.sh` for Bash live auto-suggestions & syntax highlighting. |
| `setup_cli_tools.sh` | Installs `eza` and `bat` for modern icons, colors, and syntax-highlighted `cat`. |
| `setup_docker.sh` | Enables `docker.service` and `docker.socket`, adds current user to `docker` group. Skips gracefully if already configured. |
| `setup_editor.sh` | Sets `EDITOR=nvim` and `VISUAL=nvim` in `~/.bashrc` and `~/.zshrc` if not already configured. |
| `setup_fzf_keybinds.sh` | Configures `fzf` interactive fuzzy search shortcuts (`Ctrl+R`, `Ctrl+T`). |
| `setup_git_config.sh` | Sets global `user.name` and `user.email` defaults, with an overwrite confirmation prompt if credentials exist. |
| `setup_github_ssh.sh` | Generates Ed25519 SSH key if missing, loads it into `ssh-agent`, and prints a beginner-friendly deployment guide for GitHub. |
| `setup_trash_cli_alias.sh` | Installs `trash-cli` and sets `alias rm='trash-put'` in shell configs. |
| `setup_ufw.sh` | Configures UFW with sensible defaults (deny incoming, allow outgoing, allow SSH) and enables it. |
| `setup_vnstat_service.sh` | Installs `vnstat` network traffic monitor and enables `vnstat.service` systemd daemon. |
| `setup_zoxide.sh` | Configures `zoxide` smart directory navigation (`z` / `cd`). |
| `setup_immersionpod.sh` | Configures MPD, MPC, and ImmersionPod for audio language immersion (`~/Videos/Anime`). |
| `setup_tmux_resurrect.sh` | Configures TPM, tmux-resurrect/continuum auto-restore, & systemd user daemon. |
| `setup_agym.sh` | Installs `agym` from GitHub (`Praveensenpai/agym`) & configures shell environment. |

<br>

## 🛠️ ⁺ . ⊹ Custom CLI Tools & Features . ⁺ ✨

Here are special standalone tools included in this repository to enhance your terminal workflow:

| Tool | Command | Description |
| :--- | :--- | :--- |
| 🚀 **Antigravity Manager** | `agym` | Unified CLI tool combining session picker (`agym`), account switcher (`agym accounts`), and quota stats (`agym stats`). |
| 🧹 **System Cleaner** | `arch-cleaner` | Interactive Arch Linux package cache, systemd journal log, and trash cleanup utility (`Praveensenpai/arch-cleaner`). |
| 🎧 **ImmersionPod** | `impd` | Audio language immersion tool integrated with `mpd` & `mpc` targeting `~/Videos/Anime`. |

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
| 🗑️ **`trash-cli`** | Safe Deletion | Replaces `rm` with `trash-put` to prevent accidental file deletion. |
| 📊 **`vnstat`** | Traffic Monitor | Background daemon logging hourly, daily, and monthly network bandwidth usage. |
| 📟 **`tmux`** | Session Resurrect | Terminal multiplexer with auto-save & auto-restore across reboots. |

<br>

<div align="center">
  Made with 💖 by Praveen
</div>