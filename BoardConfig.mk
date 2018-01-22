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

# Kernel
TARGET_KERNEL_CONFIG := lineage_ph2n_mini_defconfig

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3535798272
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10887364608
BOARD_CACHEIMAGE_PARTITION_SIZE := 524288000
TARGET_USERIMAGES_USE_EXT4 := true

# Recovery
TARGET_RECOVERY_FSTAB := $(LOCAL_PATH)/rootdir/fstab.qcom

# Properties
TARGET_SYSTEM_PROP += $(LOCAL_PATH)/system.prop

# inherit from the proprietary version
-include vendor/lge/ph2n/BoardConfigVendor.mk
-include device/lge/common/BoardConfigCommon.mk
