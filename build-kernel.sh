#!/bin/bash
#
# Rebuild Image + dt.img from android_kernel_samsung_universal8895 (aosp17).
#
#   ./build-kernel.sh ../../../../aosp-kernel/src
#
# Needs an aarch64-linux-gnu- cross GCC. Output goes to <src>/../out and the
# results are copied next to this script.

set -euo pipefail
SRC=$(readlink -f "${1:?usage: $0 <kernel source dir>}")
OUT=$(readlink -f "$SRC/../out")
HERE=$(dirname "$(readlink -f "$0")")
MAKE=(make -C "$SRC" O="$OUT" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
      HOSTCFLAGS=-fcommon KCFLAGS=-Wno-error)

"${MAKE[@]}" exynos8895-dream2lte_defconfig
"${MAKE[@]}" -j"$(nproc)" Image dtbs

DTBTOOL="$OUT/scripts/dtbtool_exynos/dtbtool"
[ -x "$DTBTOOL" ] || { DTBTOOL="$OUT/dtbtool"; gcc -O2 -o "$DTBTOOL" "$SRC/scripts/dtbtool_exynos/dtbtool.c"; }
"$DTBTOOL" --pagesize 2048 --platform 0x50a6 --subtype 0x217584da -o "$HERE/dt.img" \
    "$OUT"/arch/arm64/boot/dts/exynos/exynos8895-dream2lte_eur_open_10.dtb
cp "$OUT/arch/arm64/boot/Image" "$HERE/Image"
