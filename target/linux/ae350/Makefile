# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Andes Technology <peterlin@andestech.com>
#
include $(TOPDIR)/rules.mk

ARCH:=riscv64
BOARD:=ae350
BOARDNAME:=Andes AE350-AX45MP platform
FEATURES:=ext4
KERNELNAME:=Image dtbs
SUBTARGETS:=generic

KERNEL_PATCHVER:=6.6

include $(INCLUDE_DIR)/target.mk

define Target/Description
	Build firmware images for the Andes AE350-AX45MP platform
endef

$(eval $(call BuildTarget))
