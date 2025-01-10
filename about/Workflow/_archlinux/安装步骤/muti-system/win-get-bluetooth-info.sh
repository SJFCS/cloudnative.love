#!/bin/bash
# 仅鼠标，不支持耳机
# 删除reg
function set_reg_dir() {
    echo "1. windows独立磁盘，打开nautilus 手动点击挂载，然后复制路径"
    echo "2. 用mount命令挂载"
    local windows_mount_point=$(gum input --placeholder "windows 挂载点")
    if [ -d "$windows_mount_point/Windows/System32/config" ]; then
        gum confirm "发现注册表路径为 $windows_mount_point/Windows/System32/config" && export reg_dir=$windows_mount_point/Windows/System32/config
    else
        echo "路径不正确"
    fi
}

function get_device_info() {
    local line_numbers=$(grep -Pn 'BTHPORT.*(\\[\da-f]{12}){2}' ~/system.reg | awk -F : '{print $1}')
    for number in $line_numbers; do
        local number_end=$(($number + 9))
        # 设备id
        device_ids=$(get_device_id "$(sed -n "$number,${number_end}p" ~/system.reg)")
        for id in $device_ids; do
            # 设备名字
            device_name=$(get_device_name "$id")
        done
        local paired_devices_list+="$device_name ($id), line_numbers: $number $number_end "$'\n'
    done
    # 选中设备
    selected_device=$(echo -e "$paired_devices_list" | sed '$d' | gum choose --header "选择蓝牙配对设备")
    selected_start_numbers=$(echo "$selected_device" | awk '{print $(NF-1)}')
    selected_end_numbers=$(echo "$selected_device" | awk '{print $NF}')
    action_handler
    # 转换信息
    # 查看
}

function action_handler() {
    if [[ -n "$selected_device" ]]; then
        action=$(gum choose --header "执行操作" "view_devices" "convert_to_linux")
        eval $action
    fi
}
function view_devices() {
    sed -n "$selected_start_numbers,${selected_end_numbers}p" ~/system.reg
}
function convert_to_linux() {
    echo LTK: $(sed -n "$selected_start_numbers,${selected_end_numbers}p" ~/system.reg | grep LTK | awk -F : '{print $2}' | tr -d , | tr a-z A-Z)     # 去掉逗号分隔符并转换为大写
    echo IRK: $(sed -n "$selected_start_numbers,${selected_end_numbers}p" ~/system.reg | grep '"IRK"' | awk -F : '{print $2}' | tr -d , | tr a-z A-Z) # 去掉逗号分隔符并转换为大写
    # echo CSRK: $(sed -n "$selected_start_numbers,${selected_end_numbers}p" ~/system.reg | grep CEntralIRKStatus | awk -F : '{print $2}' | tr -d , | tr a-z A-Z) # 去掉逗号分隔符并转换为大写
    EDIV=$(sed -n "${selected_start_numbers},${selected_end_numbers}p" ~/system.reg | grep EDIV | awk -F : '{print $2}' | tr -d '\r')
    echo EDIV: $(echo $((16#$EDIV))) # 从十六进制转换为十进制
    ERand=$(sed -n "$selected_start_numbers,${selected_end_numbers}p" ~/system.reg | grep ERand | awk -F : '{print $2}' | tr , '\n' | tac | tr -d '\n' | tr -d '\r')
    echo ERand: $(echo $((16#$ERand))) # 先倒序，再从十六进制转换为十进制
}

function get_device_id() {
    local device_info=$1
    echo $device_info | grep -oP '(?<=\\)[0-9a-fA-F]{12}(?=])'
}

function get_device_name() {
    local device_id=$1
    local line_numbers=$(grep -Pn '.*ROOT\\ControlSet001\\Enum\\BTHLE\\Dev_'"$device_id"'\\.*'"$device_id"'\]' ~/system.reg | awk -F : '{print $1}')

    for number in $line_numbers; do
        local number_end=$(($number + 16))
        sed -n "$number,${number_end}p" ~/system.reg | grep FriendlyName | awk -F'"' '{print $4}'
    done
}

if [ -f ~/system.reg ]; then
    get_device_info
else
    set_reg_dir
    dumphive $reg_dir/SYSTEM ~/system.reg else
    get_device_info
fi

# /run/media/admin/9EE46EADE46E86FD
# paru -S gum dumphive