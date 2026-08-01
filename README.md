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
    ├── install_anime4k.sh              # Makes videos look super pretty! 📺
    ├── install_essential_apps.sh       # Installs mpv, anki, and qbittorrent via pacman 📦
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
    ├── setup_trash_cli_alias.sh        # Replaces rm with safe trash-cli (trash-put) 🗑️
    └── setup_vnstat_service.sh         # Installs & enables vnstat data tracking daemon 📊
```

<br>

## ✨ ⁺ . ⊹ Quick Start . ⁺ 🍓

Ready to make things pretty with just one command? 🚀

### 🪄 The One-Liner Magic

Paste this into your terminal to clone and install everything automatically:

```bash
curl -LsSf https://raw.githubusercontent.com/Praveensenpai/dotfiles/main/remote-install.sh | bash
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
| `disable_bluetooth.sh` | Disables bluetooth auto-power on boot. |
| `install_anime4k.sh` | Downloads and configures Anime4K GLSL shaders for `mpv`. |
| `install_essential_apps.sh` | Installs essential software (`mpv`, `anki`, `qbittorrent`) using `pacman -S --needed`. |
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
| `setup_trash_cli_alias.sh` | Installs `trash-cli` and sets `alias rm='trash-put'` in shell configs. |
| `setup_vnstat_service.sh` | Installs `vnstat` network traffic monitor and enables `vnstat.service` systemd daemon. |

<br>

<div align="center">
  Made with 💖 by Praveen
</div>