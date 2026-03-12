#!/bin/bash
set -euo pipefail

echo "Copying admin scripts..."

mkdir -p /scripts

cp -r /tmp/repo/scripts/* /scripts/

chmod +x /scripts/*.sh

echo "Scripts installed to /scripts"
