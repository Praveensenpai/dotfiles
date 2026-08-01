#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "🌸 ========================================= 🌸"
echo "        Setting up zoxide (Smart cd)...       "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

if ! command -v zoxide &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo -e "${CYAN}▶ Installing zoxide via yay...${NC}"
        yay -S --noconfirm zoxide
    fi
fi

BASHRC="$HOME/.bashrc"

if ! grep -q "zoxide init bash" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding zoxide initialization to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Zoxide Smart Navigation" >> "$BASHRC"
    echo 'eval "$(zoxide init bash)"' >> "$BASHRC"
    echo 'alias cd="z"' >> "$BASHRC"
    echo -e "${GREEN}✔ Configured zoxide in $BASHRC${NC}"
else
    echo -e "${GREEN}✔ zoxide already configured in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "         zoxide setup complete! 🎉            "
echo "✨ ========================================= ✨"
echo -e "${NC}"
