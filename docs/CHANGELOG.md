# What changed in this kernel

OnePlus 8 (instantnoodle, SM8250 "kona") Linux 4.19 kernel for Ubuntu Touch 24.04 on
Halium 10 (Android 10 vendor).  Base tree: OnePlus Oxygen OS 10 kernel source (4.19.81,
CAF `LA.UM.8.12`) as shipped in ElementalX 1.00.

Branches:

| Branch | Role |
|---|---|
| `Halium-10` | Ubuntu Touch development branch. This is what `deviceinfo_kernel_source_branch` in the build repo points at. |
| `Halium-10-stable` | `Halium-10` plus the linux-stable 4.19 series, merged in chunks (see below). Folds back into `Halium-10` once it has booted on the device. |
| `ElementalX-3.00` | Reference only: OnePlus Oxygen OS 12 kernel source (4.19.157). Not built. |

Build: `halium-instantnoodle_ubuntu_defconfig`, clang, `Image.gz` + `dtbs`; the device
trees and overlays come from the kernel source (`vendor/qcom/kona*.dtb`,
`vendor/qcom/instantnoodle-overlay-{t0,evt1,dvt}.dtbo`).

## Ubuntu Touch bring-up (branch `Halium-10`)

Oldest first.  Everything up to and including `d5455f4eb` has been installed and booted on
the device; the last two commits are compile-tested and go out with the next build.

