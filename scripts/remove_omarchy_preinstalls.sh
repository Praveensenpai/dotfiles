#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🗑️  Purging default Omarchy/DHH preinstalled applications and tooling...${NC}"

# List of DHH/Omarchy default packages to uninstall
PKGS_TO_REMOVE=(
  1password-beta
  1password-cli
  aether
  cliamp
  typora
  spotify
  libreoffice-fresh
  xournalpp
  signal-desktop
  pinta
  obsidian
  obs-studio
  kdenlive
  lazydocker
  claude-code
  chromium
  localsend
  localsend-bin
  ibus
  gnome-calculator
  evince
  system-config-printer
  cups
  cups-filters
  cups-browsed
  cups-pdf
)

# Remove packages installed via pacman if present
INSTALLED_PKGS=()
for PKG in "${PKGS_TO_REMOVE[@]}"; do
  if pacman -Qq "$PKG" &>/dev/null; then
    INSTALLED_PKGS+=("$PKG")
  fi
done

if [ ${#INSTALLED_PKGS[@]} -gt 0 ]; then
  echo -e "${BLUE}📦 Removing packages: ${INSTALLED_PKGS[*]}...${NC}"
  sudo pacman -Rns --noconfirm "${INSTALLED_PKGS[@]}" || true
else
  echo -e "${GREEN}✔ No preinstalled GUI/CLI packages found to remove.${NC}"
fi

# Remove lingering desktop entry files in ~/.local/share/applications/
echo -e "${BLUE}🧹 Cleaning up orphaned desktop entries...${NC}"
rm -f ~/.local/share/applications/typora.desktop \
      ~/.local/share/applications/localsend.desktop \
      ~/.local/share/applications/org.freedesktop.IBus.Setup.desktop

# Hide unwanted system launcher entries (Color Profile, IBus) in ~/.local/share/applications/
HIDE_DESKTOPS=(
  "org.freedesktop.IBus.Setup.desktop"
  "gnome-color-panel.desktop"
  "org.gnome.ColorProfileViewer.desktop"
)

mkdir -p ~/.local/share/applications
for ENTRY in "${HIDE_DESKTOPS[@]}"; do
  TARGET_LOCAL="~/.local/share/applications/$ENTRY"
  eval TARGET_EXP="$TARGET_LOCAL"
  if [ ! -f "$TARGET_EXP" ]; then
    SYS_FILE="/usr/share/applications/$ENTRY"
    if [ -f "$SYS_FILE" ]; then
      cp "$SYS_FILE" "$TARGET_EXP"
      echo "NoDisplay=true" >> "$TARGET_EXP"
    fi
  fi
done

# Remove default npx stubs
echo -e "${BLUE}🧹 Removing default NPX wrapper stubs...${NC}"
rm -f ~/.local/bin/codex \
      ~/.local/bin/copilot \
      ~/.local/bin/opencode \
      ~/.local/bin/playwright-cli \
      ~/.local/bin/pi

# Remove web app and TUI shortcuts
if command -v omarchy-webapp-remove-all &>/dev/null; then
  echo -e "${BLUE}🌐 Removing preinstalled web app launchers...${NC}"
  omarchy-webapp-remove-all || true
fi

if command -v omarchy-tui-remove-all &>/dev/null; then
  echo -e "${BLUE}💻 Removing preinstalled TUI wrappers...${NC}"
  omarchy-tui-remove-all || true
fi

if command -v omarchy-restart-walker &>/dev/null; then
  omarchy-restart-walker 2>/dev/null || true
fi

echo -e "${GREEN}🎉 Default Omarchy/DHH preinstalled packages and launchers purged!${NC}"
