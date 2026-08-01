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
echo "        Setting up fzf keybindings...         "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

if ! command -v fzf &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo -e "${CYAN}▶ Installing fzf via yay...${NC}"
        yay -S --noconfirm fzf
    fi
fi

BASHRC="$HOME/.bashrc"

if ! grep -q "fzf/key-bindings.bash" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding fzf keybindings to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# fzf Keybindings & Completion" >> "$BASHRC"
    echo '[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash' >> "$BASHRC"
    echo '[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash' >> "$BASHRC"
    echo -e "${GREEN}✔ Added fzf keybindings to $BASHRC${NC}"
else
    echo -e "${GREEN}✔ fzf keybindings already configured in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "          fzf setup complete! 🎉             "
echo "✨ ========================================= ✨"
echo -e "${NC}"
