#!/bin/bash

echo "🌸 Disabling Bluetooth auto-power on boot..."

# Modify the AutoEnable policy in BlueZ config using sed
sudo sed -i 's/^#*AutoEnable=.*/AutoEnable=false/' /etc/bluetooth/main.conf

# Restart the service so the policy applies immediately during install
sudo systemctl restart bluetooth

echo "✨ Bluetooth is now disabled by default!"
