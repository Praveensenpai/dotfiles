#!/bin/bash
curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/Praveensenpai/blesh-installer/main/install.sh?v=$(date +%s)" | bash
