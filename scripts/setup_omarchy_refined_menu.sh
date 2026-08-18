#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Installing Omarchy Refined Menu...${NC}\n"

if [ -d "$HOME/Projects/omarchy-refined-menu" ]; then
    bash "$HOME/Projects/omarchy-refined-menu/install.sh"
else
    curl -sSL "https://raw.githubusercontent.com/Praveensenpai/omarchy-refined-menu/main/install.sh" | bash
fi
