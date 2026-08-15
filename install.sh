#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "🌸 ========================================= 🌸"
echo "        Setting up Omarchy Dotfiles...        "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# Ask for sudo password up front
echo -e "${YELLOW}🔒 Sudo authentication required to proceed:${NC}"
sudo -v || exit 1

# Keep-alive: update existing sudo time stamp until script has finished
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_LOOP_PID=$!
trap 'kill "$SUDO_LOOP_PID" 2>/dev/null || true' EXIT INT TERM

# Ensure scripts directory exists
if [ ! -d "scripts" ]; then
    echo -e "${RED}❌ Error: 'scripts' directory not found!${NC}"
    exit 1
fi

# Ensure scripts have execution permissions
chmod +x scripts/*.sh 2>/dev/null || true

# Run all executable .sh files in the scripts directory
for script in scripts/*.sh; do
    # Skip setup_arch_cleaner.sh and set_waybar_network_speed.sh during initial installation loop
    if [ "$(basename "$script")" = "setup_arch_cleaner.sh" ] || [ "$(basename "$script")" = "set_waybar_network_speed.sh" ]; then
        continue
    fi

    # Omarchy 4 moved the visible bar from Waybar to the Quickshell-based
    # Omarchy Shell. Keep the Waybar helpers available for older releases,
    # but do not apply inactive configuration on current Omarchy installs.
    if command -v omarchy >/dev/null 2>&1 \
        && [ "$(omarchy version | cut -d. -f1)" -ge 4 ] \
        && [[ "$(basename "$script")" == set_waybar_* ]]; then
        echo -e "${YELLOW}⏭ Skipping $(basename "$script") (Omarchy 4 uses Omarchy Shell).${NC}"
        continue
    fi

    if [ -x "$script" ]; then
        echo -e "\n${CYAN}▶ Running $(basename "$script")...${NC}"
        if "$script"; then
            echo -e "${GREEN}✔ Finished $(basename "$script")${NC}"
            echo -e "${BLUE}─────────────────────────────────────────${NC}"
        else
            echo -e "\n${RED}❌ Failed: $(basename "$script") exited with errors! Aborting setup.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⏭ Skipping $(basename "$script") (not executable)${NC}"
    fi
done

echo -e "\n${GREEN}${BOLD}"
echo "🎉 ========================================= 🎉"
echo "       All dotfiles setup completed!          "
echo "🎉 ========================================= 🎉"
echo -e "${NC}"

echo -e "${PURPLE}${BOLD}💡 System Maintenance Tips:${NC}"
echo -e "${CYAN}Clean package caches, system logs, & trash anytime with:${NC}"
echo -e "  ${YELLOW}arch-cleaner${NC}"
echo -e "${CYAN}View live system activity, battery state, & resource load with:${NC}"
echo -e "  ${YELLOW}sys-chronicle status${NC}"
echo ""
