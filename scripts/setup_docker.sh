#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🐳 Configuring Docker...${NC}"

# Enable docker.service if not already enabled
if systemctl is-enabled docker.service &>/dev/null; then
    echo -e "${GREEN}✔ docker.service is already enabled.${NC}"
else
    echo -e "${BLUE}⚙️  Enabling docker.service...${NC}"
    sudo systemctl enable --now docker.service
fi

# Enable docker.socket if not already enabled
if systemctl is-enabled docker.socket &>/dev/null; then
    echo -e "${GREEN}✔ docker.socket is already enabled.${NC}"
else
    echo -e "${BLUE}⚙️  Enabling docker.socket...${NC}"
    sudo systemctl enable --now docker.socket
fi

# Add current user to docker group if not already in it
if groups "$USER" | grep -q '\bdocker\b'; then
    echo -e "${GREEN}✔ User '${USER}' is already in the docker group.${NC}"
else
    echo -e "${BLUE}👤 Adding '${USER}' to the docker group...${NC}"
    sudo usermod -aG docker "$USER"
    echo -e "${YELLOW}⚠️  Log out and back in (or reboot) for docker group membership to take effect.${NC}"
fi

echo -e "${GREEN}🎉 Docker setup complete!${NC}"
