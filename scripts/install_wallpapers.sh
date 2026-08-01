#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🖼️  Installing custom wallpapers...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_WALLPAPERS="$(cd "$SCRIPT_DIR/../wallpapers" 2>/dev/null && pwd)"
TARGET_DIR="$HOME/.config/omarchy/current/theme/backgrounds"

if [ ! -d "$DOTFILES_WALLPAPERS" ]; then
    echo -e "${BLUE}⚠ No wallpapers directory found in dotfiles repository.${NC}"
    exit 0
fi

mkdir -p "$TARGET_DIR"

# Purge unwanted default wallpapers
UNWANTED_WALLPAPERS=(
  "5-oma.jpg"
  "4-oma-cityscape.jpg"
  "2-pawel-czerwinski.jpg"
)

echo -e "${BLUE}🧹 Removing unwanted default wallpapers...${NC}"
for unwanted in "${UNWANTED_WALLPAPERS[@]}"; do
    rm -f "$TARGET_DIR/$unwanted"
done

COPIED_COUNT=0
for img in "$DOTFILES_WALLPAPERS"/*; do
    if [ -f "$img" ]; then
        echo -e "${BLUE}  Deploying $(basename "$img")...${NC}"
        cp "$img" "$TARGET_DIR/"
        ((COPIED_COUNT++))
    fi
done

echo -e "${GREEN}🎉 Deployed ${COPIED_COUNT} custom wallpaper(s) to ${TARGET_DIR}.${NC}"
