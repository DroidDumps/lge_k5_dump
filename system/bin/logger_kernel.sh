#!/system/bin/sh

source check_data_mount.sh
log_to_data_partition=`is_ext4_data_partition`
log_file="kernel.log"

kernel_log_prop=`getprop persist.service.kernel.enable`
#vold_prop=`getprop vold.decrypt`
#vold_propress=`getprop vold.encrypt_progress`

ccmode_supported='0'
ccmode_status='0'
ccmode_audit_bit='0'
ccmode_audit_kern_user=0

if [ -f  /proc/sys/crypto/cc_mode_flag ];then
    ccmode_supported='1'
    ccmode_status=$(cat /proc/sys/crypto/cc_mode_flag)
else
    ccmode_supported='0'
    ccmode_status='0'
fi

let "ccmode_audit_bit = ccmode_status & 2"

touch /data/logger/${log_file}
chmod 0644 /data/logger/${log_file}


storage_full_prop=`getprop persist.service.logger.full`
storage_low_prop=`getprop persist.service.logger.low`

file_size=8388608
file_cnt=0

if [ "$storage_full_prop" = "1" ]; then
    exit 0
fi
if [ "$storage_low_prop" = "1" ]; then
   file_size=1048576
fi

if  [ "$ccmode_audit_bit" = "2" ] ; then
    case "$kernel_log_prop" in
        99)
            # kernel_logger is only running on persist.service.kernel.enable=99 when cc_mode is enabled with user mode, DO NOT USE other purpose.
            ccmode_audit_kern_user=1
            ;;
        6)
            file_size=1048576
            file_cnt=5
            ;;
        5)
            file_cnt=100
            ;;
        4)
            file_cnt=50
            ;;
        3)
            file_cnt=20
            ;;
        2)
            file_cnt=10
            ;;
        1)
            file_cnt=5
            ;;
        0)
            file_cnt=0
            ;;
        *)
            file_cnt=0
            ;;
    esac

    if [[ $file_cnt > 0 ]]; then
        if [[ $log_to_data_partition == 1 ]]; then
            move_log "/data/logger/${log_file}" "/cache/encryption_log/${log_file}"

            /system/bin/kernel_logger -f /data/logger/${log_file} -u 1 -s $file_size -m $file_cnt
        else
            touch /cache/encryption_log/${log_file}
            chmod 0644 /cache/encryption_log/${log_file}
            /system/bin/kernel_logger -f /cache/encryption_log/${log_file} -u 1 -s $file_size -m $file_cnt
        fi
    elif [[ $ccmode_audit_kern_user = 1 ]]; then
        /system/bin/kernel_logger -u 2
    fi

else
    case "$kernel_log_prop" in
        6)
            file_size=1048576
            file_cnt=5
            ;;
        5)
            file_cnt=100
            ;;
        4)
            file_cnt=50
            ;;
        3)
            file_cnt=20
            ;;
        2)
            file_cnt=10
            ;;
        1)
            file_cnt=5
            ;;
        0)
            file_cnt=0
            ;;
        *)
            file_cnt=0
            ;;
    esac

    if [[ $file_cnt > 0 ]]; then
        if [[ $log_to_data_partition == 1 ]]; then
            move_log "/data/logger/${log_file}" "/cache/encryption_log/${log_file}"

            /system/bin/kernel_logger -f /data/logger/${log_file} -s $file_size -m $file_cnt
        else
            touch /cache/encryption_log/${log_file}
            chmod 0644 /cache/encryption_log/${log_file}
            /system/bin/kernel_logger -f /cache/encryption_log/${log_file} -s $file_size -m $file_cnt
        fi
    fi
fi
