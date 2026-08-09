#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}⏱️ Installing sys-chronicle (System Activity & Resource Logger) from GitHub...${NC}\n"

curl -4 -sSL -H "Accept: application/vnd.github.v3.raw" "https://api.github.com/repos/Praveensenpai/sys-chronicle/contents/install.sh" | bash
