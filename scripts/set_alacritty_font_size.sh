#!/bin/bash

# Update Alacritty font size to 10
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    echo "Updating Alacritty font size in $ALACRITTY_CONF..."
    if grep -q "^size =" "$ALACRITTY_CONF"; then
        sed -i 's/^size = .*/size = 10/' "$ALACRITTY_CONF"
    else
        echo "size = 10" >> "$ALACRITTY_CONF"
    fi
    echo "✔ Alacritty font size set to 10."
else
    echo "⚠ $ALACRITTY_CONF not found. Creating..."
    mkdir -p "$(dirname "$ALACRITTY_CONF")"
    cat << 'EOF' > "$ALACRITTY_CONF"
[font]
size = 10
EOF
    echo "✔ Alacritty config created."
fi
