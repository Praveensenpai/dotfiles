#!/bin/bash

echo "============================="
echo "  Setting up agy-ls (AGY Session Picker)..."
echo "============================="

# 1. Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# 2. Copy agy-ls script to ~/.local/bin
SCRIPT_SRC="$(dirname "$0")/agy-ls"
TARGET="$HOME/.local/bin/agy-ls"

if [ -f "$SCRIPT_SRC" ]; then
    echo "▶ Installing agy-ls to $TARGET..."
    cp "$SCRIPT_SRC" "$TARGET"
    chmod +x "$TARGET"
    echo "✔ Installed agy-ls executable"
fi

# 3. Configure alias in ~/.bashrc
BASHRC="$HOME/.bashrc"
if ! grep -q "alias agy-ls=" "$BASHRC"; then
    echo "▶ Adding agy-ls alias to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Antigravity CLI Session Picker Alias" >> "$BASHRC"
    echo "alias agy-ls='$HOME/.local/bin/agy-ls'" >> "$BASHRC"
    echo "✔ Configured agy-ls alias in $BASHRC"
else
    echo "✔ agy-ls alias already exists in $BASHRC"
fi

echo "============================="
echo "  agy-ls setup complete!"
echo "============================="
