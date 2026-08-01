#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Installing Antigravity CLI...${NC}"

if command -v agy &>/dev/null || command -v antigravity &>/dev/null; then
    echo -e "${GREEN}✔ Antigravity CLI is already installed.${NC}"
else
    echo -e "${BLUE}📥 Running Antigravity CLI installer...${NC}"
    curl -fsSL https://antigravity.google/cli/install.sh | bash
    echo -e "${GREEN}🎉 Antigravity CLI setup complete.${NC}"
fi
