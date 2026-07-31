#!/bin/bash

echo "============================="
echo "  Setting up dotfiles..."
echo "============================="

# Ask for sudo password up front
echo "🔒 Sudo authentication required to proceed:"
sudo -v || exit 1

# Keep-alive: update existing sudo time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# Ensure scripts directory exists
if [ ! -d "scripts" ]; then
    echo "Error: 'scripts' directory not found!"
    exit 1
fi

# Run all executable .sh files in the scripts directory
for script in scripts/*.sh; do
    if [ -x "$script" ]; then
        echo "▶ Running $script..."
        "$script"
        echo "✔ Finished $script"
        echo "-----------------------------"
    else
        echo "⏭ Skipping $script (not executable)"
    fi
done

echo "============================="
echo "  All scripts completed!"
echo "============================="