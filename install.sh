#!/bin/bash

echo "============================="
echo "  Setting up dotfiles..."
echo "============================="

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