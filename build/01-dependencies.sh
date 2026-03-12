#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  wget \
  gnupg \
  jq \
  nano \
  podman \
  slirp4netns \
  uidmap \
  fuse-overlayfs \
  containernetworking-plugins \
  cifs-utils \
  smbclient \
  unzip \
  rsync \
  acl \
  systemd \
  dbus \
  dbus-user-session

systemctl enable podman.service >/dev/null 2>&1 || true

echo "Completed base dependencies and Podman prerequisites"
