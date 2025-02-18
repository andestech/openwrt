#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 OpenWrt.org
#

set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@ gen_ae350_sdcard_img.sh @@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

[ $# -eq 7 ] || {
    echo "SYNTAX: $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size> <u-boot ITB image> <u-boot SPL>"
    exit 1
}

OUTPUT="$1"     # build_dir/target-riscv64_riscv64_musl/linux-ae350_generic/tmp/openwrt-ae350-generic-ae350_rv64_spl_xip-ext4-sdcard.img.gz
BOOTFS="$2"     # build_dir/target-riscv64_riscv64_musl/linux-ae350_generic/tmp/openwrt-ae350-generic-ae350_rv64_spl_xip-ext4-sdcard.img.gz.boot
ROOTFS="$3"     # build_dir/target-riscv64_riscv64_musl/linux-ae350_generic/root.ext4
BOOTFSSIZE="$4" # 32
ROOTFSSIZE="$5" # 104
UBOOT="$6"      # staging_dir/target-riscv64_riscv64_musl/image/ae350_rv64_spl_xip-u-boot.itb
UBOOT_SPL="$7"  # taging_dir/target-riscv64_riscv64_musl/image/ae350_rv64_spl_xip-u-boot.itb-spl

head=4
sect=63

set $(ptgen -o $OUTPUT -h $head -s $sect -l 4096 -t c -p ${BOOTFSSIZE}M -t 83 -p ${ROOTFSSIZE}M)

BOOTOFFSET="$(($1 / 512))"
BOOTSIZE="$(($2 / 512))"
ROOTFSOFFSET="$(($3 / 512))"
ROOTFSSIZE="$(($4 / 512))"

dd bs=512 if="$BOOTFS" of="$OUTPUT" seek="$BOOTOFFSET" conv=notrunc
dd bs=512 if="$ROOTFS" of="$OUTPUT" seek="$ROOTFSOFFSET" conv=notrunc