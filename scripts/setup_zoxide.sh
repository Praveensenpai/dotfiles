#!/bin/bash

echo "============================="
echo "  Setting up zoxide (Smart cd)..."
echo "============================="

if ! command -v zoxide &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo "▶ Installing zoxide via yay..."
        yay -S --noconfirm zoxide
    fi
fi

BASHRC="$HOME/.bashrc"

if ! grep -q "zoxide init bash" "$BASHRC"; then
    echo "▶ Adding zoxide initialization to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Zoxide Smart Navigation" >> "$BASHRC"
    echo 'eval "$(zoxide init bash)"' >> "$BASHRC"
    echo 'alias cd="z"' >> "$BASHRC"
    echo "✔ Configured zoxide in $BASHRC"
else
    echo "✔ zoxide already configured in $BASHRC"
fi

echo "============================="
echo "  zoxide setup complete!"
echo "============================="
