#!/bin/bash
###############################################################################
# scripts/setup.sh
# Initial configuration for UniFi OS LXC
###############################################################################

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

ENV_FILE="/root/unifi-os.env"

echo ""
echo "UniFi OS Initial Setup"
echo "----------------------------------"

read -rp "Hostname [unifi-os]: " HOSTNAME
HOSTNAME=${HOSTNAME:-unifi-os}

read -rp "Timezone [UTC]: " TIMEZONE
TIMEZONE=${TIMEZONE:-UTC}

echo ""

echo "Applying configuration..."

hostnamectl set-hostname "$HOSTNAME"
timedatectl set-timezone "$TIMEZONE"

systemctl restart systemd-logind

echo ""
echo "Setup complete."
echo ""
echo "Access UniFi OS at:"
echo "https://$(hostname -I | awk '{print $1}'):11443"
echo ""
