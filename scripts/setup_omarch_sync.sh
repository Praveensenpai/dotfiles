#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}⚡ Installing omarch-sync (Declarative Arch System State & Dotfile Auditor) from GitHub...${NC}"

curl -sSL https://raw.githubusercontent.com/Praveensenpai/omarch-sync/main/install.sh | bash

echo -e "${GREEN}${BOLD}✔ omarch-sync installation completed!${NC}"
