#!/bin/bash

echo "============================="
echo "  Setting up Tmux & TPM Resurrect..."
echo "============================="

# 1. Install tmux
if ! command -v tmux &>/dev/null; then
    echo "▶ Installing tmux..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm tmux
    fi
fi

# 2. Clone TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "▶ Cloning TPM to $TPM_DIR..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "✔ TPM is already installed"
fi

# 3. Configure ~/.tmux.conf
TMUX_CONF="$HOME/.tmux.conf"
echo "▶ Configuring $TMUX_CONF..."

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
    echo "✔ Updated $TMUX_CONF"
else
    echo "✔ TPM plugins already declared in $TMUX_CONF"
fi

# 4. Automatically install TPM plugins non-interactively
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
    echo "▶ Installing tmux plugins via TPM..."
    "$TPM_DIR/bin/install_plugins" || true
fi

# 5. Create systemd user service for tmux auto-boot
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/tmux.service"
mkdir -p "$SERVICE_DIR"

if [ ! -f "$SERVICE_FILE" ]; then
    echo "▶ Creating systemd user service at $SERVICE_FILE..."
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
    echo "✔ Created $SERVICE_FILE"
fi

# 6. Enable and start tmux systemd user service
if command -v systemctl &>/dev/null; then
    echo "▶ Enabling and starting tmux user service..."
    systemctl --user enable --now tmux 2>/dev/null || true
fi

echo "============================="
echo "  Tmux setup complete!"
echo "============================="
