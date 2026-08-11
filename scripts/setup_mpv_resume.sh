#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

MPV_CONF="$HOME/.config/mpv/mpv.conf"

echo -e "${PURPLE}🎬 Setting up MPV playback position saving...${NC}"

# Ensure mpv config directory exists
mkdir -p "$(dirname "$MPV_CONF")"

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
