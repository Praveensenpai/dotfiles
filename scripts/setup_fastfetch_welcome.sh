#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}💻 Displaying fastfetch system summary...${NC}"

if ! command -v fastfetch &>/dev/null; then
    echo -e "${BLUE}📦 Installing fastfetch package...${NC}"
    sudo pacman -S --needed --noconfirm fastfetch
fi

echo -e "${BLUE}📊 System Summary:${NC}"
fastfetch

echo -e "${GREEN}✔ System summary displayed.${NC}"
