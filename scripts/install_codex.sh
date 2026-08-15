#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🤖 Installing OpenAI Codex CLI...${NC}"

# Check if already installed
if command -v codex &>/dev/null; then
    echo -e "${GREEN}✔ OpenAI Codex CLI is already installed.${NC}"
    exit 0
fi

echo -e "${BLUE}📦 Installing openai-codex package...${NC}"

if command -v pacman &>/dev/null; then
    if sudo pacman -Sy --needed --noconfirm openai-codex; then
        echo -e "${GREEN}🎉 OpenAI Codex CLI setup complete.${NC}"
        exit 0
    fi
fi

if command -v yay &>/dev/null; then
    echo -e "${BLUE}📦 Attempting installation via yay (openai-codex-bin)...${NC}"
    if yay -S --needed --noconfirm openai-codex-bin; then
        echo -e "${GREEN}🎉 OpenAI Codex CLI setup complete.${NC}"
        exit 0
    fi
fi

echo -e "${RED}❌ Failed to install OpenAI Codex CLI.${NC}"
exit 1
