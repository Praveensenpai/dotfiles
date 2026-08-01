#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"

echo -e "${PURPLE}🔤 Configuring Alacritty font size...${NC}"

if [ -f "$ALACRITTY_CONF" ]; then
    echo -e "${BLUE}📝 Updating font size in ${ALACRITTY_CONF}...${NC}"
    if grep -q "^size =" "$ALACRITTY_CONF"; then
        sed -i 's/^size = .*/size = 10/' "$ALACRITTY_CONF"
    else
        echo "size = 10" >> "$ALACRITTY_CONF"
    fi
    echo -e "${GREEN}✔ Alacritty font size set to 10.${NC}"
else
    echo -e "${YELLOW}⚠ ${ALACRITTY_CONF} not found. Creating default...${NC}"
    mkdir -p "$(dirname "$ALACRITTY_CONF")"
    cat << 'EOF' > "$ALACRITTY_CONF"
[font]
size = 10
EOF
    echo -e "${GREEN}✔ Alacritty config created.${NC}"
fi
