#!/bin/bash

echo "============================="
echo "  Setting up ImmersionPod & MPD..."
echo "============================="

# 1. Install mpd, mpc, and impd-git
echo "▶ Installing mpd, mpc, and impd-git..."
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm mpd mpc 2>/dev/null || true
fi

if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm impd-git 2>/dev/null || true
fi

# 2. Create directories
echo "▶ Creating directories..."
mkdir -p "$HOME/Music/immersionpod"
mkdir -p "$HOME/Videos/Anime"
mkdir -p "$HOME/.config/mpd/playlists"
mkdir -p "$HOME/.config/immersionpod"

# 3. Configure mpd (~/.config/mpd/mpd.conf)
MPD_CONF="$HOME/.config/mpd/mpd.conf"
if [ ! -f "$MPD_CONF" ]; then
    echo "▶ Configuring mpd ($MPD_CONF)..."
    cat << 'EOF' > "$MPD_CONF"
music_directory    "~/Music/immersionpod"
playlist_directory "~/.config/mpd/playlists"
db_file            "~/.config/mpd/database"

audio_output {
    type    "pipewire"
    name    "PipeWire Sound Server"
}
EOF
else
    echo "✔ mpd config already exists at $MPD_CONF"
fi

# 4. Configure impd (~/.config/immersionpod/config)
IMPD_CONF="$HOME/.config/immersionpod/config"
echo "▶ Configuring immersionpod ($IMPD_CONF)..."
echo 'video_dir=~/Videos/Anime' > "$IMPD_CONF"

# 5. Enable and start mpd user service
if command -v systemctl &>/dev/null; then
    echo "▶ Enabling and starting mpd service..."
    systemctl --user enable --now mpd 2>/dev/null || true
fi

echo "============================="
echo "  ImmersionPod setup complete!"
echo "============================="
