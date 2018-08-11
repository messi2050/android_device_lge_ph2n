#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# inherit from common msm8937
include device/lge/msm8937-common/BoardConfigCommon.mk

LOCAL_PATH := device/lge/ph2n

# kernel
TARGET_KERNEL_CONFIG := lineage_ph2n_mini_defconfig

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3535798272
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10887364608
BOARD_CACHEIMAGE_PARTITION_SIZE := 524288000
TARGET_USERIMAGES_USE_EXT4 := true
#BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4

# NFC
BOARD_NFC_CHIPSET := pn548
BOARD_NFC_DEVICE := "/dev/pn547"
BOARD_NFC_HAL_SUFFIX := $(TARGET_BOARD_PLATFORM)

# Treble partitions [cache is used as vendor]
#BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
#BOARD_VENDORIMAGE_PARTITION_SIZE := 524288000
#BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
#TARGET_COPY_OUT_VENDOR := vendor

# Treble support
#BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
#PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_COMPATIBILITY_MATRIX_LEVEL_OVERRIDE := 27
PRODUCT_SHIPPING_API_LEVEL := 23

# Recovery
TARGET_RECOVERY_FSTAB := $(LOCAL_PATH)/rootdir/etc/fstab.full

# Properties
TARGET_SYSTEM_PROP += $(LOCAL_PATH)/system.prop
#TARGET_VENDOR_PROP += $(LOCAL_PATH)/vendor.prop

# inherit from the proprietary version
-include vendor/lge/ph2n/BoardConfigVendor.mk
-include device/lge/common/BoardConfigCommon.mk
