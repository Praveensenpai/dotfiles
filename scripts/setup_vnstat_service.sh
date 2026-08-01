#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}📊 Configuring vnstat data tracking service...${NC}"

if ! command -v vnstat &>/dev/null; then
    echo -e "${BLUE}📦 Installing vnstat network traffic monitor...${NC}"
    sudo pacman -S --needed --noconfirm vnstat
else
    echo -e "${GREEN}✔ vnstat is already installed.${NC}"
fi

echo -e "${BLUE}⚡ Enabling and starting vnstat background service...${NC}"
sudo systemctl enable --now vnstat

echo -e "${GREEN}🎉 vnstat daemon enabled and active.${NC}"
