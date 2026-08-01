#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🔥 Configuring UFW Firewall...${NC}"

# Check if ufw is installed
if ! command -v ufw &>/dev/null; then
    echo -e "${YELLOW}⚠️  UFW not found. Installing...${NC}"
    sudo pacman -S --needed --noconfirm ufw
fi

# Check if already enabled
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}✔ UFW is already active.${NC}"
    sudo ufw status verbose
    exit 0
fi

echo -e "${BLUE}⚙️  Applying sensible default rules...${NC}"

# Deny all incoming, allow all outgoing (safe defaults)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (so you don't lock yourself out)
sudo ufw allow ssh

echo -e "${BLUE}⚙️  Enabling UFW...${NC}"
sudo ufw --force enable

echo -e "${GREEN}✔ UFW is now active with the following rules:${NC}"
sudo ufw status verbose

echo -e "${GREEN}🎉 UFW firewall setup complete!${NC}"
