#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

HYPRIDLE_CONF="$HOME/.config/hypr/hypridle.conf"
BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"

echo -e "${PURPLE}⚙️ Configuring Hyprland idle timeouts and keybindings...${NC}"

# Configure hypridle (30m screensaver, 1h lock)
if [ -f "$HYPRIDLE_CONF" ]; then
    echo -e "${BLUE}📝 Updating timeouts in ${HYPRIDLE_CONF}...${NC}"
    sed -i 's/# Start screensaver after.*/# Start screensaver after 30 minutes/' "$HYPRIDLE_CONF"
    sed -i 's/# Lock system after.*/# Lock system after 1 hour (screensaver resets idle timer, so have to just do half + 2s margin)/' "$HYPRIDLE_CONF"
    
    python3 -c '
lines = open("'"$HYPRIDLE_CONF"'").readlines()
new_lines = []
listener_count = 0
for line in lines:
    if "listener {" in line:
        listener_count += 1
    if "timeout =" in line:
        if listener_count == 1:
            line = "    timeout = 1800\n"
        elif listener_count == 2:
            line = "    timeout = 1802\n"
    new_lines.append(line)

open("'"$HYPRIDLE_CONF"'", "w").writelines(new_lines)
'
    echo -e "${GREEN}✔ Updated hypridle timeouts (30m screensaver, 1h lock).${NC}"
fi

# Configure bindings.conf (Super+BrightnessDown to 0%)
if [ -f "$BINDINGS_CONF" ]; then
    if ! grep -q "XF86MonBrightnessDown.*0%" "$BINDINGS_CONF"; then
        echo -e "${BLUE}📝 Adding Super+BrightnessDown binding to ${BINDINGS_CONF}...${NC}"
        echo 'bindeld = SUPER, XF86MonBrightnessDown, Brightness 0%, exec, omarchy-brightness-display 0%' >> "$BINDINGS_CONF"
        echo -e "${GREEN}✔ Added Super+BrightnessDown 0% keybinding.${NC}"
    fi
fi
