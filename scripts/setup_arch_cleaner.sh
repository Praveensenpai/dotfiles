#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🧹 Launching arch-cleaner from GitHub...${NC}\n"

curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh?v=$(date +%s)" | bash

if command -v arch-cleaner >/dev/null 2>&1; then
    exec arch-cleaner "$@"
fi
