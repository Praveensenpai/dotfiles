#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

MPV_CONF="$HOME/.config/mpv/mpv.conf"

echo -e "${PURPLE}🎬 Setting up yt-dlp and MPV YouTube integration...${NC}"

# 1. Install yt-dlp if not installed
if ! command -v yt-dlp &>/dev/null; then
    echo -e "${BLUE}📦 Installing yt-dlp...${NC}"
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm yt-dlp
    else
        sudo pacman -S --needed --noconfirm yt-dlp
    fi
else
    echo -e "${GREEN}✔ yt-dlp is already installed.${NC}"
fi

# 2. Ensure mpv config directory exists
mkdir -p "$(dirname "$MPV_CONF")"

# 3. Append YouTube streaming settings if missing
if [ -f "$MPV_CONF" ] && grep -q "^#* *ytdl-format=" "$MPV_CONF" 2>/dev/null; then
    echo -e "${GREEN}✔ MPV YouTube settings already configured in mpv.conf.${NC}"
else
    echo -e "${BLUE}⚙ Appending YouTube streaming settings to mpv.conf...${NC}"
    cat << 'INNER_EOF' >> "$MPV_CONF"

# YouTube & Streaming (yt-dlp integration)
ytdl-format="bestvideo[height<=?1080][fps<=?60]+bestaudio/best"
ytdl-raw-options=ignore-errors=
sub-auto=fuzzy
INNER_EOF
    echo -e "${GREEN}✔ Appended YouTube streaming settings to mpv.conf.${NC}"
fi
