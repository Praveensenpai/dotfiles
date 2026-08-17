#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${PURPLE}☕ Installing Java JDK 21 (LTS)...${NC}"

echo -e "${BLUE}📦 Installing JDK 21 via pacman...${NC}"
sudo pacman -Sy --needed --noconfirm jdk21-openjdk

echo -e "${BLUE}🔧 Setting JDK 21 as default Java version...${NC}"
sudo archlinux-java set java-21-openjdk

echo -e "${GREEN}🎉 Java JDK 21 installed! Version: $(java -version 2>&1 | head -1)${NC}"
