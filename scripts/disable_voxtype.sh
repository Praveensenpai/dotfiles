#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🎙️ Disabling Voxtype service and keybindings...${NC}"

# Disable and stop user systemd service if running / enabled
if systemctl --user is-enabled voxtype &>/dev/null || systemctl --user is-active voxtype &>/dev/null; then
    echo -e "${BLUE}🛑 Stopping and disabling voxtype systemd user service...${NC}"
    systemctl --user disable --now voxtype 2>/dev/null || true
fi

# Ensure any running voxtype process is stopped
pkill -x voxtype 2>/dev/null || true

# Comment out voxtype keybinding in bindings.conf if present and active
BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"
if [ -f "$BINDINGS_CONF" ]; then
    if grep -q "^[[:space:]]*bind.*voxtype" "$BINDINGS_CONF"; then
        echo -e "${BLUE}📝 Commenting out voxtype keybinding in ${BINDINGS_CONF}...${NC}"
        sed -i 's/^\([[:space:]]*bind[a-z]*[[:space:]]*=[^#]*voxtype.*\)/# \1/' "$BINDINGS_CONF"
    fi
fi

# Comment out voxtype keybinding in bindings.lua if present and active
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
if [ -f "$BINDINGS_LUA" ]; then
    if grep -q "^[[:space:]]*o\.bind(.*voxtype" "$BINDINGS_LUA"; then
        echo -e "${BLUE}📝 Commenting out voxtype keybinding in ${BINDINGS_LUA}...${NC}"
        sed -i 's/^\([[:space:]]*o\.bind([^)]*voxtype.*\)/-- \1/' "$BINDINGS_LUA"
    fi
fi

echo -e "${GREEN}✨ Voxtype is now disabled!${NC}"
