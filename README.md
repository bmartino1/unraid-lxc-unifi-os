WIP


# unraid-lxc-unifi-os

Unofficial unRAID LXC template and build scripts for **UniFi OS Server** on a **privileged Debian 12 LXC**.
This repository is the successor to `bmartino1/unraid-lxc-unifi` and is meant to follow Ubiquiti's move from the legacy UniFi Network Server to **UniFi OS Server**.

Ubiquiti's current self-hosting documentation says UniFi OS Server only self-hosts UniFi Network plus key UniFi OS features, and that Protect, Access, Talk, Connect, and other UniFi applications must still run on a compatible UniFi Console...

## What this repo does

- Builds a Debian 12 / amd64 LXC archive for the unRAID LXC plugin.
- Installs the **official UniFi OS Server Linux binary** inside the container.
- Installs the host-side requirements Ubiquiti lists for Linux self-hosting:
  - `systemd`
  - `podman`
  - `slirp4netns`
- Keeps the LXC **privileged** because UniFi OS Server depends on host cgroup access.
- Installs **CIFS / SMB client tooling** so the container can mount an Unraid share for backups or exported data.

## Important limitation: UniFi Protect

**UniFi OS Server only self-hosts UniFi Network plus key UniFi OS features**, and that **Protect, Access, Talk, Connect, and other UniFi applications must still run on a compatible UniFi Console**.

That means this LXC can still mount SMB storage for things like:

- exported backups
- off-box archives
- migration files
- general admin data

But it does **not** claim to self-host Protect recording storage. nor implement. This is for unfi os and netowrk only! untill unifi give the realease and go ahead for self hosted protect once more.

## Upstream references

- Old repo base: `https://github.com/bmartino1/unraid-lxc-unifi`
- Official download page: `https://ui.com/download/software/unifi-os-server`
- Official announcement: `https://blog.ui.com/article/introducing-unifi-os-server`
- Official self-hosting guide: `https://help.ui.com/hc/en-us/articles/34210126298775-Self-Hosting-UniFi`
- Docker adaptation reference used for structure ideas: `https://github.com/lemker/unifi-os-server`

## Current design

This repo intentionally installs the **official Ubiquiti binary** rather than trying to rebuild the image from extracted container layers.

Why:

- Ubiquiti explicitly documents Linux self-hosting around the official installer.
- The official package manages the `uosserver` systemd service and host integration.
- Ubiquiti states UniFi OS Server is **not** offered as a normal standalone Docker/Podman container.

## Build-time input required

Ubiquiti's download page is JavaScript-driven and the direct Linux download URL changes by release.
Because of that, the builder uses a small config file instead of trying to scrape the release URL.

Edit this file before building:

WIP - a setup.sh scrip-t and env... will alter be avilabed at LXC root...
`build/unifi-os.env`

Example:

```bash
UNIFI_OS_URL="https://fw-download.ubnt.com/data/unifi-os-server/<current-linux-x64-installer>"
UNIFI_OS_FILENAME="unifi-os-server-linux-x64.bin"
UNIFI_HOSTNAME="unifi-os"
SMB_MOUNT_ENABLED="no"
SMB_REMOTE="//tower/backups"
SMB_MOUNTPOINT="/mnt/unraid-backups"
SMB_USERNAME=""
SMB_PASSWORD=""
SMB_DOMAIN="WORKGROUP"
```

## LXC distribution info

- Debian 12 (bookworm)
- amd64
- privileged container

## Install template on unRAID

1. Download the XML template:
   ```bash
   wget -O /tmp/lxc_container_template.xml https://raw.githubusercontent.com/bmartino1/unraid-lxc-unifi-os/main/lxc_container_template.xml
   ```
2. In unRAID, open:
   ```text
   http://<UNRAID-IP>/LXCAddTemplate
   ```
3. Import the template and apply.
4. Start the container.
5. Open the UniFi OS Server UI:
   ```text
   https://<container-ip>:11443
   ```

## First boot notes

After the LXC is created, the UniFi OS Server service should be managed with standard systemd commands inside the container:

```bash
systemctl status uosserver
systemctl restart uosserver
systemctl enable uosserver
```

## SMB helper

If `SMB_MOUNT_ENABLED="yes"` is configured in `build/unifi-os.env`, the build installs a systemd mount helper that will attempt to mount your Unraid SMB share at boot.

The helper is intended for:

- backups
- exports
- migration files

Not for unsupported Protect recording claims.

## Repository layout

- `createLXCarchive.sh` - local unRAID build helper for generating the LXC archive
- `lxc_container_template.xml` - unRAID LXC template
- `build/` - provisioning scripts copied into the temporary build container
- `notes.txt` - maintenance notes and upstream caveats
- `ubiquiti.256x256.png` - icon for template use

## Disclaimer

This is an **unofficial** community project. It is not endorsed by Ubiquiti, Lime Technology, the unRAID LXC plugin maintainer, or the authors of the Docker adaptation referenced above.
