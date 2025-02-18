# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025 Andes Technology Corporation
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

FAT32_BLOCK_SIZE=1024
FAT32_BLOCKS=$(shell echo $$(($(CONFIG_AE350_SD_BOOT_PARTSIZE)*1024*1024/$(FAT32_BLOCK_SIZE))))

KERNEL_LOADADDR:=0x00600000

define Build/riscv-sdcard
	rm -f $@.boot #$(KDIR_TMP)/$(IMG_PREFIX)-$(PROFILE)-boot.img
	mkfs.fat $@.boot  -C $(FAT32_BLOCKS)

	mcopy -i $@.boot $(STAGING_DIR_IMAGE)/$(DEVICE_NAME)-boot.scr ::boot.scr
	mcopy -i $@.boot $(DTS_DIR)/$(DEVICE_DTS).dtb ::ax45mp_c4_d_dsp_ae350.dtb
	mcopy -i $@.boot $(IMAGE_KERNEL) ::Image
	mcopy -i $@.boot $(STAGING_DIR_IMAGE)/$(DEVICE_NAME)-u-boot.itb ::u-boot.itb
	mcopy -i $@.boot $(STAGING_DIR_IMAGE)/$(DEVICE_NAME)-u-boot.itb-spl ::u-boot-spl.bin

	./gen_ae350_sdcard_img.sh \
		$@ \
		$@.boot \
		$(IMAGE_ROOTFS) \
		$(CONFIG_AE350_SD_BOOT_PARTSIZE) \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) \
		$(STAGING_DIR_IMAGE)/$(DEVICE_NAME)-u-boot.itb \
		$(STAGING_DIR_IMAGE)/$(DEVICE_NAME)-u-boot.itb-spl
endef

define Device/Default
  PROFILES := Default
  KERNEL_NAME := Image
  KERNEL := kernel-bin | libdeflate-gzip
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := riscv-sdcard | append-metadata | gzip
endef

define Device/ae350_rv64_spl_xip
  DEVICE_VENDOR := Andes Technology
  DEVICE_MODEL := AE350 (AX45MP)
  DEVICE_DTS := andes/ax45mp_c4_d_dsp_ae350
  UBOOT := ae350_rv64_spl_xip
endef
TARGET_DEVICES += ae350_rv64_spl_xip

$(eval $(call BuildImage))
