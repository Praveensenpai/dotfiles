#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}📟 Launching tmux-resurrect-systemd setup from GitHub...${NC}\n"

curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/tmux-resurrect-systemd/main/install.sh?v=$(date +%s)" | bash
