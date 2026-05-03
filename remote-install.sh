#!/bin/bash
set -e

# Configuration
REPO_URL="https://github.com/Praveensenpai/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

echo "🌸 Initializing your kawaii setup..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed! Please install git first."
    exit 1
fi

# Clone or Update the repository
if [ ! -d "$TARGET_DIR" ]; then
    echo "✨ Cloning dotfiles to $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "🎀 Dotfiles folder already exists at $TARGET_DIR."
    echo "🔄 Pulling the latest changes..."
    cd "$TARGET_DIR"
    git pull
fi

# Run the master installer
echo "🪄 Launching the master installer..."
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh
