#!/bin/bash
# WireGuard is vendored in this tree: net/wireguard holds the src/ directory of
# wireguard-linux-compat (see net/wireguard/version.h), with the Kconfig made
# bool/default y as the original fetch script did. Nothing is downloaded at build
# time any more, so a fresh checkout builds offline and reproducibly.
#
# To update: copy src/ from a newer https://git.zx2c4.com/wireguard-linux-compat
# release over net/wireguard and re-apply
#   sed -i 's/tristate/bool/;s/default m/default y/;' net/wireguard/Kconfig
exit 0
