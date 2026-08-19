#!/bin/bash

CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}📺 Installing & configuring Anime4K (Low GPU, Mode A) for mpv via anime4k-cli...${NC}\n"

# Default to auto-applying Low GPU preset with Mode A unless custom flags are passed
ARGS=("$@")
if [ $# -eq 0 ]; then
    ARGS=("install" "--preset" "low" "--mode" "a" "--yes")
fi

curl -4 -fsSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/anime4k-cli/main/install.sh?v=$(date +%s)" | sh -s -- "${ARGS[@]}"