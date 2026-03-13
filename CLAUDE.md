# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Linux kernel 4.19.81 for **OnePlus 8 (instantnoodle)** — Qualcomm Snapdragon 865 (Kona), ARM64. This is an Ubuntu Touch port built on top of the ElementalX kernel (upstream: `flar2/OnePlus8`). The port uses the **Halium 10** (Android 10) abstraction layer to run Ubuntu Touch on Android hardware.

**Current status:** Boots and runs Ubuntu Touch (Noble 24.04). WiFi, Bluetooth, and partial camera working. AppArmor security patches are an active area of work.

## Repository Layout

- **Main branch:** `ElementalX-1.00` (upstream ElementalX kernel, untouched baseline)
- **Working branch:** `Halium-10` (Ubuntu Touch / Halium port with all patches)
- **Remotes:** `origin` = scotthowson's fork, `upstream` = flar2/OnePlus8
- **Defconfig:** `arch/arm64/configs/halium-instantnoodle_ubuntu_defconfig` (~6200 lines)
- **AppArmor patches:** `security/apparmor/` — 13 files modified from upstream with UBUNTU SAUCE patches
- **Halium binder patches:** `drivers/android/binder.c` — gbinder workarounds, txn_security_ctx flag ignore, async oneway queue changes

## Build System

Builds happen inside a Docker container (`Ubuntu-20.04`). The kernel is NOT built directly from this repo's root.

### Docker Environment

- **Docker builder repo:** `/home/howson/Documents/Github/Portable-Docker-Ubuntu/`
- **Start container:** `docker compose up -d` (from the builder repo)
- **Enter container:** `docker exec -it --workdir /Android-10-Halium/OnePlus Ubuntu-20.04 /bin/bash`
- **Container mounts:** Host directory is mounted at `/Android-10-Halium/OnePlus` inside the container

### Build Process (inside Docker container)

The build overlay directory is at: `/home/howson/Documents/UbuntuTouch/OnePlus8/Android-11/build_kernel_instantnoodle/`

1. **`./build.sh -b Instantnoodle`** — Main entry point. Sources `build.conf`, clones build tools from UBports generic adaptation repo, clones the adaptation overlay, then runs the UBports build system.
2. Build tools are fetched from: `https://gitlab.com/ubports/community-ports/halium-generic-adaptation-build-tools` (main branch)
3. Adaptation overlay: `https://github.com/scotthowson/oneplus8_ubuntu_adaptation` (branch: `a10-testing`)

### Key Build Config (`build.conf`)

- `MAKE_CORES=16`
- `HAS_DYNAMIC_PARTITIONS=true`
- `RENAME_UBUNTU=true` (rootfs.img → ubuntu.img, required for correct partition mounting)
- `INCLUDE_VBMETA=true`
- `INCLUDE_RECOVERY_PARTITION=true`

### Image Creation (after kernel build)

```bash
./build/prepare-fake-ota.sh out/device_instantnoodle_usrmerge.tar.xz ota
./build/system-image-from-ota.sh ota/ubuntu_command Images/instantnoodle-a10
```

Produces: `boot.img`, `system.img`, `rootfs.img` (renamed to `ubuntu.img`) in `Images/instantnoodle-a10/`

### Kernel-Only Build (standalone)

```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-androidkernel-
export CC=clang
make halium-instantnoodle_ubuntu_defconfig
make -j16
```

Compiler: Clang 10.0.5 (Android prebuilts). Output: `arch/arm64/boot/Image`

## Device Info (`deviceinfo`)

- **Codename:** instantnoodle
- **Halium version:** 10
- **Boot image header:** v2
- **Page size:** 4096
- **Kernel cmdline includes:** `selinux=0 apparmor=1 security=apparmor systempart=/dev/mapper/system_a console=tty0`
- **Prebuilt DTB:** `oneplus-instantnoodle-instantnoodle.dtb`
- **Prebuilt DTBO:** `oneplus-instantnoodle-dtbo.img`
- **Ubuntu Touch release:** Noble (24.04)

## Critical Kernel Config Areas

### AppArmor (Default LSM)
```
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=0
CONFIG_SECURITY_APPARMOR_HASH=y
CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y
CONFIG_DEFAULT_SECURITY="apparmor"
```
AppArmor is the default LSM but boot param defaults to 0 — enabled via cmdline `apparmor=1`. SELinux is disabled via cmdline `selinux=0`.

### Android Binder (Halium IPC)
```
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder,puddlejumper,vndpuddlejumper,hwpuddlejumper,anbox-binder,anbox-hwbinder,anbox-vndbinder"
CONFIG_ANDROID_PARANOID_NETWORK=n
```

### Filesystem & Encryption (24.04 compatibility)
```
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_PFK=y
CONFIG_CRYPTO_DEV_QCOM_ICE=y
```

### Halium Required Configs
```
CONFIG_DEVTMPFS=y
CONFIG_FHANDLE=y
CONFIG_SYSVIPC=y
CONFIG_IPC_NS=y
CONFIG_NET_NS=y
CONFIG_PID_NS=y
CONFIG_USER_NS=y
CONFIG_UTS_NS=y
CONFIG_VT=y
```

## Patch History & Conventions

- **UBUNTU: SAUCE:** prefix denotes Ubuntu-specific patches not from upstream Linux (e.g., AppArmor fixes for ptrace, hash printing)
- **(halium)** prefix denotes Halium-specific binder/Android compatibility patches
- Defconfig changes are committed directly to the defconfig file, not via `make savedefconfig`
- Reference device for similar patches: OnePlus Nord N10 (billie) — `https://gitlab.com/ubports/porting/community-ports/android10/oneplus-nord-n10/oneplus-billie/`

## Key Documentation

- UBports standalone kernel build: https://docs.ubports.com/en/latest/porting/build_and_boot/standalone_kernel_build.html
- UBports image creation: https://docs.ubports.com/en/latest/porting/build_and_boot/standalone_kernel_install.html
- Halium porting guide: https://docs.ubports.com/en/latest/porting/
