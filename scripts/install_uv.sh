#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🐍 Installing uv (Python package manager)...${NC}"

# Check if already installed
if command -v uv &>/dev/null; then
    echo -e "${GREEN}✔ uv is already installed: $(uv --version)${NC}"
    exit 0
fi

echo -e "${BLUE}⬇️  Downloading and installing uv via official installer...${NC}"
curl -LsSf https://astral.sh/uv/install.sh | sh

# Source the shell env to make uv available immediately
if [ -f "$HOME/.local/bin/uv" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "${GREEN}✔ uv installed: $(uv --version)${NC}"
else
    echo -e "${GREEN}✔ uv installed successfully!${NC}"
fi

echo -e "${CYAN}ℹ️  Restart your terminal or run: source ~/.bashrc (or ~/.zshrc) to use uv.${NC}"
echo -e "${GREEN}🎉 uv setup complete!${NC}"
