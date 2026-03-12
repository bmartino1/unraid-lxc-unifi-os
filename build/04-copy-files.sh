#!/bin/bash
set -euo pipefail

cp /tmp/build/unifi-os.env /root/unifi-os.env.build-input
cp /usr/local/sbin/mount-unraid-smb.sh /root/mount-unraid-smb.sh
chmod 700 /root/mount-unraid-smb.sh

echo "Copied helper files to /root"
