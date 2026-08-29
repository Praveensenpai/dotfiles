#!/bin/bash

# Setup Japanese Input Method (Fcitx5 + Mozc) & Omarchy 4 Input Method Bar Widget
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🎌 Setting up Japanese Input Method (Fcitx5 + Mozc)...${NC}"

# 1. Install required packages if missing
PACKAGES=("fcitx5" "fcitx5-mozc" "fcitx5-gtk" "fcitx5-qt" "noto-fonts-cjk")
MISSING_PKGS=()

for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${BLUE}📦 Installing missing packages: ${MISSING_PKGS[*]}...${NC}"
    sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}"
    echo -e "${GREEN}✔ Packages installed successfully.${NC}"
else
    echo -e "${GREEN}✔ All Japanese IME packages are already installed.${NC}"
fi

# 2. Setup environment variables for IME
mkdir -p "$HOME/.config/environment.d"
cat << 'EOC' > "$HOME/.config/environment.d/im.conf"
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
EOC
echo -e "${GREEN}✔ Configured ~/.config/environment.d/im.conf.${NC}"

# 3. Setup Fcitx5 profile with US Keyboard and Mozc
mkdir -p "$HOME/.config/fcitx5"
cat << 'EOC' > "$HOME/.config/fcitx5/profile"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=mozc

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=mozc
Layout=

[GroupOrder]
0=Default
EOC
echo -e "${GREEN}✔ Configured ~/.config/fcitx5/profile.${NC}"

# Disable Fcitx5 system tray icon (so only the Omarchy bar widget shows)
cat << 'EOC' > "$HOME/.config/fcitx5/config"
[Hotkey/TriggerKeys]
0=Control+space
1=Zenkaku_Hankaku

[Hotkey/EnumerateGroupForwardKeys]

[Hotkey/EnumerateGroupBackwardKeys]

[Behavior/DisabledAddons]
0=notificationitem
EOC
echo -e "${GREEN}✔ Disabled Fcitx5 duplicate system tray icon.${NC}"

# 4. Setup Hyprland autostart
mkdir -p "$HOME/.config/hypr"
AUTOSTART_CONF="$HOME/.config/hypr/autostart.conf"
if [ -f "$AUTOSTART_CONF" ]; then
    if ! grep -q "fcitx5" "$AUTOSTART_CONF"; then
        echo "exec-once = fcitx5 -d" >> "$AUTOSTART_CONF"
        echo -e "${GREEN}✔ Added fcitx5 to autostart.conf.${NC}"
    fi
fi

# 5. Setup Hyprland Ctrl+Space keybinding
BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"

if [ -f "$BINDINGS_CONF" ]; then
    if ! grep -q "fcitx5-remote -t" "$BINDINGS_CONF"; then
        echo -e "\n# Toggle Japanese / English Input Method\nbind = CTRL, SPACE, exec, fcitx5-remote -t" >> "$BINDINGS_CONF"
        echo -e "${GREEN}✔ Added Ctrl+Space IME keybind to bindings.conf.${NC}"
    fi
fi

if [ -f "$BINDINGS_LUA" ]; then
    if ! grep -q "fcitx5-remote -t" "$BINDINGS_LUA"; then
        echo -e "\n-- Toggle Japanese / English Input Method\no.bind(\"CTRL + SPACE\", \"Toggle Japanese IME\", \"fcitx5-remote -t\")" >> "$BINDINGS_LUA"
        echo -e "${GREEN}✔ Added Ctrl+Space IME keybind to bindings.lua.${NC}"
    fi
fi

# 6. Ensure Fcitx5 is currently running
if ! pgrep -x fcitx5 >/dev/null 2>&1; then
    fcitx5 -d >/dev/null 2>&1 || true
fi

# 7. Install & Enable paisen.japanese-ime Omarchy bar widget from GitHub
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
USER_PREFIX="$(id -un)"
if [ ! -d "$PLUGINS_DIR/$USER_PREFIX.japanese-ime" ]; then
    echo -e "${BLUE}📦 Installing $USER_PREFIX.japanese-ime plugin from GitHub...${NC}"
    omarchy plugin add https://github.com/Praveensenpai/omarchy-japanese-ime --enable --yes >/dev/null 2>&1 || true
else
    omarchy plugin enable "$USER_PREFIX.japanese-ime" >/dev/null 2>&1 || true
fi

echo -e "${GREEN}🎉 Japanese Input Method setup completed successfully!${NC}"
