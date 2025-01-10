#!/bin/bash
set -e
set -o pipefail

# 参考文档
# https://sspai.com/post/78916
# https://sspai.com/post/80003
# https://www.youtube.com/watch?v=EimP1TtbDpw
# https://github.com/arcbjorn/arc-arch-linux-installation-guide
# https://github.com/Zelrin/arch-btrfs-install-guide
# https://lemmy.eus/post/2898
# https://github.com/Zelrin/arch-btrfs-install-guide
# https://arch.icekylin.online/guide/prepare/head-on-blow.html
# https://sakamotokurome.github.io/posts/archlinux/#%e5%ae%89%e8%a3%85%e5%bc%95%e5%af%bc%e7%a8%8b%e5%ba%8f
# todo:
# - 暂时放弃挂起休眠  罗技鼠标唤醒  https://blog.csdn.net/landian004/article/details/137124251 https://www.reddit.com/r/logitech/comments/1dk98qa/bolt_receiver_causes_linux_to_immediately_wake/ https://www.shuyz.com/posts/fix-linux-wakeup-right-after-suspend/
# - 暂时放弃wayland

## 连接WiFi
# 进入无线网管理交到提示符：
# iwctl
# 列出所有 WiFi 设备：
# device list
# 扫描wifi的网络：
# station wlan0 scan
# 列出网络列表
# station wlan0 get-networks
# 连接网络：
# station wlan0 connect your-wifi
# 最后 ctrl+D 退出

## paru包管理
sudo pacman -S --noconfirm --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd .. && rm -rf paru

# sudo sh -c 'cat >> /etc/profile << "EOF"
# # customize paru
# export paru_customize=true
# paru() {
#   if [[ $1 == "--customize" ]]; then
#     case $2 in
#       'enable')
#         export paru_customize=true
#         sed -i "s/export paru_customize=false/export paru_customize=true/" /etc/profile
#         echo "paru customize is enabled"
#         return
#         ;;
#       'disable')
#         export paru_customize=false
#         sed -i "s/export paru_customize=true/export paru_customize=false/" /etc/profile
#         echo "paru customize is disabled"
#         return
#         ;;
#       *)
#         echo "paru_customize: $paru_customize"
#         echo "change it use 'enable' or 'disable'。"
#         return
#         ;;
#     esac
#   fi

#   if [[ $paru_customize == "true" ]]; then
#     case $1 in
#       '-S')
#         command paru -S --noconfirm --needed "${@:2}"
#         ;;
#       '-R')
#         command paru -Rns --noconfirm "${@:2}"
#         ;;
#       '-I')
#         command paru -Qdtq
#         ;;
#       *)
#         command paru "$@"
#         ;;
#     esac
#   else
#     command paru "$@"
#   fi
# }
# EOF'
# source /etc/profile
## 蓝牙
systemctl enable --now bluetooth.service
## 打印 https://xuanwo.io/2019/09/19/archlinux-cups-connect/ https://energygreek.github.io/2021/03/10/setup-printer-use-avahi/
paru -S --noconfirm --needed cups
systemctl enable --now cups
## 中文字体 https://wiki.archlinuxcn.org/wiki/%E5%AD%97%E4%BD%93
paru -S --noconfirm --needed adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts \
  noto-fonts-sc noto-fonts-cjk \
  adobe-source-han-sans-cn-fonts \
  adobe-source-han-serif-cn-fonts \
  wqy-microhei wqy-zenhei wqy-bitmapfont
## 设置默认语言为中文
sudo sed -i 's/^#\(zh_CN.*\)/\1/' /etc/locale.gen
sudo locale-gen
locale -a
sudo sh -c 'echo "LANG=zh_CN.UTF-8" >/etc/locale.conf'
locale
# 注意：内核不支持tty显示中文，除非你使用的内核打了 cjktty 补丁能绘制中文字体，比如linux-lilyCNRepo）。或者使用fbterm、zhcon等
# 配置tty使用英文
# [[ $TERM = "linux" ]] && [[ -z $SSH_TTY ]] && [[ -z $DISPLAY ]] &&
sudo sh -c 'cat >> /etc/profile << "EOF"
# Set LANG to English if in TTY, not using SSH, and no desktop environment
if [[ "$(tty)" == "/dev/tty"* ]]; then
    export LANG="en_US.utf8"
    # Default config in /etc/locale.cnf will be used otherwise
fi
EOF'

# proxy切换在profile中添加
# proxy=http://$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*'):20172
#
# function setproxy() {
# export {http,https,ftp,all}_proxy=$proxy
# export {HTTP,HTTPS,FTP,ALL}_PROXY=$proxy
# }
#
# function unsetproxy() {
# unset {http,https,ftp,all}_proxy
# unset {HTTP,HTTPS,FTP,ALL}_PROXY
# }
#
# function showproxy() {
# env | grep -i proxy
# }

