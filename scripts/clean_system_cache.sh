#!/bin/bash

echo "============================="
echo "  Cleaning system cache (Fast)..."
echo "============================="

# Fast package cache clean
if command -v yay &> /dev/null; then
    echo "▶ Cleaning package cache..."
    yay -Sc --noconfirm 2>/dev/null || true
fi

# Fast systemd journal log vacuum (cap at 50MB)
if command -v journalctl &> /dev/null; then
    echo "▶ Vacuuming systemd journal logs (50MB cap)..."
    sudo journalctl --vacuum-size=50M 2>/dev/null || true
fi

# Instant trash empty (bulk remove without slow file iteration)
if [ -d "$HOME/.local/share/Trash" ]; then
    echo "▶ Instantly emptying trash..."
    rm -rf "$HOME/.local/share/Trash/files/"* "$HOME/.local/share/Trash/info/"* 2>/dev/null || true
fi

echo "============================="
echo "  System cleanup complete!"
echo "============================="
