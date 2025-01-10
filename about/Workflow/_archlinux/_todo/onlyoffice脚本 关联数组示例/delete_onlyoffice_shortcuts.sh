#!/bin/bash

# 设置快捷方式的基本路径
base_path="$HOME/.local/share/applications"

# 创建快捷方式列表
declare -A actions=(
    ["NewDocument"]="onlyoffice_NewDocument.desktop"
    ["NewSpreadsheet"]="onlyoffice_NewSpreadsheet.desktop"
    ["NewPresentation"]="onlyoffice_NewPresentation.desktop"
    ["NewForm"]="onlyoffice_NewForm.desktop"
)

# 循环删除每个快捷方式
for action in "${actions[@]}"; do
    desktop_file="$base_path/$action"
    if [ -f "$desktop_file" ]; then
        rm "$desktop_file"
        echo "$desktop_file 已删除。"
    else
        echo "$desktop_file 不存在。"
    fi
done

echo "所有快捷方式已删除！"

