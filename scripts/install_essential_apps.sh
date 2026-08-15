#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}📦 Installing essential applications...${NC}"

echo -e "${BLUE}📦 Installing official packages via pacman...${NC}"
sudo pacman -Sy --needed --noconfirm mpv anki qbittorrent wget neovim firefox yazi zoxide rust

if command -v yay &>/dev/null; then
  echo -e "${BLUE}📦 Installing AUR packages via yay...${NC}"
  yay -S --needed --noconfirm google-chrome
fi

echo -e "${GREEN}🎉 Essential applications (mpv, anki, qbittorrent, wget, neovim, firefox, yazi, zoxide, rust, google-chrome) installed.${NC}"
