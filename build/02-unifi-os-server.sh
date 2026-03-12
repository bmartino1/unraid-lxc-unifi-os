#!/bin/bash
set -euo pipefail

ENV_FILE="/root/unifi-os.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

echo "Installing UniFi OS Server..."

cd /tmp

wget -O unifi-os.deb "$UNIFI_OS_DOWNLOAD"

apt install -y ./unifi-os.deb

systemctl enable unifi-os

echo "UniFi OS installed."
