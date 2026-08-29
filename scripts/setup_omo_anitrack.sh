#!/bin/bash

# Setup Omo Anitrack (Anime Airing Schedule & Watchlist Plugin)
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🎌 Setting up Omo Anitrack Plugin...${NC}"

# 1. Install prerequisites (curl, jq)
PACKAGES=("curl" "jq")
MISSING_PKGS=()

for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${BLUE}📦 Installing missing packages: ${MISSING_PKGS[*]}...${NC}"
    sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}"
    echo -e "${GREEN}✔ Packages installed successfully.${NC}"
else
    echo -e "${GREEN}✔ Prerequisites (curl, jq) are installed.${NC}"
fi

# 2. Setup user storage directory
CONFIG_DIR="$HOME/.config/omarchy/anitrack"
mkdir -p "$CONFIG_DIR"
[ ! -f "$CONFIG_DIR/pins.json" ] && echo "[]" > "$CONFIG_DIR/pins.json"
echo -e "${GREEN}✔ Watchlist storage initialized at ~/.config/omarchy/anitrack/pins.json.${NC}"

# 3. Install & Enable paisen.omo-anitrack from GitHub
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
USER_PREFIX="$(id -un)"
if [ ! -d "$PLUGINS_DIR/$USER_PREFIX.omo-anitrack" ]; then
    echo -e "${BLUE}📦 Installing $USER_PREFIX.omo-anitrack plugin from GitHub...${NC}"
    omarchy plugin add https://github.com/Praveensenpai/omo-anitrack --enable --yes >/dev/null 2>&1 || true
else
    omarchy plugin enable "$USER_PREFIX.omo-anitrack" >/dev/null 2>&1 || true
fi

echo -e "${GREEN}🎉 Omo Anitrack setup completed successfully!${NC}"