## 输入法
# https://loshine.github.io/2015/09/12/rime/
# https://sspai.com/post/84373
# https://github.com/iDvel/rime-ice/pull/679/files
# https://github.com/lei4519/blog/issues/85
paru -S --noconfirm --needed ibus ibus-rime rime-ice-git # 分别是框架 输入法 词库
sudo sh -c 'cat << EOF >> /etc/profile
# Set IBus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
EOF'

# gnome中手动启用输入法

# [org/gnome/desktop/input-sources]
# mru-sources=[('ibus', 'rime'), ('xkb', 'us')]
# sources=[('xkb', 'us'), ('ibus', 'rime')]
# xkb-options=['terminate:ctrl_alt_bksp']

cat <<EOF >$HOME/.config/ibus/rime/default.custom.yaml
patch:
  # 仅使用「雾凇拼音」的默认配置，配置此行即可
  __include: rime_ice_suggestion:/
  # 以下根据自己所需自行定义，仅做参考。
  # 针对对应处方的定制条目，请使用 <recipe>.custom.yaml 中配置，例如 rime_ice.custom.yaml
  __patch:
    key_binder/bindings/+:
      # 开启逗号句号翻页
      - { when: paging, accept: comma, send: Page_Up }
      - { when: has_menu, accept: period, send: Page_Down }
    ascii_composer:
      good_old_caps_lock: true
      switch_key:
        Caps_Lock: clear
        Control_L: noop
        Control_R: noop
        Shift_L: commit_code
        Shift_R: commit_code
EOF
# ibus-rime 设置输入框横排显示
sed -i 's/horizontal: false/horizontal: true/' ~/.config/ibus/rime/build/ibus_rime.yaml
ibus-daemon -drx
# vim default.yaml 删除sechema
# 如果用大字表，推荐安装[花园明朝字体](https://glyphwiki.org/hanazono/)，或者两分官网推荐的[天珩字库](http://cheonhyeong.com/Simplified/download.html)。
# 推荐[霞鹜文楷](https://github.com/lxgw/LxgwWenKai)，它能识别简体的「𰻝𰻝面 biang biang mian」中的「𰻝」😄，而且拿它做 Rime 的字体也不错。
# - 左右shift切换
#   https://github.com/iDvel/rime-ice/issues/120#issuecomment-1496868635
# - 删除错误词
#   选中已造词，使用 Shift + Delete 即可删除

# - https://pdog18.github.io/rime-soak/#/result
# - https://www.mintimate.cc/zh/
# - https://yuexun.me/blog/custom-input-methods-with-rime
# - https://zhuanlan.zhihu.com/p/91129641
# - https://github.com/rime/home/wiki/CustomizationGuide#%E5%9C%A8%E7%89%B9%E5%AE%9A%E7%A8%8B%E5%BA%8F%E8%A3%8F%E9%97%9C%E9%96%89%E4%B8%AD%E6%96%87%E8%BC%B8%E5%85%A5
# - https://sspai.com/post/84373
# https://ttys3.dev/blog/nvim-and-rime-esc-auto-switch

# https://github.com/iDvel/rime-ice/issues/399
# https://github.com/iDvel/rime-ice/issues/117
# https://github.com/iDvel/rime-ice/issues/1006

## nvim 发行版
https://www.lazyvim.org/
https://www.lunarvim.org/
https://nvchad.com/
https://astronvim.com/

paru -S xclip nvim
paru -R vim gvim
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
# https://harttle.land/2020/09/04/vim-clipboard.html
# https://harttle.land/2022/03/19/vim-copy-paste.html
# https://www.google.com/search?q=vim+set+tab+to+2+spaces&oq=vim+tab+2&gs_lcrp=EgZjaHJvbWUqCAgCEAAYCBgeMgYIABBFGDkyBwgBEAAYgAQyCAgCEAAYCBgeMggIAxAAGAgYHjIICAQQABgIGB4yCAgFEAAYCBgeMggIBhAAGAgYHjIGCAcQRRhB0gEINzU2NGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8

# 多屏幕登录界面
❯ sudo mkdir -p /etc/systemd/system/gdm.service.d/
❯ sudo vim /etc/systemd/system/gdm.service.d/override.conf

[Service]
ExecStartPre=/bin/cp /home/admin/.config/monitors.xml /var/lib/gdm/.config/monitors.xml
systemctl daemon-reload
systemctl restart gdm

# sudo cp ~/.config/monitors.xml  ~gdm/.config/
# sudo chown gdm:gdm ~gdm/.config/monitors.xml
# 上面这个不生效
# https://www.reddit.com/r/pop_os/comments/1czpboy/how_can_i_get_the_login_screen_to_honor_my/

# pacman -S xorg-xrandr
# xrandr 找到屏幕信息，用你的屏幕名替换下面的DP-1
# sudo sh -c 'cat << EOF >> /etc/X11/xorg.conf.d/10-monitor.conf
# Section "Monitor"
#   Identifier "DP-1"
#   Option "Primary" "true"
# EndSection
# EOF'
# 操作后，只需按 [Ctrl]+[Alt]+[F1] 切换到 gdm 屏幕即可立即看到差异。您可以通过输入密码解锁会话或按 [Ctrl]+[Alt]+[F2]（有时是 F3、F4... 直到 F6）返回会话。
# 这个方案会导致异常显示

