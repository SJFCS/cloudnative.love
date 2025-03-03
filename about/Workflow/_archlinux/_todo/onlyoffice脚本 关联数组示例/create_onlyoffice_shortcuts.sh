#!/bin/bash

# 设置快捷方式的基本信息
base_path="$HOME/.local/share/applications"
exec_path="/usr/bin/onlyoffice-desktopeditors"

# 创建快捷方式
declare -A actions=(
    ["NewDocument"]="--new:word"
    ["NewSpreadsheet"]="--new:cell"
    ["NewPresentation"]="--new:slid:wqe"
    ["NewForm"]="--new:form"
)

# 循环创建每个快捷方式
for action in "${!actions[@]}"; do
    desktop_file="$base_path/onlyoffice_$action.desktop"
    
    cat << EOF > "$desktop_file"
[Desktop Entry]
Version=1.0
Name=ONLYOFFICE $action
Comment=Create a new $action
Type=Application
Exec=$exec_path ${actions[$action]}
Terminal=false
Icon=onlyoffice-desktopeditors
Categories=Office;
EOF
done

echo "快捷方式已创建！"

