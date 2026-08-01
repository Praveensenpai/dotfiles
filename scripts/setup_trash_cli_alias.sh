#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

echo -e "${PURPLE}🗑️  Configuring trash-cli alias...${NC}"

if ! command -v trash-put &>/dev/null; then
    echo -e "${BLUE}📦 Installing trash-cli package...${NC}"
    sudo pacman -S --needed --noconfirm trash-cli
else
    echo -e "${GREEN}✔ trash-cli is already installed.${NC}"
fi

if [ -f "$BASHRC" ]; then
    if ! grep -q "alias rm='trash-put'" "$BASHRC"; then
        echo -e "${BLUE}📝 Adding alias rm='trash-put' to ${BASHRC}...${NC}"
        echo -e "\nalias rm='trash-put'" >> "$BASHRC"
        echo -e "${GREEN}✔ Alias added to ${BASHRC}.${NC}"
    else
        echo -e "${GREEN}✔ Alias rm='trash-put' already exists in ${BASHRC}.${NC}"
    fi
fi

if [ -f "$ZSHRC" ]; then
    if ! grep -q "alias rm='trash-put'" "$ZSHRC"; then
        echo -e "${BLUE}📝 Adding alias rm='trash-put' to ${ZSHRC}...${NC}"
        echo -e "\nalias rm='trash-put'" >> "$ZSHRC"
        echo -e "${GREEN}✔ Alias added to ${ZSHRC}.${NC}"
    else
        echo -e "${GREEN}✔ Alias rm='trash-put' already exists in ${ZSHRC}.${NC}"
    fi
fi