| Commit | Change | Why |
|---|---|---|
| `d49b74fb6` | `CONFIG_LOCALVERSION="-perf"`, AUTOFS4, AppArmor boot default | Vendor blobs and the Halium rootfs expect the stock version string; AppArmor is Ubuntu's LSM. |
| `ec72e2601` | Defconfig regenerated in `savedefconfig` form | The old file was a 6200-line `.config` dump. Adds EXT4_FS_SECURITY, YAMA, SELinux boot parameter, ENCRYPTED_KEYS/EVM, netfilter matches for Ubuntu's iptables, `DEFAULT_MMAP_MIN_ADDR=32768`; drops the no-op `CONFIG_CMDLINE`. |
| `cc13ae724` | WireGuard vendored (`net/wireguard`, wireguard-linux-compat 1.0.20220627) | Nothing is downloaded at build time any more. |
| `ad9957b2e` | binderfs backport, `CONFIG_ANDROID_BINDERFS=y` | Ubuntu Touch 24.04-2.x bind-mounts `/dev/binderfs`. The static `/dev/binder`, `/dev/hwbinder`, `/dev/vndbinder` devices are kept because the Android 10 container's init does not know binderfs. |
| `9156fe091`, `c5456a86b` | qcacld-3.0 WLAN driver in tree, built in (`CONFIG_QCA_CLD_WLAN=y`) | No more dependency on the stock `qca_cld3_wlan.ko` vermagic. The built-in driver only creates `/dev/wlan`; writing `ON` to it loads the firmware and creates `wlan0` (the overlay's `android-wlan-on.service` does this). |
| `59ca6a8bd`, `b85fe0c4f`, `b46b881a0` | fscrypt v2 (policy v2, `FS_IOC_ADD_ENCRYPTION_KEY`, fs-verity, casefolding) from the Android Common Kernel; OnePlus f2fs "bigdata" statistics dropped; link fixes | Needed for 24.04 first-boot encryption. |
| `ac37ad105` | Defconfig: drop `PAGE_OWNER`, `CGROUP_DEBUG`, `HARDENED_USERCOPY_PAGESPAN`, `ARM64_STRICT_BREAK_BEFORE_MAKE`, `CMA_DEBUGFS` | Debug-only options that cost runtime performance. |
| `b13b048e8` | `DTC_FLAGS += -Wno-reg_format -Wno-avoid_default_addr_size` for the vendor trees | The CAF trees trip these two dtc checks by design; CI output was unreadable. |
| `e16c73093` | `control_center`: two implicit-int declarations fixed | clang 18 rejects them. |
| `59c6eef37` | `techpack/display`: eleven routine backlight/HBM/AOD/fps messages moved from `DSI_ERR` to `DSI_DEBUG` | They were flooding dmesg on every brightness change. |
| `e6490e833` | `CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL=y` | Ubuntu Touch has no userspace governor daemon; stock defaulted to `performance` until Android's init switched it. |
| `f349483e2` | `instantnoodle{,p,v}.dtsi`: duplicated charger "temp region settings" block removed | The in-tree dtc refuses duplicate properties; the second copy was the one that took effect, and it is the one kept (`sw-iterm` 225/235/225). |
| `d5455f4eb` | Only the three instantnoodle overlays are built (`*-overlay-{t0,evt1,dvt}.dtbo`); `ARCH_HOWSON` and the `*-howson-overlay-*` trees removed; the Pro overlays sit behind `CONFIG_ARCH_ONEPLUS8PRO` | The build repo now takes DTB and DTBO straight from the kernel build. The device is a `dvt` board (`kona MTP dvt 19821`). |
| `d3d220bd6` | Fingerprint: `touch_state` sysfs attribute on the Goodix device (pollable, set by `gf_opticalfp_irq_handler`); when `force_screenfp` is set on `card0-DSI-1`, the SDE CRTC takes `fingerprint_mode`/`fingerprint_pressed` from `notify_dim`/`notify_fppress` instead of requiring the OnePlus HWC's private `fppressed` plane | Lets a non-Android compositor (Mir) drive the under-display sensor: the kernel sends the UI_READY DRM event when the dim layer is up, which the Goodix HAL waits for. See "Under-display fingerprint" below. |
| `8fd95cf6d` | ElementalX leftovers removed: Boeffla wakelock blocker, KLAPSE, wake gestures, the FIOPS/SIO/ZEN/Maple I/O schedulers (default back to CFQ; BFQ stays for mq) | Nothing in Ubuntu Touch uses them; they are a maintenance burden in the stable merge. KCAL colour control is kept. |

## linux-stable 4.19 series (branch `Halium-10-stable`)

Merged from `gregkh/linux` in chunks on top of `8fd95cf6d`; each chunk is one squashed
commit whose message lists the files kept at the CAF version and every hand adaptation.
Policy: Qualcomm-divergent drivers (dwc3, UFS, sdhci-msm/cqhci, rpmh, qrtr, rmnet, glink,
smp2p, coresight, wil6210, the USB gadget composite/configfs/f_fs layer, cpu_cooling,
clk-rcg2) keep our version; core kernel, mm, net, HID, crypto, scheduler and timers take
upstream with adaptation to the CAF/WALT code.

| Chunk | Commit | Status |
|---|---|---|
| v4.19.82..100 | `fbd63de70`, fixes `a5e03602d`, `600a2863b` | builds |
| v4.19.101..150 | `5092898b9` | builds |
| v4.19.151..200 | `11a46463b` | builds |
| v4.19.201..250 | `42165ffba` | builds |
| v4.19.251..300 | `5a9843ba6` | builds |
| v4.19.301..325 | `bcc284993681` | builds |

Things that change for userspace with the stable series:

- `uname -r` moves from `4.19.81-perf` to `4.19.325-perf`.  Vendor blobs do not key on
  it; nothing in the overlay does either.
- `stpcpy()` is in `lib/string.c` from 4.19.150, so clang builds no longer need
  `-fno-builtin-stpcpy`.
- The qcacld WLAN driver's `>= 4.19.110` check selected the Android-common-kernel
  `wakeup_source_register(dev, name)` API that linux-stable never had; it is now gated on
  the `WAKEUP_SOURCE_DEV` feature macro only.
- `fscrypt_supp.h`/`fscrypt_notsupp.h` stay deleted (our fscrypt v2 tree merged them into
  `fscrypt.h`); `fscrypt_is_nokey_name()` lives there and ext4/f2fs/ubifs use it.
- dm-table: upstream dropped `dm_table_all_devices_attribute()`; the inline-crypt queue
  flag is now derived through `dm_table_any_dev_attr()` like the other attributes.
- From 4.19.235 the kernel carries upstream's rewritten `drivers/char/random.c` (the 5.18
  RNG backport), built on our `<crypto/chacha.h>`; `CONFIG_RANDOM_TRUST_BOOTLOADER` is new
  and `/dev/random` no longer blocks after the CRNG is seeded.
