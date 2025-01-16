#!/system/bin/sh
# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点
MODDIR=${0%/*}

# 该脚本将在设备开机后作为延迟服务启动

# 检测逻辑来自yc9559的uperf
wait_until_login() {
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 5
    done

    local test_file="/sdcard/Android/.PERMISSION_TEST_autochagespeed"
    true >"$test_file"
    while [ ! -f "$test_file" ]; do
        sleep 5
        true >"$test_file"
    done
    rm "$test_file"
}

wait_until_login

echo $(date) "模块启动" > "$MODDIR"/log.log
chmod 777 /sys/class/power_supply/*/*
lasthint="DisCharging"
cp -f "$MODDIR/backup.prop" "$MODDIR/module.prop"

while true; do

    # 读取配置文件和系统数据到变量
    source /sdcard/Android/autochagespeed/config.txt

    status=$(cat /sys/class/power_supply/battery/status)
    capacity=$(cat /sys/class/power_supply/battery/capacity)
    temp=$(cat /sys/class/power_supply/battery/temp)
    
    # max_current=$((max_current * 1000))
    # min_current=$((min_current * 1000))
    # target_capacity=$((target_capacity))
    capacity1=$((capacity1))    
    current1=$((current1 * 1000))
    capacity2=$((capacity2))
    current2=$((current2 * 1000))
    capacity3=$((capacity3))
    current3=$((current3 * 1000))
    capacity4=$((capacity4))
    current4=$((current4 * 1000))
    capacity5=$((capacity5))
    current5=$((current5 * 1000))
    temperature=$((temperature * 10))
    currentTemp=$((currentTemp * 1000))
    lowbattery=$((lowbattery))
    lowbatteryCurrent=$((lowbatteryCurrent * 1000))

    target_set_current=39000000

    current=$(($(cat /sys/class/power_supply/battery/current_now) * $minus))
    show_current=$(($current / 1000))
    show_temp=$(($temp / 10))
    show_target_set_current=$(($target_set_current / 1000))


    # 判断目前状态
    hint="DisCharging"
    if [ "$status" = "Charging" ]; then
        hint="Charging"
        if [[ $capacity -gt $capacity1 ]]; then
            hint="Charging1"
        elif [[ $capacity -gt $capacity2 ]]; then
            hint="Charging2"
        elif [[ $capacity -gt $capacity3 ]]; then
            hint="Charging3"
        elif [[ $capacity -gt $capacity4 ]]; then
            hint="Charging4"
        elif [[ $capacity -gt $capacity5 ]]; then
            hint="Charging5"
        fi

        # 进行相应操作
        if [[ $hint == "Charging1" ]]; then
            target_set_current=$current1
        elif [[ $hint == "Charging2" ]]; then
            target_set_current=$current2
        elif [[ $hint == "Charging3" ]]; then
            target_set_current=$current3
        elif [[ $hint == "Charging4" ]]; then
            target_set_current=$current4
        elif [[ $hint == "Charging5" ]]; then
            target_set_current=$current5
        fi
        
        if [[ $temp -gt $temperature ]]; then
            if [[ $target_set_current -gt $currentTemp ]]; then
                target_set_current=$currentTemp
                hint="HighTemperature"
            fi
        fi

        if [[ $capacity -lt $lowbattery ]]; then
            hint="LowBattery"
            target_set_current=$lowbatteryCurrent
        fi
    fi

    show_target_set_current=$(($target_set_current / 1000))

    if [ "$status" = "Charging" ]; then
        sed -i "/^description=/c description=[ 当前状态:${hint} 目标:${show_target_set_current}mA 实际:${show_current}mA 温度:${show_temp}℃ ] 自动充电调速" "$MODDIR/module.prop"
        # echo '0' > /sys/class/power_supply/battery/input_current_limited
        # echo '1' > /sys/class/power_supply/usb/boost_current
        echo ${target_set_current} > /sys/class/power_supply/usb/ctm_current_max
        echo ${target_set_current} > /sys/class/power_supply/usb/current_max
        echo ${target_set_current} > /sys/class/power_supply/usb/sdp_current_max
        echo ${target_set_current} > /sys/class/power_supply/usb/hw_current_max
        echo ${target_set_current} > /sys/class/power_supply/usb/constant_charge_current
        echo ${target_set_current} > /sys/class/power_supply/usb/constant_charge_current_max
        echo ${target_set_current} > /sys/class/power_supply/main/current_max
        echo ${target_set_current} > /sys/class/power_supply/main/constant_charge_current_max
        echo ${target_set_current} > /sys/class/power_supply/dc/current_max
        echo ${target_set_current} > /sys/class/power_supply/dc/constant_charge_current_max
        echo ${target_set_current} > /sys/class/power_supply/battery/constant_charge_current_max
        echo ${target_set_current} > /sys/class/power_supply/battery/constant_charge_current
        echo ${target_set_current} > /sys/class/power_supply/battery/current_max
        echo ${target_set_current} > /sys/class/power_supply/pc_port/current_max
        echo ${target_set_current} > /sys/class/power_supply/qpnp-dc/current_max
    elif [ "$status" = "Discharging" ]; then
        sleep 60
    fi

    #写入日志

    if [[ $lasthint != $hint ]]
    then
        echo $(date) $hint"事件" >> "$MODDIR"/log.log
        sed -i "/^description=/c description=[ 当前状态:${hint} ] 自动充电调速" "$MODDIR/module.prop"
    fi
    lasthint=$hint
    sleep 1
done
exit
