#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SYSCTL_CONF="/etc/sysctl.d/99-tcp-keepalive.conf"

echo -e "${PURPLE}🔌 Setting up TCP Keepalive tuning (60s time / 10s intvl / 6 probes)...${NC}"

# Apply immediately
echo -e "${BLUE}⚙️  Applying sysctl TCP keepalive parameters...${NC}"
sudo sysctl -w net.ipv4.tcp_keepalive_time=60 \
            net.ipv4.tcp_keepalive_intvl=10 \
            net.ipv4.tcp_keepalive_probes=6 > /dev/null

# Persist across reboots
echo -e "${BLUE}⚙️  Writing persistent configuration to ${SYSCTL_CONF}...${NC}"
sudo tee "$SYSCTL_CONF" > /dev/null << 'EOF'
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
EOF

echo -e "${GREEN}✔ TCP Keepalive tuning is active and written to ${SYSCTL_CONF}${NC}"
echo -e "${GREEN}🎉 TCP connections will now stay alive through long SSE streams!${NC}"
