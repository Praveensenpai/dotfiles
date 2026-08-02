#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}🧹 Launching arch-cleaner from GitHub...${NC}\n"

curl -4 -fsSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh?v=$(date +%s)" | bash

if command -v arch-cleaner >/dev/null 2>&1; then
    exec arch-cleaner "$@"
fi
