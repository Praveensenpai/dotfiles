#!/bin/bash

CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}📺 Installing & configuring Anime4K for mpv via anime4k-cli...${NC}\n"

curl -4 -fsSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/anime4k-cli/main/install.sh?v=$(date +%s)" | sh -s -- "$@"