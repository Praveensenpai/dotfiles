#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPRIDLE_CONF="$HOME/.config/hypr/hypridle.conf"
BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"

echo -e "${PURPLE}⚙️ Configuring Hyprland idle timeouts and keybindings...${NC}"

# Configure hypridle (30m screensaver, 1h lock)
if [ -f "$HYPRIDLE_CONF" ]; then
    echo -e "${BLUE}📝 Updating timeouts in ${HYPRIDLE_CONF}...${NC}"
    sed -i 's/# Start screensaver after.*/# Start screensaver after 30 minutes/' "$HYPRIDLE_CONF"
    sed -i 's/# Lock system after.*/# Lock system after 1 hour (screensaver resets idle timer, so have to just do half + 2s margin)/' "$HYPRIDLE_CONF"
    
    awk '
    /listener \{/ { count++ }
    /timeout =/ {
        if (count == 1) { print "    timeout = 1800"; next }
        if (count == 2) { print "    timeout = 1802"; next }
    }
    { print }
    ' "$HYPRIDLE_CONF" > "$HYPRIDLE_CONF.tmp" && mv "$HYPRIDLE_CONF.tmp" "$HYPRIDLE_CONF"
    echo -e "${GREEN}✔ Updated hypridle timeouts (30m screensaver, 1h lock).${NC}"
fi

# Configure bindings.lua (Super+BrightnessDown to 0%)
if [ -f "$BINDINGS_LUA" ]; then
    if ! grep -q "XF86MonBrightnessDown" "$BINDINGS_LUA"; then
        echo -e "${BLUE}📝 Adding Super+BrightnessDown binding to ${BINDINGS_LUA}...${NC}"
        echo 'o.bind("SUPER + XF86MonBrightnessDown", "Brightness 0%", "omarchy-brightness-display 0%")' >> "$BINDINGS_LUA"
        echo -e "${GREEN}✔ Added Super+BrightnessDown 0% keybinding to bindings.lua.${NC}"
    fi
fi

# Configure bindings.conf (Super+BrightnessDown to 0%)
if [ -f "$BINDINGS_CONF" ]; then
    if ! grep -q "XF86MonBrightnessDown.*0%" "$BINDINGS_CONF"; then
        echo -e "${BLUE}📝 Adding Super+BrightnessDown binding to ${BINDINGS_CONF}...${NC}"
        echo 'bindeld = SUPER, XF86MonBrightnessDown, Brightness 0%, exec, omarchy-brightness-display 0%' >> "$BINDINGS_CONF"
        echo -e "${GREEN}✔ Added Super+BrightnessDown 0% keybinding to bindings.conf.${NC}"
    fi
fi
