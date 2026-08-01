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
echo "        Setting up modern CLI tools...        "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# Install eza and bat if not installed
if ! command -v eza &> /dev/null || ! command -v bat &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo -e "${CYAN}▶ Installing eza and bat via yay...${NC}"
        yay -S --noconfirm eza bat
    fi
fi

BASHRC="$HOME/.bashrc"

# Add aliases for eza and bat
if ! grep -q "alias ls='eza" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding eza and bat aliases to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Modern CLI Tool Aliases" >> "$BASHRC"
    echo "alias ls='eza --icons --group-directories-first'" >> "$BASHRC"
    echo "alias ll='eza -la --icons --group-directories-first'" >> "$BASHRC"
    echo "alias cat='bat --style=plain'" >> "$BASHRC"
    echo -e "${GREEN}✔ Added aliases to $BASHRC${NC}"
else
    echo -e "${GREEN}✔ CLI tool aliases already exist in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "        CLI tools setup complete! 🎉          "
echo "✨ ========================================= ✨"
echo -e "${NC}"
