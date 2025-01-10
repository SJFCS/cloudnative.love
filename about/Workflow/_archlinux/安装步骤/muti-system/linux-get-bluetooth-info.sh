#!/bin/bash
# todo重启蓝牙
function get_bluetooth_adapters() {
    # 列出所有蓝牙适配器
    bluetooth_adapters=$(ls /var/lib/bluetooth 2>/dev/null)

    # 检查是否存在适配器
    if [[ -z "$bluetooth_adapters" ]]; then
        echo "没有找到蓝牙适配器。"
        exit 1
    fi
}

function get_bluetooth_paired_devices() {
    # 蓝牙适配器
    for adapter in $bluetooth_adapters; do
        adapter_dir="/var/lib/bluetooth/$adapter"
        bluetooth_paired_devices=$(ls $adapter_dir | grep -E '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
        if [[ -z "$bluetooth_paired_devices" ]]; then
            echo "适配器 $adapter 没有找到配对设备。"
            exit 1
        fi

        # 蓝牙配对设备
        for device in $bluetooth_paired_devices; do
            local info_file="$adapter_dir/$device/info"
            local name=$(grep -o 'Name=.*' "$info_file" | sed 's/Name=//' 2>/dev/null)
            local paired_devices_list+="Adapter: $adapter Device: $name ($device)"$'\n'
        done
    done
    # 选中设备
    selected_device=$(echo -e "$paired_devices_list" | sed '$d' | gum choose --header "选择蓝牙配对设备")
    selected_device_id=$(echo "$selected_device" | awk '{print $NF}' | tr -d '()')
    selected_device_info_file="$adapter_dir/$selected_device_id/info"
    selected_device_dir=$adapter_dir/$selected_device_id
    action_handler
}

function action_handler() {
    if [[ -n "$selected_device" ]]; then
        action=$(gum choose --header "执行操作" "view_devices" "edit_devices" "rename_devices")
        eval $action
    fi
}

function edit_devices() {
    vim $selected_device_info_file
}
function view_devices() {
    gum pager <$selected_device_info_file
}
function rename_devices() {
    new_device_id=$(gum input --placeholder "$selected_device_id")
    # 校验格式
    if [[ $new_device_id =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        gum confirm "确定重命名吗？ 设备 ID 将由 $selected_device_id 变为 $new_device_id" && mv $selected_device_dir $adapter_dir/$new_device_id || echo "取消重命名"
    else
        echo "输入格式不正确"
    fi

}

# todo 检查命令工具
# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本"
    exit 1
fi

# 循环
while true; do
    get_bluetooth_adapters
    get_bluetooth_paired_devices
    read -p "按任意键返回主菜单，或按两次 Ctrl+C 退出..." -n 1 -t 0.5
done
