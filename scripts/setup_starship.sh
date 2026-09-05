#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}${BOLD}"
echo "🌸 ========================================= 🌸"
echo "        Setting up Starship Prompt...         "
echo "🌸 ========================================= 🌸"
echo -e "${NC}"

# Install Starship if not already installed
if ! command -v starship &> /dev/null; then
    if command -v yay &> /dev/null; then
        echo -e "${CYAN}▶ Installing starship via yay...${NC}"
        yay -S --noconfirm starship
    elif command -v sudo &> /dev/null; then
        echo -e "${CYAN}▶ Installing starship via pacman...${NC}"
        sudo pacman -S --noconfirm --needed starship
    fi
fi

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# Deploy starship.toml with Nerd Font symbols & modules
STARSHIP_CONFIG="$HOME/.config/starship.toml"
echo -e "${CYAN}▶ Writing Starship configuration to ${YELLOW}$STARSHIP_CONFIG${CYAN}...${NC}"

cat << 'TOML_EOF' > "$STARSHIP_CONFIG"
add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status$rust$python$docker_context]($style)$character"

[character]
error_symbol = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$symbol$branch]($style) "
symbol = " "
style = "italic cyan"

[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""

[rust]
format = "[$symbol($version )]($style)"
symbol = "󱘗 "
style = "bold red"

[python]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold yellow"

[docker_context]
format = "[$symbol$context]($style) "
symbol = " "
style = "bold blue"
TOML_EOF

echo -e "${GREEN}✔ Configured starship.toml with Nerd Font symbols${NC}"

# Ensure Starship is initialized in ~/.bashrc
BASHRC="$HOME/.bashrc"
if ! grep -q "starship init bash" "$BASHRC"; then
    echo -e "${CYAN}▶ Adding Starship initialization to ${YELLOW}$BASHRC${CYAN}...${NC}"
    echo "" >> "$BASHRC"
    echo "# Starship Prompt" >> "$BASHRC"
    echo 'if command -v starship &> /dev/null; then' >> "$BASHRC"
    echo '    eval "$(starship init bash)"' >> "$BASHRC"
    echo 'fi' >> "$BASHRC"
    echo -e "${GREEN}✔ Added starship init to $BASHRC${NC}"
else
    echo -e "${GREEN}✔ Starship already initialized in $BASHRC${NC}"
fi

echo -e "\n${PURPLE}${BOLD}"
echo "✨ ========================================= ✨"
echo "       Starship setup complete! 🎉            "
echo "✨ ========================================= ✨"
echo -e "${NC}"
