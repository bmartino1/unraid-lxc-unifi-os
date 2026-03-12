#!/bin/bash
set -euo pipefail

# Build helper for unRAID's LXC plugin.
# Creates a temporary Debian 12 LXC, runs scripts in ./build, and packs the result.

if [ ! -f /boot/config/plugins/lxc.plg ]; then
  echo "ERROR: LXC plugin not found!"
  exit 1
fi

LXC_PATH=$(grep "lxc.lxcpath" /boot/config/plugins/lxc/lxc.conf | cut -d '=' -f2)
LXC_PACKAGE_NAME="unifi-os"
LXC_PACKAGE_DIR="${LXC_PATH}/cache/build_cache_unifi_os"
LXC_DISTRIBUTION="debian"
LXC_RELEASE="bookworm"
LXC_ARCH="amd64"
LXC_BUILD_ROOT=$(cd "$(dirname "$0")" && pwd)

if echo "${LXC_PATH}" | grep -q "/mnt/user" ; then
  echo "ERROR: LXC path /mnt/user is not allowed!"
  exit 1
fi

if [ ! -f "${LXC_BUILD_ROOT}/build/unifi-os.env" ]; then
  echo "ERROR: Missing ${LXC_BUILD_ROOT}/build/unifi-os.env"
  echo "Copy build/unifi-os.env.example to build/unifi-os.env and edit it first."
  exit 1
fi

LXC_CONT_NAME=$(openssl rand -base64 24 | tr -dc 'a-z0-9' | cut -c -12)
mkdir -p "${LXC_PACKAGE_DIR}"

echo "Build time: $(date +"%Y-%m-%d %H:%M")" > "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log"

echo "Creating temporary container"
lxc-create --name "${LXC_CONT_NAME}" \
  --template download -- \
  --dist "${LXC_DISTRIBUTION}" \
  --release "${LXC_RELEASE}" \
  --arch "${LXC_ARCH}" > "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log"

echo "Generating build script list"
LXC_BUILD_FILES=$(ls -1 "${LXC_BUILD_ROOT}/build/" | grep "^[0-9][0-9]-" | sort)

echo "Starting temporary container"
lxc-start -n "${LXC_CONT_NAME}"
echo "Waiting 10 seconds for temporary container to come online"
sleep 10

echo "Copying build directory to container"
cp -R "${LXC_BUILD_ROOT}/build" "${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp/build"

echo "Executing build scripts in container"
IFS=$'\n'
for script in ${LXC_BUILD_FILES}; do
  echo "Executing ${script}"
  lxc-attach -n "${LXC_CONT_NAME}" -- bash -lc "chmod +x /tmp/build/${script} && /tmp/build/${script} 2>&1 | tee /tmp/${script%.*}.log"
  status=$?
  if [ "${status}" != "0" ]; then
    echo "ERROR: ${script} returned non-zero exit status"
    lxc-stop -k -n "${LXC_CONT_NAME}" 2>/dev/null || true
    lxc-destroy -n "${LXC_CONT_NAME}" || true
    exit 1
  fi
done

echo "Stopping temporary container"
lxc-stop -n "${LXC_CONT_NAME}" -t 15 2>/dev/null || true

echo "Copying over build logs"
for script in ${LXC_BUILD_FILES}; do
  cp "${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp/${script%.*}.log" "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log"
done

echo "Final cleanup"
cd "${LXC_PATH}/${LXC_CONT_NAME}"
find . -name ".bash_history" -exec rm {} \;
rm -rf "${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp"/*
sed -i '/# Container specific configuration/,$d' config

# keep package logs but remove build secrets copied into /tmp/build
rm -f "${LXC_PATH}/${LXC_CONT_NAME}/rootfs/root/.smb-credentials" || true

echo "Generating build.log"
cat \
  "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log" \
  "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log" > "${LXC_PACKAGE_DIR}/build.log"
rm -f \
  "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log" \
  "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log"

for script in ${LXC_BUILD_FILES}; do
  cat "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log" >> "${LXC_PACKAGE_DIR}/build.log"
  rm -f "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log"
done

echo "Packing container"
tar -cf - . | xz -9 --threads=$(nproc --all) > "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz"
md5sum "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz" | awk '{print $1}' > "${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz.md5"
echo "--------------------END--------------------" >> "${LXC_PACKAGE_DIR}/build.log"

echo "Stopping and destroying temporary container"
lxc-stop -k -n "${LXC_CONT_NAME}" 2>/dev/null || true
lxc-destroy -n "${LXC_CONT_NAME}" || true