# 下面这个提到的项目支持自由切换
# https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/3867
#   - https://github.com/derflocki/multi-monitor-login

# X11 分数比例缩放 Fractional Scaling   https://github.com/puxplaying/mutter-x11-scaling/tree/master
# - 若不使用分数缩放，可以通过Tweaks增加了文本大小$ gsettings get org.gnome.desktop.interface text-scaling-factor
# - https://www.reddit.com/r/linux/comments/tfp84r/fractional_scaling_is_broken_in_linux_we_have_to/
paru -S mutter-x11-scaling gnome-control-center-x11-scaling

# 要在安装运行后启用分数缩放：
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

## wayland
## 启用wayland 要先开启 nvidia drm
https://forum.endeavouros.com/t/how-can-i-enable-wayland-on-gnome/44961
https://wiki.archlinuxcn.org/wiki/HiDPI

systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
# 如果不起作用 ：sudo -s /dev/null /etc/udev/rules.d/61-gdm.rules （删除gnome的禁用waylan规则）
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']" # wayland，需要登出再登录 否则会出现窗口定位问题

#dbus-launch gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
#这里使用了 dbus-launch，这是为了在当前环境中启动一个新的 D-Bus 会话。如果你在一个没有运行 D-Bus 会话的环境（例如某些脚本或远程会话）中执行 gsettings，使用 dbus-launch 可以确保命令能够正确运行。
#dbus-gpt https://chatgpt.com/share/670fb3a8-6224-8001-8ed5-25dc37ac5ebd

# 关闭：gsettings reset org.gnome.mutter experimental-features
# 卸载 paru -S mutter gnome-control-center

# 然后打开“设置”>“显示”来设置比例。
# 存在问题：Integrated集成显卡的时候有光标闪烁问题，使用hybird则没问题
# - https://cn.v2ex.com/t/887419
# - https://askubuntu.com/questions/1234189/cursor-flickers-on-primary-display-when-fractional-scaling-is-enable-for-dual-mo

# 常见多屏缩放方案
# - https://blog.ihipop.com/2020/06/5250.html
# - https://wiki.archlinux.org/title/HiDPI#Xorg
# 整体放大到 2 倍，然后使用 xrandr 单独再缩小，还能每个屏幕不一样的缩放系数。切换配置用到 autorandr 。https://blog.ihipop.com/2020/06/5250.html

# 建议是买显示器之前就考虑好分辨率尺寸和缩放参数，尽量避免非整数缩放（历史遗留问题，处理起来很困难）和不同屏幕不同缩放参数（ Wayland 支持，但 X11 默认只支持相同的参数导致很多 Xwayland 程序要么糊要么小（也有分数比例缩放的补丁），要么就得用 randr 之类的办法才能达成，过于麻烦），所以最后选硬件时候花点工夫能省不少事情（4k）。

## rog
# - https://extensions.gnome.org/extension/5344/supergfxctl-gex/ 官方不更新了
# - https://extensions.gnome.org/extension/7018/gpu-supergfxctl-switch/ 扩展
# - https://asus-linux.org/guides/arch-guide/
# - https://asus-linux.org/guides/vfio-guide/

sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

curl -s "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" | sudo pacman-key -a -

sudo sh -c 'cat << EOF >> /etc/pacman.conf
[g14]
Server = https://arch.asus-linux.org
EOF'
sudo pacman -Suy
# Asusctl——自定义风扇配置文件、动漫、 LED 控制等。
sudo pacman -S asusctl power-profiles-daemon
systemctl enable --now power-profiles-daemon.service
# Supergfxctl——图形切换
sudo pacman -S supergfxctl switcheroo-control
sudo systemctl enable --now supergfxd
sudo systemctl enable --now switcheroo-control
# supergfxctl 无需 asusctl 即可使用。您可以switcherooctl launch your_command在混合命令中使用命令在 dGPU 上运行选定的程序。主命令运行的任何程序/命令都会继承选定的 GPU（因此使用 switcherooctl 启动 Steam 将使其中的任何游戏在 dGPU 上运行）。
# ROG 控制中心 GUI 工具
sudo pacman -S rog-control-center

sudo sed -i 's/"vfio_enable": false/"vfio_enable": true/' /etc/supergfxd.conf
sudo systemctl restart supergfxd

# 官方镜像地址 ：https://archlinux.org/mirrorlist/all/
## rankmirrors
# rankmirrors -n 1 mirrorlist
# rankmirrors /etc/pacman.d/mirrorlist
## Reflector
pacman -S reflector
reflector --verbose --country China -l 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# 包管理
# /etc/pacman.conf ，取消 #Color 的注释，
# /etc/paru.conf 取消注释 #BottomUp
