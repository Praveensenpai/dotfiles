#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🎵 Setting up MPD (Music Player Daemon)...${NC}"

# 1. Install mpd if not installed
if ! command -v mpd &>/dev/null; then
    echo -e "${BLUE}📦 Installing mpd via pacman...${NC}"
    if command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm mpd
    else
        echo -e "${RED}❌ pacman not found. Please install mpd manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✔ mpd is already installed.${NC}"
fi

# 2. Ensure configuration and music directories exist
mkdir -p "$HOME/.config/mpd" "$HOME/.local/share/mpd/playlists" "$HOME/Music"

# 3. Create default user mpd.conf if missing
MPD_CONF="$HOME/.config/mpd/mpd.conf"
if [ ! -f "$MPD_CONF" ]; then
    echo -e "${BLUE}⚙ Creating default mpd.conf...${NC}"
    cat << 'EOF' > "$MPD_CONF"
music_directory    "~/Music"
playlist_directory "~/.local/share/mpd/playlists"
db_file            "~/.local/share/mpd/database"
log_file           "syslog"
pid_file           "~/.local/share/mpd/pid"
state_file         "~/.local/share/mpd/state"
sticker_file       "~/.local/share/mpd/sticker.sql"

auto_update "yes"

audio_output {
        type            "pipewire"
        name            "PipeWire Sound Server"
}
EOF
    echo -e "${GREEN}✔ Created ~/.config/mpd/mpd.conf${NC}"
else
    echo -e "${GREEN}✔ mpd configuration already exists at ~/.config/mpd/mpd.conf.${NC}"
fi

# 4. Enable and start MPD user service
echo -e "${BLUE}⚡ Enabling and starting MPD user service...${NC}"
systemctl --user enable --now mpd 2>/dev/null || systemctl --user start mpd 2>/dev/null || true

echo -e "${GREEN}🎉 MPD daemon setup complete!${NC}"
