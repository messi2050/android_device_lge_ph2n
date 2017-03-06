#!/system/bin/sh

#
# Allow USB enumeration with default PID/VID
#
if [ -e /sys/class/android_usb/f_mass_storage/lun/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
fi
if [ -e /sys/class/android_usb/f_cdrom_storage/lun/nofua ];
then
    echo 1  > /sys/class/android_usb/f_cdrom_storage/lun/nofua
fi
if [ -e /sys/class/android_usb/f_mass_storage/rom/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/rom/nofua
fi

usb_config=`getprop persist.sys.usb.config`
case "$usb_config" in
    "" | "pc_suite" | "mtp_only" | "auto_conf")
        setprop persist.sys.usb.config mtp
        ;;
    "adb" | "pc_suite,adb" | "mtp_only,adb" | "auto_conf,adb")
        setprop persist.sys.usb.config mtp,adb
        ;;
    "ptp_only")
        setprop persist.sys.usb.config ptp
        ;;
    "ptp_only,adb")
        setprop persist.sys.usb.config ptp,adb
        ;;
    * ) ;; #USB persist config exists, do nothing
esac

################################################################################
# QCOM
################################################################################

chown -h root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
chmod -h 220 /sys/devices/platform/msm_hsusb/gadget/wakeup

# Target as specified in build.prop at compile-time
target=`getprop ro.board.platform`

# Set platform variables
if [ -d /sys/devices/soc0 ]; then
    soc_hwplatform=`cat /sys/devices/soc0/hw_platform` 2> /dev/null
    soc_id=`cat /sys/devices/soc0/soc_id` 2> /dev/null
else
    soc_hwplatform=`cat /sys/devices/system/soc/soc0/hw_platform` 2> /dev/null
fi

#
# soc_id may specify additional chip variants not captured in ro.board.platform
# so allow for additional target differentiation based on that
#
case $soc_id in
    "252")
        target="apq8092"
    ;;
    "253")
        target="apq8094"
    ;;
esac

# enable rps cpus on msm8937 target
setprop sys.usb.rps_mask 0
case "$soc_id" in
    "294" | "295")
        setprop sys.usb.rps_mask 10
    ;;
esac

#
# Allow persistent usb charging disabling
# User needs to set usb charging disabled in persist.usb.chgdisabled
#
usbchgdisabled=`getprop persist.usb.chgdisabled`
case "$usbchgdisabled" in
    "") ;; #Do nothing here
    * )
    case $target in
        "msm8660")
        echo "$usbchgdisabled" > /sys/module/pmic8058_charger/parameters/disabled
        echo "$usbchgdisabled" > /sys/module/smb137b/parameters/disabled
        ;;
        "msm8960")
        echo "$usbchgdisabled" > /sys/module/pm8921_charger/parameters/disabled
        ;;
    esac
esac

usbcurrentlimit=`getprop persist.usb.currentlimit`
case "$usbcurrentlimit" in
    "") ;; #Do nothing here
    * )
    case $target in
        "msm8960")
        echo "$usbcurrentlimit" > /sys/module/pm8921_charger/parameters/usb_max_current
        ;;
    esac
esac

#
# Check ESOC for external MDM
#
# Note: currently only a single MDM is supported
#
if [ -d /sys/bus/esoc/devices ]; then
for f in /sys/bus/esoc/devices/*; do
    if [ -d $f ]; then
        esoc_name=`cat $f/esoc_name`
        if [ "$esoc_name" = "MDM9x25" -o "$esoc_name" = "MDM9x35" ]; then
            esoc_link=`cat $f/esoc_link`
            break
        fi
    fi
done
fi

#
# Do target specific things
#
baseband=`getprop ro.baseband`
case "$target" in
    "msm8974")
# Select USB BAM - 2.0 or 3.0
        echo ssusb > /sys/bus/platform/devices/usb_bam/enable
    ;;
    "apq8084")
        if [ "$baseband" == "apq" ]; then
            echo "msm_hsic_host" > /sys/bus/platform/drivers/xhci_msm_hsic/unbind
        fi
        echo qti,ether > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8226")
         if [ -e /sys/bus/platform/drivers/msm_hsic_host ]; then
             if [ ! -L /sys/bus/usb/devices/1-1 ]; then
                 echo msm_hsic_host > /sys/bus/platform/drivers/msm_hsic_host/unbind
             fi
         fi
    ;;
    "msm8994" | "msm8992" | "msm8996")
        echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
        echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8952" | "msm8976")
        echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
        # Increase RNDIS DL max aggregation size to 11K
        echo 11264 > /sys/module/g_android/parameters/rndis_dl_max_xfer_size
        echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "apq8064")
        echo hsic,hsic > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8909")
        echo qti,bam > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8937")
        echo qti,bam > /sys/class/android_usb/android0/f_rmnet/transports
        echo 10 > /sys/module/g_android/parameters/rndis_dl_max_pkt_per_xfer
        echo 3 > /sys/module/g_android/parameters/rndis_ul_max_pkt_per_xfer
    ;;

    * )
        echo smd,bam > /sys/class/android_usb/android0/f_rmnet/transports
        echo 10 > /sys/module/g_android/parameters/rndis_dl_max_pkt_per_xfer
        echo 5 > /sys/module/g_android/parameters/rndis_ul_max_pkt_per_xfer
    ;;
esac

#
# set module params for embedded rmnet devices
#
rmnetmux=`getprop persist.rmnet.mux`
case "$baseband" in
    "mdm" | "dsda" | "sglte2")
        case "$rmnetmux" in
            "enabled")
                    echo 1 > /sys/module/rmnet_usb/parameters/mux_enabled
                    echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                    echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
            ;;
        esac
        echo 1 > /sys/module/rmnet_usb/parameters/rmnet_data_init
        # Allow QMUX daemon to assign port open wait time
        chown -h radio.radio /sys/devices/virtual/hsicctl/hsicctl0/modem_wait
    ;;
    "dsda2")
          echo 2 > /sys/module/rmnet_usb/parameters/no_rmnet_devs
          echo hsicctl,hsusbctl > /sys/module/rmnet_usb/parameters/rmnet_dev_names
          case "$rmnetmux" in
               "enabled") #mux is neabled on both mdms
                      echo 3 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > write /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
               "enabled_hsic") #mux is enabled on hsic mdm
                      echo 1 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
               "enabled_hsusb") #mux is enabled on hsusb mdm
                      echo 2 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
          esac
          echo 1 > /sys/module/rmnet_usb/parameters/rmnet_data_init
          # Allow QMUX daemon to assign port open wait time
          chown -h radio.radio /sys/devices/virtual/hsicctl/hsicctl0/modem_wait
    ;;
esac

################################################################################
# DEVICE
################################################################################

if [ -f "/init.lge.usb.dev.sh" ]
then
    source /init.lge.usb.dev.sh
fi
