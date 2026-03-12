#!/bin/bash
set -euo pipefail

echo "==== podman version ===="
podman --version || true

echo "==== uosserver service ===="
systemctl status uosserver --no-pager || true

echo "==== listening sockets ===="
ss -tulpn || true
