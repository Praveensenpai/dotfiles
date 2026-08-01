#!/bin/bash

echo "============================="
echo "  Setting up modern CLI tools..."
echo "============================="

# Install eza and bat if not installed
if ! command -v eza &> /dev/null || ! command -v bat &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo "▶ Installing eza and bat via yay..."
        yay -S --noconfirm eza bat
    fi
fi

BASHRC="$HOME/.bashrc"

# Add aliases for eza and bat
if ! grep -q "alias ls='eza" "$BASHRC"; then
    echo "▶ Adding eza and bat aliases to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Modern CLI Tool Aliases" >> "$BASHRC"
    echo "alias ls='eza --icons --group-directories-first'" >> "$BASHRC"
    echo "alias ll='eza -la --icons --group-directories-first'" >> "$BASHRC"
    echo "alias cat='bat --style=plain'" >> "$BASHRC"
    echo "✔ Added aliases to $BASHRC"
else
    echo "✔ CLI tool aliases already exist in $BASHRC"
fi

echo "============================="
echo "  CLI tools setup complete!"
echo "============================="
