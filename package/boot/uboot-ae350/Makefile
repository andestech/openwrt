# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 OpenWrt.org
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_RELEASE:=1
PKG_VERSION:=2024.07
PKG_HASH:=f591da9ab90ef3d6b3d173766d0ddff90c4ed7330680897486117df390d83c8f

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
	BUILD_TARGET:=ae350
	BUILD_DEVICES=$(1)
	UBOOT_IMAGE:=u-boot.itb
	DTS_DIR:=arch/riscv/dts
	UENV:=default
	DEFAULT:=y
endef

define U-Boot/ae350_rv64_spl_xip
	NAME:=Andes AE350
	OPENSBI:=generic
	DEPENDS:=+opensbi_generic
	UBOOT_DTS:=ae350_64.dtb
	BUILD_DEVICES:=ae350_rv64_spl_xip
endef

UBOOT_TARGETS := \
	ae350_rv64_spl_xip

UBOOT_MAKE_FLAGS += \
	OPENSBI=$(STAGING_DIR_IMAGE)/fw_dynamic-${OPENSBI}.bin

define Build/Configure
	$(call Build/Configure/U-Boot)
	sed -i 's/# CONFIG_SPL_FS_FAT is not set/CONFIG_SPL_FS_FAT=y/' $(PKG_BUILD_DIR)/.config
	sed -i 's/# CONFIG_SPL_MMC is not set/CONFIG_SPL_MMC=y/' $(PKG_BUILD_DIR)/.config
	sed -i 's/CONFIG_SPL_RAM_SUPPORT=y/# CONFIG_SPL_RAM_SUPPORT is not set/' $(PKG_BUILD_DIR)/.config
	sed -i 's/CONFIG_SPL_OPENSBI_SCRATCH_OPTIONS=0x0/CONFIG_SPL_OPENSBI_SCRATCH_OPTIONS=0x1/' $(PKG_BUILD_DIR)/.config
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(UBOOT_IMAGE)          $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-$(UBOOT_IMAGE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin      $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-$(UBOOT_IMAGE)-spl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(DTS_DIR)/$(UBOOT_DTS) $(STAGING_DIR_IMAGE)/$(UBOOT_DTS)

	mkimage -C none -A arm -T script -d uEnv-$(UENV).txt \
		$(STAGING_DIR_IMAGE)/$(BUILD_DEVICES)-boot.scr
endef

$(eval $(call BuildPackage/U-Boot))
