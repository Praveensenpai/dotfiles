#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d"
DNS_CONF="${RESOLVED_CONF_DIR}/dns.conf"

echo -e "${PURPLE}🌐 Setting up permanent high-performance DNS (Cloudflare / Quad9 / Google)...${NC}"

sudo mkdir -p "$RESOLVED_CONF_DIR"

sudo tee "$DNS_CONF" > /dev/null << 'EOF'
[Resolve]
DNS=1.1.1.1 9.9.9.9 8.8.8.8
FallbackDNS=1.0.0.1 8.8.4.4
Domains=~.
EOF

echo -e "${BLUE}⚙️  Restarting systemd-resolved service...${NC}"
sudo systemctl restart systemd-resolved

echo -e "${GREEN}✔ Permanent DNS configuration written to ${DNS_CONF}${NC}"
echo -e "${GREEN}🎉 High-performance DNS is now active and permanent!${NC}"
