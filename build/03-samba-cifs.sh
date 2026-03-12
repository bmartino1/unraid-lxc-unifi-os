#!/bin/bash
set -euo pipefail

source /tmp/build/unifi-os.env

mkdir -p /usr/local/sbin /etc/systemd/system /root

cat > /usr/local/sbin/mount-unraid-smb.sh <<'SCRIPT'
#!/bin/bash
set -euo pipefail

ENV_FILE="/root/.unifi-os-smb.env"
CREDS_FILE="/root/.smb-credentials"

if [ ! -f "$ENV_FILE" ]; then
  echo "SMB env file not found: $ENV_FILE"
  exit 0
fi

source "$ENV_FILE"

if [ "${SMB_MOUNT_ENABLED:-no}" != "yes" ]; then
  echo "SMB mount disabled"
  exit 0
fi

mkdir -p "$SMB_MOUNTPOINT"

if mountpoint -q "$SMB_MOUNTPOINT"; then
  echo "SMB already mounted at $SMB_MOUNTPOINT"
  exit 0
fi

mount -t cifs "$SMB_REMOTE" "$SMB_MOUNTPOINT" \
  -o "credentials=$CREDS_FILE,iocharset=utf8,vers=3.0,uid=0,gid=0,file_mode=0660,dir_mode=0770"
SCRIPT
chmod 700 /usr/local/sbin/mount-unraid-smb.sh

cat > /etc/systemd/system/unifi-os-smb-mount.service <<'SERVICE'
[Unit]
Description=Mount Unraid SMB share for UniFi OS exports/backups
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/mount-unraid-smb.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

cat > /root/.unifi-os-smb.env <<EOF_ENV
SMB_MOUNT_ENABLED="${SMB_MOUNT_ENABLED:-no}"
SMB_REMOTE="${SMB_REMOTE:-//tower/backups}"
SMB_MOUNTPOINT="${SMB_MOUNTPOINT:-/mnt/unraid-backups}"
EOF_ENV
chmod 600 /root/.unifi-os-smb.env

cat > /root/.smb-credentials <<EOF_CREDS
username=${SMB_USERNAME:-}
password=${SMB_PASSWORD:-}
domain=${SMB_DOMAIN:-WORKGROUP}
EOF_CREDS
chmod 600 /root/.smb-credentials

mkdir -p "${SMB_MOUNTPOINT:-/mnt/unraid-backups}"
systemctl enable unifi-os-smb-mount.service >/dev/null 2>&1 || true

echo "Installed optional SMB/CIFS mount helper"
