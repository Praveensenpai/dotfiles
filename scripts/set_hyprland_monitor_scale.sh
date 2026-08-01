#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPR_MONITORS_CONF="$HOME/.config/hypr/monitors.conf"

echo -e "${PURPLE}🖥️  Configuring Hyprland monitor scale...${NC}"

if [ -f "$HYPR_MONITORS_CONF" ]; then
    echo -e "${BLUE}📝 Updating monitor scale in ${HYPR_MONITORS_CONF}...${NC}"
    if grep -q "^monitor=" "$HYPR_MONITORS_CONF"; then
        sed -i 's/^monitor=.*/monitor=,preferred,auto,1.5/' "$HYPR_MONITORS_CONF"
    else
        echo "monitor=,preferred,auto,1.5" >> "$HYPR_MONITORS_CONF"
    fi
    echo -e "${GREEN}✔ Hyprland monitor scale set to 1.5.${NC}"
else
    echo -e "${BLUE}⚠ ${HYPR_MONITORS_CONF} not found. Creating...${NC}"
    mkdir -p "$(dirname "$HYPR_MONITORS_CONF")"
    cat << 'EOF' > "$HYPR_MONITORS_CONF"
monitor=,preferred,auto,1.5
EOF
    echo -e "${GREEN}✔ Hyprland monitor config created.${NC}"
fi
