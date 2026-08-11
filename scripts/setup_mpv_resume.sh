#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

MPV_CONF="$HOME/.config/mpv/mpv.conf"
MPV_SCRIPTS_DIR="$HOME/.config/mpv/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${PURPLE}🎬 Setting up MPV playback position saving & directory auto-playlist...${NC}"

# Ensure mpv config directories exist
mkdir -p "$(dirname "$MPV_CONF")"
mkdir -p "$MPV_SCRIPTS_DIR"

# Check if save-position-on-quit is already set in mpv.conf
if [ -f "$MPV_CONF" ] && grep -q "^#* *save-position-on-quit=" "$MPV_CONF" 2>/dev/null; then
    echo -e "${BLUE}⚙ Updating save-position-on-quit in mpv.conf...${NC}"
    sed -i "s|^#* *save-position-on-quit=.*|save-position-on-quit=yes|" "$MPV_CONF"
    echo -e "${GREEN}✔ Save playback position setting updated in mpv.conf.${NC}"
else
    echo -e "${BLUE}⚙ Appending save-position-on-quit setting to mpv.conf...${NC}"
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Save playback position on quit so videos resume where left off
save-position-on-quit=yes
INNER_EOF
    echo -e "${GREEN}✔ Appended save-position-on-quit setting to mpv.conf.${NC}"
fi

# Check if input-ipc-server is already set in mpv.conf
if [ -f "$MPV_CONF" ] && grep -q "^#* *input-ipc-server=" "$MPV_CONF" 2>/dev/null; then
    echo -e "${BLUE}⚙ Updating input-ipc-server in mpv.conf...${NC}"
    sed -i "s|^#* *input-ipc-server=.*|input-ipc-server=/tmp/mpvsocket|" "$MPV_CONF"
    echo -e "${GREEN}✔ IPC socket server setting updated in mpv.conf.${NC}"
else
    echo -e "${BLUE}⚙ Appending input-ipc-server setting to mpv.conf...${NC}"
    cat << 'INNER_EOF' >> "$MPV_CONF"

# Enable IPC socket server for sys-chronicle real-time media telemetry
input-ipc-server=/tmp/mpvsocket
INNER_EOF
    echo -e "${GREEN}✔ Appended input-ipc-server setting to mpv.conf.${NC}"
fi

# Deploy autoload.lua for auto-loading season episodes into playlist
if [ -f "$DOTFILES_DIR/mpv/scripts/autoload.lua" ]; then
    echo -e "${BLUE}⚙ Deploying autoload.lua script...${NC}"
    cp "$DOTFILES_DIR/mpv/scripts/autoload.lua" "$MPV_SCRIPTS_DIR/autoload.lua"
    echo -e "${GREEN}✔ Deployed autoload.lua script to $MPV_SCRIPTS_DIR.${NC}"
elif [ ! -f "$MPV_SCRIPTS_DIR/autoload.lua" ]; then
    echo -e "${BLUE}📥 Downloading autoload.lua script...${NC}"
    curl -sSL "https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua" -o "$MPV_SCRIPTS_DIR/autoload.lua"
    echo -e "${GREEN}✔ Downloaded autoload.lua script to $MPV_SCRIPTS_DIR.${NC}"
else
    echo -e "${GREEN}✔ autoload.lua script already present.${NC}"
fi
