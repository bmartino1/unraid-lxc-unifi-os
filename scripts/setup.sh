#!/bin/bash
###############################################################################
# scripts/setup.sh
# First run configuration
###############################################################################

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

echo ""
echo "UniFi OS Initial Setup"
echo "----------------------------------"

read -rp "Hostname [unifi-os]: " HOSTNAME
HOSTNAME=${HOSTNAME:-unifi-os}

read -rp "Timezone [UTC]: " TIMEZONE
TIMEZONE=${TIMEZONE:-UTC}

hostnamectl set-hostname "$HOSTNAME"

timedatectl set-timezone "$TIMEZONE"

systemctl restart systemd-logind

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "Setup complete."
echo ""
echo "Access UniFi OS:"
echo "https://${IP}:11443"
echo ""
echo "Admin tools located in:"
echo "/scripts"
echo ""
