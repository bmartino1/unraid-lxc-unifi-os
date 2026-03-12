#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

source /tmp/build/unifi-os.env

if [ -z "${UNIFI_OS_URL:-}" ]; then
  echo "ERROR: UNIFI_OS_URL is empty in /tmp/build/unifi-os.env"
  exit 1
fi

if [ -z "${UNIFI_OS_FILENAME:-}" ]; then
  UNIFI_OS_FILENAME="unifi-os-server-linux-x64.bin"
fi

install -d -m 0755 /root/unifi-os-installer
wget -O "/root/unifi-os-installer/${UNIFI_OS_FILENAME}" "${UNIFI_OS_URL}"
chmod +x "/root/unifi-os-installer/${UNIFI_OS_FILENAME}"

if [ -n "${UNIFI_HOSTNAME:-}" ]; then
  hostnamectl set-hostname "${UNIFI_HOSTNAME}" || true
fi

# The official installer performs its own service and host integration.
# Run from a writable directory inside the LXC.
cd /root/unifi-os-installer
"/root/unifi-os-installer/${UNIFI_OS_FILENAME}" install

systemctl enable uosserver >/dev/null 2>&1 || true
systemctl restart uosserver || true

echo "Installed official UniFi OS Server binary"
