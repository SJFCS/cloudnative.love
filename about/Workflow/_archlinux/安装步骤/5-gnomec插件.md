## gnome extensions
安装浏览器插件https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html
paru -S gnome-browser-connector gnome-shell-extensions
or
paru -S extension-manager
paru -S gnome-shell-extension-pop-shell
  https://blogs.gnome.org/tbernard/2023/07/26/rethinking-window-management/
  https://extensions.gnome.org/extension/4481/forge/
  https://extensions.gnome.org/extension/6099/paperwm/


## dock & taskbar
- 推荐[App Icons Taskbar](https://extensions.gnome.org/extension/4944/app-icons-taskbar/)   暂无bug
- [Dash to Panel](https://extensions.gnome.org/extension/1160/dash-to-panel/)           win风格, 1. 直角边和激活下标有点丑  2. 分数比例缩放时候compiz-alike-magic-lamp-effect会错位  3. 如a lacritty chrome 打开界面后鼠标仍会转圈圈，此时是无法再次点击缩小的
  - 设置参数例子 https://fostips.com/dash-to-panel-gnome-45-support/
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)              mac风格, 缩小有bug 没深入使用
- 推荐 https://extensions.gnome.org/extension/1653/tweaks-in-system-menu/
## 窗口效果
- https://extensions.gnome.org/extension/3210/compiz-windows-effect/
- https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/ 苹果风格
- https://extensions.gnome.org/extension/4679/burn-my-windows/ 
## 全局效果
- 推荐触摸板 https://extensions.gnome.org/extension/4033/x11-gestures/
- 推荐(可被内置插件代替，但貌似这个更好一些) https://extensions.gnome.org/extension/615/appindicator-support/
- 推荐https://extensions.gnome.org/extension/3193/blur-my-shell/ 模糊透明效果 分数比例缩放时候有黑边闪烁bug
- 自定义按钮
- https://github.com/StorageB/custom-command-menu
- https://github.com/StorageB/custom-command-toggle
## 全局菜单
- https://github.com/Weather-OS/Fildem-v2?tab=readme-ov-file
- https://github.com/gonzaarcr/Fildem/pull/176
- https://extensions.gnome.org/extension/6230/bottom-overview/
 
## 系统工具
- 触摸板 https://extensions.gnome.org/extension/4033/x11-gestures/  paru -S touchegg systemctl enable --now touchegg
- 推荐 蓝牙https://extensions.gnome.org/extension/6670/bluetooth-battery-meter/
- https://extensions.gnome.org/extension/6778/airpod-battery-monitor/   用于 AirPods and Beats 设备的电量显示
- 推荐 paru -S  gnome-shell-extension-arch-update
检查命令: /bin/sh -c "/usr/bin/checkupdates; /usr/bin/paru -Qua"
更新命令: alacritty -e /bin/sh -c 'paru; echo Done - Press enter to exit; read'



- 推荐https://extensions.gnome.org/extension/1460/vitals/
- 推荐https://extensions.gnome.org/extension/1653/tweaks-in-system-menu/
- 推荐https://extensions.gnome.org/extension/7065/tiling-shell/
- 推荐https://extensions.gnome.org/extension/7/removable-drive-menu/
- 推荐https://extensions.gnome.org/extension/517/caffeine/
- 推荐https://extensions.gnome.org/extension/6307/quake-terminal/ 动画冲突https://github.com/diegodario88/quake-terminal/issues/41
- 推荐https://extensions.gnome.org/extension/5263/gtk4-desktop-icons-ng-ding/
- 推荐https://extensions.gnome.org/extension/7018/gpu-supergfxctl-switch/
- 推荐屏幕 ddc  https://extensions.gnome.org/extension/6325/control-monitor-brightness-and-volume-with-ddcutil/
sudo pacman -S ddcutil 
Version=8; gnome-extensions install https://extensions.gnome.org/api/v1/extensions/monitor-brightness-volume@ailin.nemui/versions/$Version/?format=zip
LOGOUT 不然提示找不到
gnome-extensions enable monitor-brightness-volume@ailin.nemui
gnome-extensions info monitor-brightness-volume@ailin.nemui


paru -S translate-shell https://extensions.gnome.org/extension/2959/light-dict/





关闭brul-my-shell 文件夹模糊，避免分数缩放闪烁黑框，开启v-shell重绘文件夹，关闭其模糊效果避免与 burl-my-shell冲突
用Transparent Top Bar代替不知是否可行


# 导出插件脚本
#!/bin/bash
# 输出表头
printf "%-70s | %-10s\n" "Extension Name" "Status"
printf "%-70s | %-10s\n" "----------------------------------------------------------------------" "------"
# 获取扩展名称和状态
for ext in $(gnome-extensions list); do
    name=$(gnome-extensions info "$ext" | grep -Po '(?<=名称:\s).*')
    state=$(gnome-extensions info "$ext" | grep -Po '(?<=状态:\s).*')
    printf "%-70s | %-10s\n" "$name" "$state"
done






| Extension Name               | Status |
| ---------------------------- | ------ |
| Tiling Shell                 | ACTIVE |
| Gtk4 Desktop Icons NG (DING) | ACTIVE |
| X11 Gestures                 | ACTIVE |
| Wiggle                       | ACTIVE | 晃动找到鼠标指针，wayland支持良好 x11 会出现错位 但不影响 |




| Extension Name                                     | Status      |
| -------------------------------------------------- | ----------- |
| App Icons Taskbar                                  | ACTIVE      |
| Bluetooth Battery Meter                            | ACTIVE      |
| Blur my Shell                                      | ACTIVE      |
| Caffeine                                           | ACTIVE      |
| Control monitor brightness and volume with ddcutil | ACTIVE      |
| GPU Supergfxctl Switch                             | ACTIVE      |
| Vitals                                             | ACTIVE      |
| Tweaks & Extensions in System Menu                 | ACTIVE      |
| Quake Terminal                                     | ACTIVE      |
| AppIndicator and KStatusNotifierItem Support       | ACTIVE      |
| Removable Drive Menu                               | ACTIVE      |
| Panel Workspace Scroll                             | ACTIVE      |
| V-Shell (Vertical Workspaces)                      | ACTIVE      |
| Customize IBus                                     | ACTIVE      |
| Wiggle                                             | ACTIVE      |
| Rounded Window Corners Reborn                      | ACTIVE      |
| Maximize To Empty Workspace                        | ACTIVE      |
| Remove World Clocks                                | ACTIVE      |
| Edit Desktop Files                                 | ACTIVE      |
| RebootIntoWindows                                  | ACTIVE      |
| Arch Linux Updates Indicator                       | ACTIVE      |
| Apps Menu                                          | INITIALIZED |
| Auto Move Windows                                  | INITIALIZED |
| Launch new instance                                | INITIALIZED |
| Light Style                                        | INITIALIZED |
| Native Window Placement                            | INITIALIZED |
| Places Status Indicator                            | INITIALIZED |
| Screenshot Window Sizer                            | INITIALIZED |
| Status Icons                                       | INITIALIZED |
| System Monitor                                     | INITIALIZED |
| User Themes                                        | INITIALIZED |
| Window List                                        | INITIALIZED |
| windowNavigator                                    | INITIALIZED |
| Space Bar                                          | ACTIVE      |