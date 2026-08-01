#!/bin/bash

# Ensure trash-cli package is installed
if ! command -v trash-put &>/dev/null; then
    echo "Installing trash-cli package..."
    sudo pacman -S --noconfirm trash-cli
else
    echo "✔ trash-cli is already installed."
fi

# Add alias rm='trash-put' to ~/.bashrc
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if ! grep -q "alias rm='trash-put'" "$BASHRC"; then
        echo "Adding alias rm='trash-put' to $BASHRC..."
        echo -e "\nalias rm='trash-put'" >> "$BASHRC"
        echo "✔ Alias added to $BASHRC."
    else
        echo "✔ Alias rm='trash-put' already exists in $BASHRC."
    fi
fi

# Add alias rm='trash-put' to ~/.zshrc if it exists
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -q "alias rm='trash-put'" "$ZSHRC"; then
        echo "Adding alias rm='trash-put' to $ZSHRC..."
        echo -e "\nalias rm='trash-put'" >> "$ZSHRC"
        echo "✔ Alias added to $ZSHRC."
    else
        echo "✔ Alias rm='trash-put' already exists in $ZSHRC."
    fi
fi
