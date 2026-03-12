#!/bin/bash

set -euo pipefail

echo "Unraid SMB Mount Setup"

read -rp "Server (example tower): " SERVER
read -rp "Share name: " SHARE
read -rp "Username: " USER
read -rsp "Password: " PASS
echo ""

mkdir -p /mnt/unraid

echo "//$SERVER/$SHARE /mnt/unraid cifs username=$USER,password=$PASS,vers=3.0 0 0" >> /etc/fstab

mount -a

echo "Mounted at /mnt/unraid"
