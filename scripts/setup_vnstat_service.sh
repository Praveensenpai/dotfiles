#!/bin/bash

# Ensure vnstat package is installed
if ! command -v vnstat &>/dev/null; then
    echo "Installing vnstat network traffic monitor..."
    sudo pacman -S --noconfirm vnstat
else
    echo "✔ vnstat is already installed."
fi

# Enable and start the vnstat background service
echo "Enabling and starting vnstat background service..."
sudo systemctl enable --now vnstat

echo "✔ vnstat daemon enabled and active."
