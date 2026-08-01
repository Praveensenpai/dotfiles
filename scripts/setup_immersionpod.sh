#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "🌸 ========================================= 🌸"
echo "        Setting up ImmersionPod & MPD...      "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# 1. Install mpd, mpc, and ffmpeg via pacman
echo -e "${CYAN}▶ Installing mpd, mpc, and ffmpeg...${NC}"
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm mpd mpc ffmpeg 2>/dev/null || true
fi

# 2. Install impd directly from official upstream repo (instant download)
if ! command -v impd &>/dev/null; then
    echo -e "${CYAN}▶ Downloading impd directly...${NC}"
    sudo curl -sL https://raw.githubusercontent.com/Ajatt-Tools/impd/master/impd -o /usr/local/bin/impd
    sudo chmod +x /usr/local/bin/impd
    echo -e "${GREEN}✔ Installed impd to /usr/local/bin/impd${NC}"
else
    echo -e "${GREEN}✔ impd is already installed${NC}"
fi

# 3. Create required directories
echo -e "${CYAN}▶ Creating directories...${NC}"
mkdir -p "$HOME/Music/immersionpod"
mkdir -p "$HOME/Videos/Anime"
mkdir -p "$HOME/.config/mpd/playlists"
mkdir -p "$HOME/.config/immersionpod"

# 4. Configure mpd (~/.config/mpd/mpd.conf)
MPD_CONF="$HOME/.config/mpd/mpd.conf"
if [ ! -f "$MPD_CONF" ]; then
    echo -e "${CYAN}▶ Configuring mpd (${YELLOW}$MPD_CONF${CYAN})...${NC}"
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
    echo -e "${GREEN}✔ mpd config already exists at $MPD_CONF${NC}"
fi

# 5. Configure impd (~/.config/immersionpod/config)
IMPD_CONF="$HOME/.config/immersionpod/config"
echo -e "${CYAN}▶ Configuring immersionpod (${YELLOW}$IMPD_CONF${CYAN})...${NC}"
echo 'video_dir=~/Videos/Anime' > "$IMPD_CONF"

# 6. Enable and start mpd user service
if command -v systemctl &>/dev/null; then
    echo -e "${CYAN}▶ Enabling and starting mpd service...${NC}"
    systemctl --user enable --now mpd 2>/dev/null || true
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "      ImmersionPod setup complete! 🎉        "
echo "✨ ========================================= ✨"
echo -e "${NC}"
