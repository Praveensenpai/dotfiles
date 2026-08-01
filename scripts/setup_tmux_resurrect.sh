#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "🌸 ========================================= 🌸"
echo "        Setting up Tmux & TPM Resurrect...   "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# 1. Install tmux
if ! command -v tmux &>/dev/null; then
    echo -e "${CYAN}▶ Installing tmux...${NC}"
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm tmux
    fi
fi

# 2. Clone TPM & plugins (tmux-resurrect, tmux-continuum)
PLUGINS_DIR="$HOME/.tmux/plugins"
mkdir -p "$PLUGINS_DIR"

TPM_DIR="$PLUGINS_DIR/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo -e "${CYAN}▶ Cloning TPM to ${YELLOW}$TPM_DIR${CYAN}...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo -e "${GREEN}✔ TPM is already installed${NC}"
fi

RESURRECT_DIR="$PLUGINS_DIR/tmux-resurrect"
if [ ! -d "$RESURRECT_DIR" ]; then
    echo -e "${CYAN}▶ Cloning tmux-resurrect to ${YELLOW}$RESURRECT_DIR${CYAN}...${NC}"
    git clone https://github.com/tmux-plugins/tmux-resurrect "$RESURRECT_DIR"
else
    echo -e "${GREEN}✔ tmux-resurrect is already installed${NC}"
fi

CONTINUUM_DIR="$PLUGINS_DIR/tmux-continuum"
if [ ! -d "$CONTINUUM_DIR" ]; then
    echo -e "${CYAN}▶ Cloning tmux-continuum to ${YELLOW}$CONTINUUM_DIR${CYAN}...${NC}"
    git clone https://github.com/tmux-plugins/tmux-continuum "$CONTINUUM_DIR"
else
    echo -e "${GREEN}✔ tmux-continuum is already installed${NC}"
fi

# 3. Configure ~/.tmux.conf
TMUX_CONF="$HOME/.tmux.conf"
echo -e "${CYAN}▶ Configuring ${YELLOW}$TMUX_CONF${CYAN}...${NC}"

# Create tmux.conf if missing or add TPM lines if not present
if ! grep -q "tmux-plugins/tpm" "$TMUX_CONF" 2>/dev/null; then
    cat << 'EOF' >> "$TMUX_CONF"

# --- TPM & Resurrect/Continuum Config ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Automatic restore on tmux start
set -g @continuum-restore 'on'

# Initialize TMUX plugin manager (keep at bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
    echo -e "${GREEN}✔ Updated $TMUX_CONF${NC}"
else
    echo -e "${GREEN}✔ TPM plugins already declared in $TMUX_CONF${NC}"
fi

# 4. Automatically install TPM plugins non-interactively
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
    echo -e "${CYAN}▶ Installing tmux plugins via TPM...${NC}"
    "$TPM_DIR/bin/install_plugins" || true
fi

# 5. Create systemd user service for tmux auto-boot
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/tmux.service"
mkdir -p "$SERVICE_DIR"

if [ ! -f "$SERVICE_FILE" ]; then
    echo -e "${CYAN}▶ Creating systemd user service at ${YELLOW}$SERVICE_FILE${CYAN}...${NC}"
    cat << 'EOF' > "$SERVICE_FILE"
[Unit]
Description=tmux main terminal multiplexer
Documentation=man:tmux(1)

[Service]
Type=forking
ExecStart=/usr/bin/tmux new-session -s default -d
ExecStop=/usr/bin/tmux kill-server

[Install]
WantedBy=default.target
EOF
    echo -e "${GREEN}✔ Created $SERVICE_FILE${NC}"
fi

# 6. Enable and start tmux systemd user service
if command -v systemctl &>/dev/null; then
    echo -e "${CYAN}▶ Enabling and starting tmux user service...${NC}"
    systemctl --user enable --now tmux 2>/dev/null || true
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "         Tmux setup complete! 🎉             "
echo "✨ ========================================= ✨"
echo -e "${NC}"
