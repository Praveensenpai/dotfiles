#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}🔑 Setting up GitHub SSH Key Authentication...${NC}\n"

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
PUB_KEY="$SSH_KEY.pub"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$PUB_KEY" ]; then
    echo -e "${BLUE}⚙️  No existing SSH key found. Generating new Ed25519 SSH key...${NC}"
    ssh-keygen -t ed25519 -C "git@github.com" -f "$SSH_KEY" -N ""
    echo -e "${GREEN}✔ SSH key generated successfully at ${SSH_KEY}.${NC}\n"
else
    echo -e "${GREEN}✔ Existing SSH key found at ${PUB_KEY}.${NC}\n"
fi

# Ensure ssh-agent is running and key is loaded
eval "$(ssh-agent -s)" &>/dev/null || true
ssh-add "$SSH_KEY" &>/dev/null || true

PUB_KEY_CONTENT=$(cat "$PUB_KEY")

echo -e "${YELLOW}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}📋 STEP 1: Copy your Public SSH Key below:${NC}"
echo -e "${YELLOW}${BOLD}========================================================================${NC}\n"

echo -e "${CYAN}${BOLD}${PUB_KEY_CONTENT}${NC}\n"

echo -e "${YELLOW}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}🌐 STEP 2: Add to GitHub${NC}"
echo -e "${YELLOW}${BOLD}========================================================================${NC}"
echo -e "1. Open your browser and go to GitHub SSH Settings:"
echo -e "   👉 ${CYAN}https://github.com/settings/ssh/new${NC}"
echo -e "2. In the ${BOLD}Title${NC} box, type a friendly name (e.g. ${CYAN}Arch Linux Laptop${NC})."
echo -e "3. In the ${BOLD}Key type${NC} dropdown, keep ${CYAN}Authentication Key${NC} selected."
echo -e "4. Paste your key from Step 1 into the ${BOLD}Key${NC} box."
echo -e "5. Click ${GREEN}${BOLD}Add SSH Key${NC}.\n"

echo -e "${YELLOW}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}🧪 STEP 3: Verify Connection${NC}"
echo -e "${YELLOW}${BOLD}========================================================================${NC}"
echo -e "Run this command to test your SSH connection to GitHub:"
echo -e "   👉 ${CYAN}ssh -T git@github.com${NC}\n"
