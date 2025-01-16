    #!/sbin/sh
    ui_print "- Installing..."
    ui_print "- 理论上来说，模块目录位于/data/adb/modules/autochagespeed"
    ui_print "- 配置文件位于/sdcard/Android/autochagespeed/config.txt"
    dir_path="/sdcard/Android/autochagespeed"
    if [ ! -d "$dir_path" ]; then
        mkdir -p /sdcard/Android/autochagespeed
    fi
    file_path="/sdcard/Android/autochagespeed/config.txt"
    if [ ! -e "$file_path" ]; then
        status=$(cat /sys/class/power_supply/battery/status)
        current=$(cat /sys/class/power_supply/battery/current_now)
        if [[ $status == "Charging" ]]
        then
            ui_print "! 请拔出充电器再安装!"
            exit 1
        fi
        echo "# 当大于{capacity}%就将最大电流设为{current}mA, 以下五个capacity必须从大到小, 否则无效" > $file_path
        echo "capacity1=80" >> $file_path
        echo "current1=200" >> $file_path
        echo "" >> $file_path
        echo "capacity2=60" >> $file_path
        echo "current2=400" >> $file_path
        echo "" >> $file_path
        echo "capacity3=40" >> $file_path
        echo "current3=600" >> $file_path
        echo "" >> $file_path
        echo "capacity4=20" >> $file_path
        echo "current4=800" >> $file_path
        echo "" >> $file_path
        echo "capacity5=0" >> $file_path
        echo "current5=30000" >> $file_path
        echo "" >> $file_path
        echo "# 当电池温度大于{temperature}°C时, 将最大电流设为{currentTemp}mA" >> $file_path
        echo "temperature=42" >> $file_path
        echo "currentTemp=200" >> $file_path
        echo "" >> $file_path
        echo "# 保持最低电量, -1为不开启" >> $file_path
        echo "lowbattery=10" >> $file_path
        echo "lowbatteryCurrent=39000" >> $file_path
        echo "" >> $file_path
        echo "# 电流极性符号" >> $file_path
        if [[ $current -gt 0 ]]
        then
            ui_print "- 相反的电流极性，设置电流符号为负"
            echo "minus=-1" >> $file_path
        else
            ui_print "- 正常的电流极性，设置电流符号为正"
            echo "minus=1" >> $file_path
        fi
    fi
    unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
    ui_print "- 配置导入完成,如有需要请前往配置目录修改"

