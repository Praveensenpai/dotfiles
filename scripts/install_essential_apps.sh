#!/bin/bash

echo "Installing essential applications (mpv, anki, qbittorrent, wget)..."

# Install mpv, anki, qbittorrent, and wget via pacman --needed
sudo pacman -S --needed --noconfirm mpv anki qbittorrent wget

echo "✔ Essential applications (mpv, anki, qbittorrent, wget) installed."
