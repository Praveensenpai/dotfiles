#!/bin/bash
echo "Installing & running omarchy-debloat Rust utility..."
curl -fsSL https://raw.githubusercontent.com/Praveensenpai/omarchy-debloat/main/install.sh | bash
if command -v omarchy-debloat &>/dev/null; then
    omarchy-debloat --all
fi
