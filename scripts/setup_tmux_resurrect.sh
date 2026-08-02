#!/bin/bash
curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/tmux-resurrect-systemd/main/install.sh?v=$(date +%s)" | bash
