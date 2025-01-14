    #!/sbin/sh
    status=$(cat /sys/class/power_supply/battery/status)
    current=$(cat /sys/class/power_supply/battery/current_now)
    if [[ $status == "Charging" ]]
    then
        ui_print "! 请拔出充电器再安装!"
        exit 1
    fi
    ui_print "- Installing..."
    ui_print "- 理论上来说，模块目录位于/data/adb/modules/autochagespeed"
    ui_print "- 配置文件位于/sdcard/Android/autochagespeed/config.txt"
    mkdir -p /sdcard/Android/autochagespeed
    echo "# 当大于{capacity}%就将最大电流设为{current}mA, 以下五个capacity必须从大到小, 否则无效" > /sdcard/Android/autochagespeed/config.txt
    echo "capacity1=80" >> /sdcard/Android/autochagespeed/config.txt
    echo "current1=200" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "capacity2=60" >> /sdcard/Android/autochagespeed/config.txt
    echo "current2=400" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "capacity3=40" >> /sdcard/Android/autochagespeed/config.txt
    echo "current3=600" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "capacity4=20" >> /sdcard/Android/autochagespeed/config.txt
    echo "current4=800" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "capacity5=0" >> /sdcard/Android/autochagespeed/config.txt
    echo "current5=30000" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "# 当电池温度大于{temperature}°C时, 将最大电流设为{currentTemp}mA" >> /sdcard/Android/autochagespeed/config.txt
    echo "temperature=42" >> /sdcard/Android/autochagespeed/config.txt
    echo "currentTemp=200" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "# 保持最低电量, -1为不开启" >> /sdcard/Android/autochagespeed/config.txt
    echo "lowbattery=10" >> /sdcard/Android/autochagespeed/config.txt
    echo "lowbatteryCurrent=39000" >> /sdcard/Android/autochagespeed/config.txt
    echo "" >> /sdcard/Android/autochagespeed/config.txt
    echo "# 电流极性符号" >> /sdcard/Android/autochagespeed/config.txt
    if [[ $current -gt 0 ]]
    then
        ui_print "- 相反的电流极性，设置电流符号为负"
        echo "minus=-1" >> /sdcard/Android/autochagespeed/config.txt
    else
        ui_print "- 正常的电流极性，设置电流符号为正"
        echo "minus=1" >> /sdcard/Android/autochagespeed/config.txt
    fi
    unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
    ui_print "- 配置导入完成,如有需要请前往配置目录修改"

