#!/bin/bash
set -euo pipefail

echo "Running health checks..."

systemctl daemon-reload

systemctl enable unifi-os
systemctl start unifi-os

sleep 10

systemctl status unifi-os || true

echo ""
echo "Running containers:"
podman ps || true

echo "Health checks complete."