- Spectre-BHB mitigation (`CONFIG_MITIGATE_SPECTRE_BRANCH_HISTORY`) is in from 4.19.234.
- The MMC core stays at the CAF version (the device has no SD/eMMC); upstream's BKOPS
  cleanup is not taken.

The series is complete: the branch is at Linux 4.19.325, the final 4.19 release.  It is
build-tested only.  The first device test is a build with `deviceinfo_kernel_source_branch`
pointed at `Halium-10-stable`; once that boots with WiFi, Bluetooth, charging and display
working, the branch is fast-forwarded into `Halium-10`.

Also kept at the CAF version because upstream's changes do not fit the Qualcomm driver:
the whole UFS host driver (`drivers/scsi/ufs/`), the dwc3 USB controller, the MMC core,
the rmnet data path, and `drivers/iommu/io-pgtable-arm.c`.  The CAF hrtimer CPU-isolation
path (`hrtimer_quiesce_cpu()`) coexists with upstream's `hrtimers_cpu_dying()`.

## Under-display fingerprint (UDFPS), state of play

- Hardware path: Goodix optical sensor on SPI, `gf_spi.c`; touch driver calls
  `gf_opticalfp_irq_handler()` on finger down/up inside the sensor area (centre
  x=546, y=1909, radius 118 on the 1080x2400 panel).
- Display path: `/sys/class/drm/card0-DSI-1/{notify_fppress,notify_dim,dim_alpha,force_screenfp,dimlayer_bl_en}`.
  With `force_screenfp=1`, writing `notify_dim=1` then `notify_fppress=1` makes the kernel
  raise `DRM_PANEL_ONSCREENFINGERPRINT_EVENT` (UI_READY) on the next commit; the HAL's
  capture waits for exactly that.
- `/proc/touchpanel/touch_hold` must be 1 for the touch driver to report sensor-area
  presses.
- The Goodix HAL (`android.hardware.biometrics.fingerprint@2.1-service`) needs its persist
  files under their original names (they had been renamed `.off`) and `/data/media/0` to
  exist in the container; with those it reaches `caliState=0x2`.  The remaining calibration
  bit needs a lit-screen runtime calibration, which is what the test script exercises.
- Test script: `fodtest.py` (polls `touch_state` with POLLPRI, drives the sysfs nodes);
  run it on a build that contains `d3d220bd6`.
- Still to do in userspace: a small daemon that does what the script does, hooked to
  biometryd / the lock screen.  That is Ubuntu Touch side work, not kernel.

## Display artifacts (black 32x4 dashes)

Pre-existing on the stock-kernel port, present in screenshots, so they are in the app
buffers, not a panel/DSI problem.  Adreno 650 bring-up is clean (a650 SQE/GMU/zap load,
no KGSL faults), the artifacts do not track GPU clock or Qt batching, and disabling UBWC
in gralloc (`vendor.gralloc.disable_ubwc=1`) did not change them.  Kernel side is
exhausted for now; the next suspects are the Mir/Qt render path in the rootfs.

## Still planned

1. Boot test of `Halium-10-stable` (4.19.325) on the device, then fold into `Halium-10`.
2. Newer toolchain in CI (clang 18 already builds it locally with the warning set in the
   build repo's `build.conf`).
3. LTO/CFI as an optional, last step.
4. Branch cleanup/rename (`ubuntu-touch`, `ubuntu-touch-stable`, a Droidian branch);
   requires the build repo's `deviceinfo` and CI workflow to follow.
5. Droidian defconfig and workflow.
