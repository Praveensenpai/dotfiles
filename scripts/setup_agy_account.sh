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
echo "    Setting up agy-account (AGY Switcher)...  "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# 1. Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# 2. Copy agy-account script to ~/.local/bin
SCRIPT_SRC="$(dirname "$0")/agy-account"
TARGET="$HOME/.local/bin/agy-account"

if [ -f "$SCRIPT_SRC" ]; then
    echo -e "${CYAN}▶ Installing agy-account to ${YELLOW}$TARGET${CYAN}...${NC}"
    cp "$SCRIPT_SRC" "$TARGET"
    chmod +x "$TARGET"
    echo -e "${GREEN}✔ Installed agy-account executable${NC}"
fi

# 3. Configure alias in ~/.bashrc
BASHRC="$HOME/.bashrc"
if ! grep -q "alias agy-account=" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding agy-account alias to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Antigravity CLI Account Switcher Alias" >> "$BASHRC"
    echo "alias agy-account='$HOME/.local/bin/agy-account'" >> "$BASHRC"
    echo -e "${GREEN}✔ Configured agy-account alias in $BASHRC${NC}"
else
    echo -e "${GREEN}✔ agy-account alias already exists in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "       agy-account setup complete! 🎉         "
echo "✨ ========================================= ✨"
echo -e "${NC}"
