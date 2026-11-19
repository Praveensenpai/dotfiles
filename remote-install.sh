#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo -e "\033[1;35m🌸 Initializing your kawaii Omarchy setup...\033[0m"

RELEASE_URL="https://github.com/Praveensenpai/dotfiles/releases/latest/download/omarchy-dotfiles-x86_64-linux.tar.gz"
DEST_BIN="/tmp/omarchy-dotfiles"

echo -e "\033[0;36m✨ Downloading omarchy-dotfiles (x86_64) from GitHub Releases...\033[0m"
if curl -LsSf -H 'Cache-Control: no-cache' "$RELEASE_URL" 2>/dev/null | tar -xz -C /tmp omarchy-dotfiles 2>/dev/null; then
    chmod +x "$DEST_BIN"
    echo -e "\033[1;32m✔ Download and extraction complete. Launching Omarchy Dotfiles TUI...\033[0m\n"
    exec "$DEST_BIN" "$@"
fi

echo -e "\033[1;33m⚠ Prebuilt binary not reachable; cloning repository to build locally...\033[0m"
REPO_URL="https://github.com/Praveensenpai/dotfiles.git"
TARGET_DIR="${HOME}/dotfiles"

if [ ! -d "$TARGET_DIR" ]; then
    git clone "$REPO_URL" "$TARGET_DIR"
else
    git -C "$TARGET_DIR" pull
fi

cd "$TARGET_DIR"
cargo run --release -- "$@"
