#!/bin/bash

# ANSI Color Tokens
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🎙️ Launching voicevox-linux-installer from GitHub...${NC}\n"

curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/voicevox-linux-installer/main/install.sh?v=$(date +%s)" | bash

if command -v voicevox-linux-installer >/dev/null 2>&1; then
    exec voicevox-linux-installer "$@"
fi
