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
echo "        Setting up ble.sh for Bash...          "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

BASHRC="$HOME/.bashrc"

# Check if blesh is installed via yay/pacman or binary
if command -v blesh &> /dev/null || [ -f "$HOME/.local/share/blesh/ble.sh" ] || [ -f "/usr/share/blesh/ble.sh" ]; then
    echo -e "${GREEN}✔ ble.sh is already installed${NC}"
else
    if command -v yay &> /dev/null; then
        echo -e "${CYAN}▶ Installing blesh-git via yay...${NC}"
        yay -S --noconfirm blesh-git
    else
        echo -e "${CYAN}▶ Downloading pre-built ble.sh...${NC}"
        mkdir -p "$HOME/.local/share"
        TMP_DIR=$(mktemp -d)
        curl -sL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJ -C "$TMP_DIR"
        rm -rf "$HOME/.local/share/blesh"
        mv "$TMP_DIR/ble-nightly" "$HOME/.local/share/blesh"
        rm -rf "$TMP_DIR"
    fi
fi

# Detect blesh installation location for .bashrc
BLE_PATH=""
if [ -f "/usr/share/blesh/ble.sh" ]; then
    BLE_PATH="/usr/share/blesh/ble.sh"
elif [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    BLE_PATH="$HOME/.local/share/blesh/ble.sh"
fi

# Ensure ble.sh is sourced in ~/.bashrc for interactive shells
if [ -n "$BLE_PATH" ] && ! grep -q "blesh/ble.sh" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding ble.sh to ${YELLOW}$BASHRC${CYAN}...${NC}"
    sed -i "/\[\[ \$- != \*i\* \]\] && return/a \\n# Bash Line Editor (ble.sh)\n[[ \$- == *i* ]] && source $BLE_PATH" "$BASHRC"
    echo -e "${GREEN}✔ Added ble.sh source line to $BASHRC${NC}"
else
    echo -e "${GREEN}✔ ble.sh configuration up-to-date in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "         ble.sh setup complete! 🎉            "
echo "✨ ========================================= ✨"
echo -e "${NC}"
