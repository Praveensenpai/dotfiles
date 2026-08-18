#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

MODE="${1:-bonsai}"

echo -e "${PURPLE}${BOLD}🌸 ========================================= 🌸${NC}"
echo -e "${PURPLE}${BOLD}       Configuring Omarchy Screensaver...     ${NC}"
echo -e "${PURPLE}${BOLD}🌸 ========================================= 🌸${NC}\n"

# 1. Build and install cbonsai if not found
if ! command -v cbonsai &>/dev/null && [ ! -f "$HOME/.local/bin/cbonsai" ]; then
    echo -e "${BLUE}📦 Building and installing cbonsai from source...${NC}"
    BUILD_DIR="$(mktemp -d)"
    if git clone --depth 1 https://gitlab.com/jallbrit/cbonsai.git "$BUILD_DIR" >/dev/null 2>&1; then
        ( cd "$BUILD_DIR" && make >/dev/null 2>&1 && mkdir -p "$HOME/.local/bin" && cp cbonsai "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/cbonsai" )
        rm -rf "$BUILD_DIR"
        echo -e "${GREEN}✔ cbonsai installed to ~/.local/bin/cbonsai.${NC}"
    else
        echo -e "${YELLOW}⚠ Git clone failed. Attempting via yay...${NC}"
        yay -S --needed --noconfirm cbonsai || true
    fi
else
    echo -e "${GREEN}✔ cbonsai is installed.${NC}"
fi

# 2. Ensure ~/.local/bin exists and is on PATH
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/omarchy"

# 3. Write configuration file
CONFIG_FILE="$HOME/.config/omarchy/screensaver.conf"

if [ "$MODE" = "default" ] || [ "$MODE" = "ttfx" ]; then
    echo "MODE=ttfx" > "$CONFIG_FILE"
    echo -e "${GREEN}✔ Screensaver mode set to: default (ttfx ASCII art)${NC}"
elif [ "$MODE" = "test" ]; then
    echo -e "${CYAN}▶ Launching screensaver preview...${NC}"
    omarchy-launch-screensaver force >/dev/null 2>&1 || true
    exit 0
else
    echo "MODE=bonsai" > "$CONFIG_FILE"
    echo -e "${GREEN}✔ Screensaver mode set to: Zen Bonsai (cbonsai)${NC}"
fi

# 4. Deploy omarchy-screensaver wrapper
cat << 'EOF' > "$HOME/.local/bin/omarchy-screensaver"
#!/bin/bash

# Custom Omarchy Screensaver Runner (supports cbonsai & ttfx)
CONFIG_FILE="$HOME/.config/omarchy/screensaver.conf"
MODE="bonsai"

if [ -f "$CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

screensaver_in_focus() {
  hyprctl activewindow -j 2>/dev/null | jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
}

exit_screensaver() {
  hyprctl eval 'hl.config({ cursor = { invisible = false } })' &>/dev/null || hyprctl keyword cursor:invisible false &>/dev/null || true
  pkill -x cbonsai 2>/dev/null || true
  pkill -x ttfx 2>/dev/null || true
  pkill -f '[o]rg.omarchy.screensaver' 2>/dev/null || true
  exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

printf '\033]11;rgb:00/00/00\007'  # Black background

hyprctl eval 'hl.config({ cursor = { invisible = true } })' &>/dev/null || hyprctl keyword cursor:invisible true &>/dev/null

tty=$(tty 2>/dev/null)

wait_for_terminal_resize() {
  local deadline=$((SECONDS + 2))
  while ((SECONDS < deadline)) && [[ $(stty size 2>/dev/null) == "24 80" ]]; do
    sleep 0.02
  done
}

wait_for_terminal_resize

if [ "$MODE" = "bonsai" ] && (command -v cbonsai &>/dev/null || [ -x "$HOME/.local/bin/cbonsai" ]); then
  CBONSAI_BIN="$(command -v cbonsai || echo "$HOME/.local/bin/cbonsai")"
  
  while true; do
    "$CBONSAI_BIN" -S -m "🌸 禅 · ZEN 🌸" -t 0.02 -w 3 &
    CB_PID=$!

    while kill -0 "$CB_PID" 2>/dev/null; do
      if read -n1 -t 1 || ! screensaver_in_focus; then
        exit_screensaver
      fi
    done
  done
else
  # Default ttfx ASCII effects
  while true; do
    ttfx -i ~/.config/omarchy/branding/screensaver.txt \
      --frame-rate 120 --canvas-width 0 --canvas-height 0 --reuse-canvas --anchor-canvas c --anchor-text c \
      --random-effect --no-eol --no-restore-cursor &

    while pgrep -t "${tty#/dev/}" -x ttfx >/dev/null; do
      if read -n1 -t 1 || ! screensaver_in_focus; then
        exit_screensaver
      fi
    done
  done
fi
EOF

chmod +x "$HOME/.local/bin/omarchy-screensaver"
echo -e "${GREEN}✔ Screensaver wrapper deployed to ~/.local/bin/omarchy-screensaver.${NC}"
echo -e "${PURPLE}💡 Tip: Run './scripts/setup_screensaver.sh test' to preview anytime!${NC}\n"
