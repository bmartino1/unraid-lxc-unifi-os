#!/bin/bash
set -euo pipefail

echo "Installing base dependencies..."

apt update

apt install -y \
curl \
wget \
ca-certificates \
gnupg \
lsb-release \
systemd \
podman \
slirp4netns \
uidmap \
dbus \
jq \
mc \
cifs-utils

echo "Dependencies installed."
