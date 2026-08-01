#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}📦 Installing essential applications...${NC}"

sudo pacman -S --needed --noconfirm mpv anki qbittorrent wget

echo -e "${GREEN}🎉 Essential applications (mpv, anki, qbittorrent, wget) installed.${NC}"
