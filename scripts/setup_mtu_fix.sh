#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

IFACE="${1:-wlan0}"
MTU="${2:-1400}"
DISPATCHER_SCRIPT="/etc/NetworkManager/dispatcher.d/99-mtu.sh"

echo -e "${PURPLE}🔧 Setting up MTU fix for ${IFACE} (MTU=${MTU})...${NC}"

# Apply MTU immediately
echo -e "${BLUE}⚙️  Applying MTU=${MTU} to ${IFACE} now...${NC}"
sudo ip link set "$IFACE" mtu "$MTU"

# Create NetworkManager dispatcher script for persistence across reboots
echo -e "${BLUE}⚙️  Installing persistent NetworkManager dispatcher script...${NC}"
sudo tee "$DISPATCHER_SCRIPT" > /dev/null << EOF
#!/bin/bash
# Auto-set MTU on network interface up (fixes TCP connection resets)
if [ "\$2" = "up" ] && [ "\$1" = "${IFACE}" ]; then
    ip link set ${IFACE} mtu ${MTU}
fi
EOF

sudo chmod +x "$DISPATCHER_SCRIPT"

# Verify
CURRENT_MTU=$(cat /sys/class/net/"$IFACE"/mtu 2>/dev/null)
echo -e "${GREEN}✔ MTU is now: ${CURRENT_MTU}${NC}"
echo -e "${GREEN}✔ Dispatcher script installed at: ${DISPATCHER_SCRIPT}${NC}"
echo -e "${GREEN}🎉 MTU fix is now permanent — will apply on every boot/reconnect!${NC}"
