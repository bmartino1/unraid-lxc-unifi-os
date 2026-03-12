#!/bin/bash

echo "UniFi OS Status"
echo "--------------------------------"

systemctl status unifi-os --no-pager

echo ""
echo "Running containers:"
podman ps

echo ""
echo "IP Address:"
hostname -I
