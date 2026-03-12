#!/bin/bash

echo "UniFi OS status"
echo "------------------------"

systemctl status unifi-os --no-pager

echo ""
echo "Running containers:"
podman ps

echo ""
echo "IP:"
hostname -I
