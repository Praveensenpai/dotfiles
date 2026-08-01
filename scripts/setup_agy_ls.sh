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
echo "    Setting up agy-ls (AGY Session Picker)... "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# 1. Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# 2. Copy agy-ls script to ~/.local/bin
SCRIPT_SRC="$(dirname "$0")/agy-ls"
TARGET="$HOME/.local/bin/agy-ls"

if [ -f "$SCRIPT_SRC" ]; then
    echo -e "${CYAN}▶ Installing agy-ls to ${YELLOW}$TARGET${CYAN}...${NC}"
    cp "$SCRIPT_SRC" "$TARGET"
    chmod +x "$TARGET"
    echo -e "${GREEN}✔ Installed agy-ls executable${NC}"
fi

# 3. Configure alias in ~/.bashrc
BASHRC="$HOME/.bashrc"
if ! grep -q "alias agy-ls=" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding agy-ls alias to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Antigravity CLI Session Picker Alias" >> "$BASHRC"
    echo "alias agy-ls='$HOME/.local/bin/agy-ls'" >> "$BASHRC"
    echo -e "${GREEN}✔ Configured agy-ls alias in $BASHRC${NC}"
else
    echo -e "${GREEN}✔ agy-ls alias already exists in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "         agy-ls setup complete! 🎉            "
echo "✨ ========================================= ✨"
echo -e "${NC}"
