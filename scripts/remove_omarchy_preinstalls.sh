#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}🗑️  Purging default Omarchy/DHH preinstalled applications and tooling...${NC}"

# List of DHH/Omarchy default packages to uninstall (excluding system deps like ibus/evince)
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
  gnome-calculator
  system-config-printer
  cups
  cups-filters
  cups-browsed
  cups-pdf
)

# Remove packages installed via pacman individually to prevent dependency blockages
for PKG in "${PKGS_TO_REMOVE[@]}"; do
  if pacman -Qq "$PKG" &>/dev/null; then
    echo -e "${BLUE}📦 Removing package: ${PKG}...${NC}"
    sudo pacman -Rns --noconfirm "$PKG" 2>/dev/null || sudo pacman -R --noconfirm "$PKG" 2>/dev/null || true
  fi
done

# Remove lingering desktop entry files in ~/.local/share/applications/
echo -e "${BLUE}🧹 Cleaning up orphaned desktop entries...${NC}"
rm -f ~/.local/share/applications/typora.desktop \
      ~/.local/share/applications/localsend.desktop \
      ~/.local/share/applications/org.freedesktop.IBus.Setup.desktop \
      ~/.local/share/applications/org.gnome.Evince.desktop

# Hide system launcher entries (Color Profile, IBus, Evince) without breaking system dependencies
HIDE_DESKTOPS=(
  "org.freedesktop.IBus.Setup.desktop"
  "gnome-color-panel.desktop"
  "org.gnome.ColorProfileViewer.desktop"
  "org.gnome.Evince.desktop"
)

mkdir -p ~/.local/share/applications
for ENTRY in "${HIDE_DESKTOPS[@]}"; do
  TARGET_LOCAL="$HOME/.local/share/applications/$ENTRY"
  SYS_FILE="/usr/share/applications/$ENTRY"
  
  if [ -f "$SYS_FILE" ]; then
    cp "$SYS_FILE" "$TARGET_LOCAL"
    if grep -q "^\[Desktop Entry\]" "$TARGET_LOCAL"; then
      sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$TARGET_LOCAL"
    else
      echo "NoDisplay=true" >> "$TARGET_LOCAL"
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

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications" &>/dev/null || true
fi

if command -v omarchy-restart-walker &>/dev/null; then
  omarchy-restart-walker 2>/dev/null || true
fi

echo -e "${GREEN}🎉 Default Omarchy/DHH preinstalled packages and launchers purged!${NC}"
