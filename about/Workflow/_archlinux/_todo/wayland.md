
## wayland


- https://linuxiac.com/nvidia-with-wayland-on-arch-setup-guide/
- https://www.reddit.com/r/archlinux/comments/1c313xq/comment/kzgownh/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
- https://blog.taoky.moe/2023-05-22/wemeet-screencast-in-wayland.html

gnome 默认支持 wayland，但在某些情况下wayland会被禁用
1. 环境变量
sudo nano /etc/environment
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
2. WaylandEnable
sudo vim /etc/gdm/custom.conf 确保注释 #WaylandEnable=false
3. 启用 KMS
为了在 Nvidia 上实现 Wayland 的全面支持，需要通过添加内核参数来启用 DRM 内核模式设置
- https://wiki.archlinux.org/title/NVIDIA
- https://wiki.archlinux.org/title/Kernel_mode_setting
wayland 以来内核模式设置（KMS），若没启用 gdm会禁用wayland
- 更新 Mkinitcpio 模块
$ sudo vim /etc/mkinitcpio.conf
4. 添加 MODULES
MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)
保存，执行以下命令来重新生成initramfs镜像文件：
$ sudo mkinitcpio -P
内核 gpu驱动更新后通过hook自动配置 https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
5. 添加引导支持
对于 grub，编辑 sudo vim /etc/default/grub 文件，并添加 nvidia-drm.modeset=1：
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1  "
$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```
6. 禁用 GDM udev 规则
禁用 Wayland 的规则所在位置：
[/usr/lib/udev/rules.d/61-gdm.rules](https://gitlab.gnome.org/GNOME/gdm/-/blob/main/data/61-gdm.rules.in)。
/usr/lib/udev/rules.d/是系统路径，每次升级时都会被覆盖。 /etc/udev/rules.d/是自定义规则或用户修改的路径。
[请通过创建以下符号链接来覆盖这些规则](https://wiki.archlinux.org/title/GDM#Wayland_and_the_proprietary_NVIDIA_driver)
sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
该命令用于创建一个空的符号链接来禁用GDM的udev规则，这样做的目的是为了避免 GDM 强制使用 Xorg 作为显示服务器。通过禁用这些规则，用户可以在 GDM 登录界面选择使用 Wayland 或 X11 作为显示协议，从而提供了更多的灵活性和选择。这对于希望尝试或切换到 Wayland 显示协议的用户来说是有用的。
7. 重启并选择Wayland
配置完成后，重启电脑并进入gdm登录界面：会发现启动选择器的图形样式有所变化。你可以通过选择 GNOME 来启动 Wayland，或者通过选择 GNOME on Xorg 回到 X11。

8. 要确认你正在使用 Wayland，可以执行以下命令：    
$ echo $XDG_SESSION_TYPE

检查日志 journalctl -b |grep gdm
## 分数比例缩放 Fractional Scaling
ps: Tweaks 中唯一可用的缩放功能是字体。建议4k屏幕使用200%缩放 避免麻烦，

- https://www.reddit.com/r/archlinux/comments/1cxuiow/gnome_mutter_patch_with_xwayland_fractional/
- https://wiki.archlinux.org/title/HiDPI#Fractional_scaling
- https://wiki.archlinux.org/title/Variable_refresh_rate

可以使用 dconf-editor 开启  scale-monitor-framebuffer 和 variable-refresh-rate
开启
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate']"
重置
gsettings set org.gnome.mutter experimental-features "[]"
