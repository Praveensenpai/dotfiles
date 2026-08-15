#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPR_LOOK_CONF="$HOME/.config/hypr/looknfeel.conf"
HYPR_LOOK_LUA="$HOME/.config/hypr/looknfeel.lua"

echo -e "${PURPLE}🪟 Configuring Hyprland gaps & border colors...${NC}"

if [ -f "$HYPR_LOOK_LUA" ]; then
    echo -e "${BLUE}📝 Updating gaps and borders in ${HYPR_LOOK_LUA}...${NC}"
    
    if grep -q "gaps_in =" "$HYPR_LOOK_LUA"; then
        sed -i 's/^[[:space:]]*gaps_in = .*/    gaps_in = 0,/' "$HYPR_LOOK_LUA"
    fi
    if grep -q "gaps_out =" "$HYPR_LOOK_LUA"; then
        sed -i 's/^[[:space:]]*gaps_out = .*/    gaps_out = 0,/' "$HYPR_LOOK_LUA"
    fi
    echo -e "${GREEN}✔ Hyprland Lua window gaps & border colors updated.${NC}"
fi

if [ -f "$HYPR_LOOK_CONF" ]; then
    echo -e "${BLUE}📝 Updating gaps and borders in ${HYPR_LOOK_CONF}...${NC}"
    
    if grep -q "^[[:space:]]*gaps_in =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*gaps_in = .*/    gaps_in = 0/' "$HYPR_LOOK_CONF"
    fi
    if grep -q "^[[:space:]]*gaps_out =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*gaps_out = .*/    gaps_out = 0/' "$HYPR_LOOK_CONF"
    fi

    if grep -q "^[[:space:]]*col.active_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*col.active_border = .*/    col.active_border = rgba(7aa2f755)/' "$HYPR_LOOK_CONF"
    fi
    if grep -q "^[[:space:]]*col.inactive_border =" "$HYPR_LOOK_CONF"; then
        sed -i 's/^[[:space:]]*col.inactive_border = .*/    col.inactive_border = rgba(59595922)/' "$HYPR_LOOK_CONF"
    fi
    echo -e "${GREEN}✔ Hyprland conf window gaps & border colors updated.${NC}"
fi
