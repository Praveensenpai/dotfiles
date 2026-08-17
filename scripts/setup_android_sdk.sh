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
echo "       Setting up Android SDK PATH...         "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

BASHRC="$HOME/.bashrc"

if ! grep -q "ANDROID_HOME" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding Android SDK to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Android SDK" >> "$BASHRC"
    echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> "$BASHRC"
    echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> "$BASHRC"
    echo -e "${GREEN}✔ Added ANDROID_HOME and platform-tools to $BASHRC${NC}"
else
    echo -e "${GREEN}✔ Android SDK PATH already configured in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "     Android SDK PATH setup complete! 🎉      "
echo "✨ ========================================= ✨"
echo -e "${NC}"
