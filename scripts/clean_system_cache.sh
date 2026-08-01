#!/bin/bash

echo "============================="
echo "  Cleaning system cache..."
echo "============================="

# Clean package manager cache
if command -v yay &> /dev/null; then
    echo "▶ Cleaning yay/pacman package cache..."
    yay -Sc --noconfirm 2>/dev/null || true
elif command -v pacman &> /dev/null; then
    echo "▶ Cleaning pacman package cache..."
    sudo pacman -Sc --noconfirm 2>/dev/null || true
fi

# Clean systemd journal logs older than 7 days
if command -v journalctl &> /dev/null; then
    echo "▶ Vacuuming systemd journal logs (>7 days)..."
    sudo journalctl --vacuum-time=7d 2>/dev/null || true
fi

# Empty trash if trash-cli is installed
if command -v trash-empty &> /dev/null; then
    echo "▶ Emptying trash..."
    trash-empty 2>/dev/null || true
fi

echo "============================="
echo "  System cleanup complete!"
echo "============================="
