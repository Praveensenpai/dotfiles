#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}✏️  Configuring default terminal editor (neovim)...${NC}"

BASHRC="$HOME/.bashrc"

EXPORT_LINES='export EDITOR="nvim"
export VISUAL="nvim"'

RC_FILE="$HOME/.bashrc"
if [ -f "$RC_FILE" ]; then
    if ! grep -q 'EDITOR="nvim"' "$RC_FILE"; then
        echo -e "${BLUE}📝 Adding EDITOR=nvim to $(basename "$RC_FILE")...${NC}"
        echo -e "\n# Default terminal editor\n$EXPORT_LINES" >> "$RC_FILE"
        echo -e "${GREEN}✔ Added to $(basename "$RC_FILE").${NC}"
    else
        echo -e "${GREEN}✔ EDITOR=nvim already set in $(basename "$RC_FILE"). Skipping.${NC}"
    fi
fi

echo -e "${GREEN}🎉 Default editor set to neovim (nvim).${NC}"
