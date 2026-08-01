#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}💻 Configuring fastfetch terminal welcome banner...${NC}"

if ! command -v fastfetch &>/dev/null; then
    echo -e "${BLUE}📦 Installing fastfetch package...${NC}"
    sudo pacman -S --needed --noconfirm fastfetch
else
    echo -e "${GREEN}✔ fastfetch is already installed.${NC}"
fi

BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

if [ -f "$BASHRC" ]; then
    if ! grep -q "^fastfetch" "$BASHRC"; then
        echo -e "${BLUE}📝 Adding fastfetch to ${BASHRC}...${NC}"
        echo -e "\nfastfetch" >> "$BASHRC"
        echo -e "${GREEN}✔ Added fastfetch startup hook to ${BASHRC}.${NC}"
    fi
fi

if [ -f "$ZSHRC" ]; then
    if ! grep -q "^fastfetch" "$ZSHRC"; then
        echo -e "${BLUE}📝 Adding fastfetch to ${ZSHRC}...${NC}"
        echo -e "\nfastfetch" >> "$ZSHRC"
        echo -e "${GREEN}✔ Added fastfetch startup hook to ${ZSHRC}.${NC}"
    fi
fi

echo -e "${GREEN}🎉 Fastfetch terminal welcome banner configured.${NC}"
