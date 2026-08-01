#!/bin/bash

echo "============================="
echo "  Setting up ble.sh for Bash..."
echo "============================="

BASHRC="$HOME/.bashrc"

# Check if blesh is installed via yay/pacman or binary
if command -v blesh &> /dev/null || [ -f "$HOME/.local/share/blesh/ble.sh" ] || [ -f "/usr/share/blesh/ble.sh" ]; then
    echo "✔ ble.sh is already installed"
else
    if command -v yay &> /dev/null; then
        echo "▶ Installing blesh-git via yay..."
        yay -S --noconfirm blesh-git
    else
        echo "▶ Downloading pre-built ble.sh..."
        mkdir -p "$HOME/.local/share"
        TMP_DIR=$(mktemp -d)
        curl -sL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJ -C "$TMP_DIR"
        rm -rf "$HOME/.local/share/blesh"
        mv "$TMP_DIR/ble-nightly" "$HOME/.local/share/blesh"
        rm -rf "$TMP_DIR"
    fi
fi

# Detect blesh installation location for .bashrc
BLE_PATH=""
if [ -f "/usr/share/blesh/ble.sh" ]; then
    BLE_PATH="/usr/share/blesh/ble.sh"
elif [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    BLE_PATH="$HOME/.local/share/blesh/ble.sh"
fi

# Ensure ble.sh is sourced in ~/.bashrc for interactive shells
if [ -n "$BLE_PATH" ] && ! grep -q "blesh/ble.sh" "$BASHRC"; then
    echo "▶ Adding ble.sh to $BASHRC..."
    sed -i "/\[\[ \$- != \*i\* \]\] && return/a \\n# Bash Line Editor (ble.sh)\n[[ \$- == *i* ]] && source $BLE_PATH" "$BASHRC"
    echo "✔ Added ble.sh source line to $BASHRC"
else
    echo "✔ ble.sh configuration up-to-date in $BASHRC"
fi

echo "============================="
echo "  ble.sh setup complete!"
echo "============================="
