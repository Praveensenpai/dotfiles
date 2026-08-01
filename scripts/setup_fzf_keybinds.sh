#!/bin/bash

echo "============================="
echo "  Setting up fzf keybindings..."
echo "============================="

if ! command -v fzf &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo "▶ Installing fzf via yay..."
        yay -S --noconfirm fzf
    fi
fi

BASHRC="$HOME/.bashrc"

if ! grep -q "fzf/key-bindings.bash" "$BASHRC"; then
    echo "▶ Adding fzf keybindings to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# fzf Keybindings & Completion" >> "$BASHRC"
    echo '[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash' >> "$BASHRC"
    echo '[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash' >> "$BASHRC"
    echo "✔ Added fzf keybindings to $BASHRC"
else
    echo "✔ fzf keybindings already configured in $BASHRC"
fi

echo "============================="
echo "  fzf setup complete!"
echo "============================="
