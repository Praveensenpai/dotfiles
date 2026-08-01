#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🗑️  Removing default Omarchy web apps...${NC}"

DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/applications/icons"

# List of default Omarchy web apps to purge
WEB_APPS=(
  "Basecamp"
  "ChatGPT"
  "Discord"
  "Figma"
  "Fizzy"
  "GitHub"
  "Google Contacts"
  "Google Maps"
  "Google Messages"
  "Google Photos"
  "HEY"
  "WhatsApp"
  "X"
  "YouTube"
  "Zoom"
)

REMOVED_COUNT=0

for APP in "${WEB_APPS[@]}"; do
  DESKTOP_FILE="$DESKTOP_DIR/$APP.desktop"
  ICON_FILE="$ICON_DIR/$APP.png"
  
  if [ -f "$DESKTOP_FILE" ] || [ -f "$ICON_FILE" ]; then
    echo -e "${BLUE}  Removing ${APP}...${NC}"
    rm -f "$DESKTOP_FILE" "$ICON_FILE"
    ((REMOVED_COUNT++))
  fi
done

if command -v omarchy-restart-walker &>/dev/null; then
  omarchy-restart-walker 2>/dev/null || true
fi

echo -e "${GREEN}🎉 Removed ${REMOVED_COUNT} default web apps.${NC}"
