#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_SCRIPTS="$WAYBAR_DIR/scripts"
WAYBAR_CONFIG="$WAYBAR_DIR/config.jsonc"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RS_DIR="$SCRIPT_DIR/network-status-rs"

mkdir -p "$WAYBAR_SCRIPTS"

echo "Building Rust Network bandwidth speed & vnstat status binary for Waybar..."

if command -v cargo &> /dev/null && [ -d "$RS_DIR" ]; then
    cargo build --release --manifest-path "$RS_DIR/Cargo.toml"
    cp "$RS_DIR/target/release/network-status-rs" "$WAYBAR_SCRIPTS/network-status-bin"
    chmod +x "$WAYBAR_SCRIPTS/network-status-bin"
    echo "✔ Rust network-status-bin compiled and installed."
else
    echo "⚠ Cargo or Rust source not found."
fi

if [ -f "$WAYBAR_CONFIG" ]; then
    sed -i 's|"exec": ".*network-status.*"|"exec": "~/.config/waybar/scripts/network-status-bin"|' "$WAYBAR_CONFIG"
    echo "✔ Network bandwidth speed & vnstat tooltips configured in Waybar."
fi
