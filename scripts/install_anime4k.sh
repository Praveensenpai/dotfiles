#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}📺 Launching anime4k-mpv-installer from GitHub...${NC}\n"

curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/anime4k-mpv-installer/main/install.sh?v=$(date +%s)" | bash

if command -v anime4k-mpv-installer >/dev/null 2>&1; then
    exec anime4k-mpv-installer "$@"
fi