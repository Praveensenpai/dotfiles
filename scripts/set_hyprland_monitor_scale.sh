#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPR_MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
HYPR_MONITORS_LUA="$HOME/.config/hypr/monitors.lua"

echo -e "${PURPLE}🖥️  Configuring Hyprland monitor scale...${NC}"

if [ -f "$HYPR_MONITORS_LUA" ]; then
    echo -e "${BLUE}📝 Updating monitor scale in ${HYPR_MONITORS_LUA}...${NC}"
    if grep -q "omarchy_monitor_scale =" "$HYPR_MONITORS_LUA"; then
        sed -i 's/local omarchy_monitor_scale = .*/local omarchy_monitor_scale = 1.5/' "$HYPR_MONITORS_LUA"
    elif grep -q "scale =" "$HYPR_MONITORS_LUA"; then
        sed -i 's/scale = .*/scale = 1.5/' "$HYPR_MONITORS_LUA"
    else
        echo 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.5 })' >> "$HYPR_MONITORS_LUA"
    fi
    echo -e "${GREEN}✔ Hyprland Lua monitor scale set to 1.5.${NC}"
fi

if [ -f "$HYPR_MONITORS_CONF" ]; then
    echo -e "${BLUE}📝 Updating monitor scale in ${HYPR_MONITORS_CONF}...${NC}"
    if grep -q "^monitor=" "$HYPR_MONITORS_CONF"; then
        sed -i 's/^monitor=.*/monitor=,preferred,auto,1.5/' "$HYPR_MONITORS_CONF"
    else
        echo "monitor=,preferred,auto,1.5" >> "$HYPR_MONITORS_CONF"
    fi
    echo -e "${GREEN}✔ Hyprland conf monitor scale set to 1.5.${NC}"
else
    echo -e "${BLUE}⚠ ${HYPR_MONITORS_CONF} not found. Creating...${NC}"
    mkdir -p "$(dirname "$HYPR_MONITORS_CONF")"
    cat << 'EOF' > "$HYPR_MONITORS_CONF"
monitor=,preferred,auto,1.5
EOF
    echo -e "${GREEN}✔ Hyprland monitor config created.${NC}"
fi
