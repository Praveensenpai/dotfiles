#!/bin/bash

echo "Installing essential applications (mpv, anki, qbittorrent)..."

# Install mpv, anki, and qbittorrent via pacman --needed
sudo pacman -S --needed --noconfirm mpv anki qbittorrent

echo "✔ Essential applications (mpv, anki, qbittorrent) installed."
