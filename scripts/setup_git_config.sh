#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

DEFAULT_NAME="Praveen Senpai"
DEFAULT_EMAIL="pvnt20@gmail.com"

echo -e "${PURPLE}⚙️  Configuring Git User Credentials...${NC}"

CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [ -n "$CURRENT_NAME" ] || [ -n "$CURRENT_EMAIL" ]; then
    echo -e "${YELLOW}Existing Git Configuration Found:${NC}"
    echo -e "  User Name  : ${CYAN}${CURRENT_NAME:-<not set>}${NC}"
    echo -e "  User Email : ${CYAN}${CURRENT_EMAIL:-<not set>}${NC}\n"
    
    if [ -t 0 ]; then
        read -p "Do you want to overwrite your Git user configuration? (y/N): " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}✔ Preserved existing Git configuration.${NC}"
            exit 0
        fi
    else
        echo -e "${GREEN}✔ Running non-interactively; preserving existing Git configuration.${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}📝 Setting global Git user name: ${CYAN}${DEFAULT_NAME}${NC}"
git config --global user.name "$DEFAULT_NAME"

echo -e "${BLUE}📝 Setting global Git user email: ${CYAN}${DEFAULT_EMAIL}${NC}"
git config --global user.email "$DEFAULT_EMAIL"

echo -e "${BLUE}📝 Setting default branch name to 'main'...${NC}"
git config --global init.defaultBranch main

echo -e "${GREEN}🎉 Git configuration complete!${NC}"
