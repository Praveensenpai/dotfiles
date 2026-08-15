#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPR_DIR="$HOME/.config/hypr"
HYPR_LOOK_CONF="$HYPR_DIR/looknfeel.conf"
HYPR_LOOK_LUA="$HYPR_DIR/looknfeel.lua"

echo -e "${PURPLE}🪟 Configuring Hyprland gaps & border colors...${NC}"

mkdir -p "$HYPR_DIR"

# 1. Update/Deploy Lua config (Omarchy 4+)
cat << 'EOF' > "$HYPR_LOOK_LUA"
-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,

    col = {
      active_border = "rgba(7aa2f755)",
      inactive_border = "rgba(59595922)",
    },
  },
})
EOF
echo -e "${GREEN}✔ Hyprland Lua gaps & border config deployed to ${HYPR_LOOK_LUA}.${NC}"

# 2. Update/Deploy standard conf config
cat << 'EOF' > "$HYPR_LOOK_CONF"
# Change the default Omarchy look'n'feel

# https://wiki.hypr.land/Configuring/Basics/Variables/#general
general {
    # No gaps between windows or borders
    gaps_in = 0
    gaps_out = 0
    border_size = 1

    # Faded / semi-transparent border color
    col.active_border = rgba(7aa2f755)
    col.inactive_border = rgba(59595922)
}
EOF
echo -e "${GREEN}✔ Hyprland conf gaps & border config deployed to ${HYPR_LOOK_CONF}.${NC}"

