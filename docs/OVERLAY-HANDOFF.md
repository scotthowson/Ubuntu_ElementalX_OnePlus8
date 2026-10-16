# Rundown for the overlay / build-repo agent

## Status 2026-10-16: the 4.19.325 kernel does not boot, bisect needed

The first device test of `Halium-10-stable` (Linux 4.19.325) fails: the phone resets
before the USB gadget comes up (no RNDIS, no adb, no Halium initrd telnet), and the
recovery image from the same build fails identically.  The old `Halium-10` kernel boots
the same rootfs, overlay and dtbo, and the new kernel fails with the old dtbo too, so the
regression is in the kernel itself.  No ramoops/pstore log survives a reset on this
device, and nothing is visible by inspection, so we bisect by chunk.

Bisect branches on the kernel repo (`scotthowson/Ubuntu_ElementalX_OnePlus8`), one per
squashed stable chunk, all compile-tested with clang 18:

| `deviceinfo_kernel_source_branch` | Kernel |
|---|---|
| `bisect/stable-4.19.100` | v4.19.82..100 |
| `bisect/stable-4.19.150` | ..150 |
| `bisect/stable-4.19.200` | ..200 (build this one first) |
| `bisect/stable-4.19.250` | ..250 |
| `bisect/stable-4.19.300` | ..300 |
| `bisect/stable-4.19.325` | ..325, includes the clang 9 Makefile fix |

Procedure:

1. Build with `deviceinfo_kernel_source_branch="bisect/stable-4.19.200"`.  Nothing else in
   `deviceinfo` or the overlay changes.  Publish `boot.img` (the dtbo from any build is
   fine; the old one is known good).
2. The user tests from the bootloader with `fastboot boot boot.img` (the flashed
   `Halium-10` kernel stays as fallback) and reports boots / loops plus the seconds from
   the OnePlus logo to the reset.
3. Boots: next `bisect/stable-4.19.300`, then `.250` or `.325`.  Loops: next `.100`,
   then `.150`.  Three builds pin the chunk; the kernel side then diffs that chunk
   against LineageOS 22.2 (4.19.325 on the same SoC) and fixes it.
4. When a bisect kernel boots to the UI, also collect over ssh:
   `uname -r; dmesg | grep -i -E 'warn|bug|error' | head -40`.

CI toolchain note: the runner builds with the AOSP android10-gsi clang (r353983c,
clang 9).  `Halium-10-stable` carries a `scripts/Makefile.extrawarn` fix so that
upstream's new clang warning flags are probed instead of forced; the five older bisect
branches predate those flags and need nothing.  Please attach the CI build log of each
bisect build to the result: clang 9 is older than anything the merged upstream code has
been compiled with, and a warning there may be the clue.

Nothing in the overlay is implicated and no overlay change is needed for the bisect.

## Earlier items (still valid)

Kernel side status as of the linux-stable 4.19.200 merge.  For the full kernel change
list see `docs/CHANGELOG.md` in this repo.  Items are grouped by whether the overlay agent
needs to act now, later, or just know.

## Act now (next build off `Halium-10`)

1. **Next build should include `d3d220bd6` (fingerprint enabler) and `8fd95cf6d`
   (ElementalX removal).**  Both compile-tested, not yet installed.  No overlay change is
   needed for them; the ElementalX removal was checked against the overlay tree and
   nothing references the removed sysfs nodes (boeffla, klapse, wake gestures, the extra
   I/O schedulers).  I/O scheduler stays cfq.
2. **`/data/media/0` must exist inside the Android container at boot.**  The Goodix
   fingerprint HAL writes its calibration object there and silently fails otherwise.
   Create it (owner `media_rw:media_rw`, mode 0770, like Android does) from the
   container-side device hacks before `vendor.fps_hal` starts.
3. **Fingerprint persist files.**  On this device the files under
   `/mnt/vendor/persist/` (goodix `gf_*`) had been renamed with a `.off` suffix at some
   point; the HAL needs the original names.  Nothing to ship in the overlay, but worth a
   note in `PORTING_NOTES.md` so nobody renames them again.  A backup of the restored
   set is `persist-data-backup.tgz` on the PC.
4. **UBWC experiment is over, result negative.**  `vendor.gralloc.disable_ubwc=0` in
   `overlay/.../vendor/build.prop` is the right value; do not flip it again for the
   dashes.  Note the outcome in `PORTING_NOTES.md` under the artifacts entry.

## Later (when the stable branch is ready to test)

5. **Stable kernel test build.**  When told, make a test build with
   `deviceinfo_kernel_source_branch="Halium-10-stable"`.  Expect `uname -r` to report
   `4.19.3xx-perf` instead of `4.19.81-perf` (`kernel/README.md` line "uname -r" needs
   updating then).  Acceptance is the same list as before: boots, UI, `lxc-info -n
   android` RUNNING, `wlan0` after the ON write, Bluetooth via bluebinder, charging,
   deep idle, plus `dmesg` diffed against the Halium-10 build for new warnings.
6. **Branch rename (pending the user's decision).**  Proposed: `Halium-10` →
   `ubuntu-touch`, `Halium-10-stable` → `ubuntu-touch-stable`, old ElementalX/HaliumX
   branches deleted, `ElementalX-3.00` kept as a reference.  If that goes ahead,
   `deviceinfo_kernel_source_branch`, the CI workflow's branch references and the three
   docs (`README.md`, `PORTING_NOTES.md`, `kernel/README.md`) need the new names.  Do not
   change anything until the rename is actually done on the kernel repo.

## Just know

7. **fscrypt policy v2** is on in the overlay (`1bced70`) and the kernel has v2; verify on
   the next fresh install, then close the item in `PORTING_NOTES.md`.
8. **DTB/DTBO from the kernel build** (`0413628`) matches what the kernel now produces:
   `kona.dtb kona-v2.dtb kona-v2.1.dtb` and the three `instantnoodle-overlay-*.dtbo`.
   The dtc warning spam is gone from CI since `b13b048e8`; the only remaining dtc output
   should be real errors.
9. **Fingerprint userspace is the next feature after boot/WiFi/BT.**  The kernel
   contract is documented in `docs/CHANGELOG.md` ("Under-display fingerprint").  The
   test script `fodtest.py` can be shipped under `tools/` in the build repo for now; the
   real integration is a small service that watches `touch_state`, raises the dim layer
   and `notify_fppress`, and talks to biometryd.  Ubuntu Touch's biometryd has no UDFPS
   backend, so this will be a device-specific helper.
10. **`vendor.bluetooth-1-0-qti`** is the HAL service name bluebinder has to wait for
    (`fd3e347` already does this).  Nothing further.
11. **WLAN ON write** stays required with the built-in driver; `android-wlan-on.service`
    is the right mechanism and the stable merge does not change it.
12. **Props that only SurfaceFlinger reads** in `vendor/build.prop` can be pruned at
    leisure; none of them affect the kernel.

## Open questions for the user to settle

- Branch rename: yes/no, and the final names.
- Whether the Droidian work gets its own build repo or a second `deviceinfo` in this one.
