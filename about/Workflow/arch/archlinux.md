
# 准备
## 终端大小
```
setfont ter-132n
```
## 网络
**无线连接**
[https://wiki.archlinux.org/title/Iwd#iwctl](https://wiki.archlinux.org/title/Iwd#iwctl)
**有线连接**
```
ip a add 192.168.100.2/24 dev enp1s0
ip link set enp1s0 up
ip r add default via 192.168.100.1
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```
## 远程安装
```
systemctl start sshd
passwd
ip a
ssh root@ip.address.of.arch-target-device
```
# 基础环境
## 设置键盘布局
```
使用 localectl status  查看当前的键盘配置。

使用 localectl list-keymaps  查看可用值。

loadkeys us-acentos

https://wiki.archlinux.org/title/Linux_console_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)/Keyboard_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E6%9F%A5%E7%9C%8B%E9%94%AE%E7%9B%98%E8%AE%BE%E7%BD%AE
```
## 验证启动模式
```
如果在 UEFI 主板上启用了 UEFI 模式，安装程序将相应地启动 Arch。

通过列出以下内容来验证系统是否通过UEFI启动...efivars

ls /sys/firmware/efi/efivars
如果该目录不存在，则系统以 BIOS 模式引导。

```
### 更新系统时钟
```
timedatectl set-ntp true
timedatectl status

```
## 分区
## BTRFS
```
通过运行 来确定将安装 Arch Linux 的内部存储设备。lsblk -f
export disk="/dev/nvme0n1"


使用 BTRFS 格式化根分区：mkfs.vfat -F32 /dev/sda1
mkfs.btrfs /dev/mapper/luks
mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@log
btrfs sub create /mnt/@.snapshots
umount /mnt
挂载子卷：

mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p2 /mnt

nodiratime


mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs}
 mkdir -p /mnt/{boot/efi,home,var/log,var/cache/pacman/pkg,btrfs,tmp}

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/nvme0n1p2 /mnt/home

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@pkg /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvolid=5 /dev/nvme0n1p2 /mnt/btrfs

挂载 EFI 分区

# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot





```
```
pacstrap /mnt linux-zen linux-firmware base base-devel btrfs-progs intel-ucode nano

（如果您有 AMD CPU，则需要安装而不是amd-ucodeintel-ucode);

生成 /etc/fstab：
genfstab -U /mnt >> /mnt/etc/fstab

是时候 chroot 进入系统了：
arch-chroot /mnt/

创建用户和密码的时间，首先是 root 密码：
passwd

现在，创建一个用户：
useradd -mG wheel <YOUR-USERNAME>

现在编辑 sudoers 文件以授予用户 sudo 权限（您可以使用任何终端文本编辑器，但我将使用 nano）：
EDITOR=nano visudo

并取消注释此行：

##Uncomment允许组轮的成员执行任何命令
%wheel ALL=(ALL) ALL

现在是用户的密码：
passwd <YOUR-USERNAME>

设置主机名：
echo <YOUR-HOSTNAME> > /etc/hostname

取消注释以下 /etc/locale.gen 行：
en_US.UTF-8 UTF-8
<YOUR-LANGUAGE>.UTF-8 UTF-8

设置区域设置：
echo LANG=<YOUR-LANAGUAGE>.UTF-8 > /etc/locale.conf

生成区域设置：
locale-gen

现在让我们找出您的时区：

OR

（如果您已经知道系统使用的区域）;timedatectl list-timezones | lesstimedatectl list-timezones | grep <YOUR-REGION>

设置时区：
ln -sf /usr/share/zoneinfo/<YOUR-REGION>/<YOUR-ZONE> /etc/localtime

现在是时候将系统时钟与时区同步了：hwclock --systohc

在 /etc/hosts 中定义主机：
nano /etc/hosts

127.0.0.1 本地主机
：：1 本地主机
127.0.1.1 <您的主机名>.localdomain <您的主机名>

配置 initramfs 的创建：

将模块更改为：
MODULES=（btrfs） 和 HOOKS=...到：\nano /etc/mkinitcpio.conf

HOOKS=（base udev systemd autodetect keyboard modconf block sd-encrypt filesystems）

重新创建初始化框架：
mkinitcpio -P

现在让我们为您的系统安装一些其他有用的软件包：
pacman -S linux-zen-headers networkmanager dialog wpa_supplicant mtools dosfstools git xdg-utils xdg-user-dirs alsa-utils pipewire pipewire-alsa pipewire-pulse apparmor sbctl

您还可以安装：

bash-completion如果您想在终端上增加一些功能;
network-manager-applet如果您依赖WiFi，但您可以在安装DE / WM后将其卸载;
bluez如果您的系统中有蓝牙支持;bluez-utils
cups如果你有一台打印机，如果你有一台HP打印机，只需要后者;hplip
安装后，为以下软件包启用服务：systemctl enable NetworkManager apparmor (bluetooth cups - optional)

现在让我们配置系统启动！
```
## 安装引导加载程序
```
安装系统启动：
bootctl --path=/boot install

您可以附加根分区的 UUID 以节省时间：
echo blkid -s UUID -o value /dev/sda2 >> /boot/loader/entries/arch.conf

然后编辑 /boot/loader/entries/arch.conf 并填充它：

title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options rd.luks.name=<UUID OF ROOT PARTITION>=luks root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=<UUID AGAIN>=discard rw quiet lsm=lockdown，yama，apparmor，bpf

编辑文件 /boot/loader/loader.conf 并添加：

默认 arch.conf
编辑器 no

如果要选择操作系统，则还需要取消注释并将数字更改为您希望promt在启动时显示的数字。timeout

退出 chroot，卸载分区并重新启动：

exit
umount -a
reboot
```
## 镜像源
[https://man.archlinux.org/man/reflector.1#EXAMPLES](https://man.archlinux.org/man/reflector.1#EXAMPLES)
```

选择在过去 12 小时内同步且位于法国或德国的 HTTPS 镜像，按下载速度对它们进行排序，然后用结果覆盖文件 /etc/pacman.d/mirrorlist：

reflector --country china --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

cat /etc/pacman.d/mirrorlist

pacman -Syy
```
# **安全启动 + TPM 2.0**
```
我们已经在步骤1中安装了，所以让我们使用它。
首先，在系统 BIOS 中，应该有一个用于删除所有键或启用设置模式的选项。之后，启用安全启动，当您重新启动时，您应该会看到如下命令：sbctlsbctl status

==>警告：安装模式：已启用
==>警告：安全启动：已禁用

现在，您只需要按照GitHub页面中的说明进行操作即可。
但是，如果您遇到错误，特别是在 期间，就像我的情况一样，您可能需要按以下顺序使用此命令安装并手动注册密钥：sbctl enroll-keysefitools
efi-updatevar -f /usr/share/secureboot/keys/db/db.auth db
efi-updatevar -f /usr/share/secureboot/keys/KEK/KEK.auth KEK
efi-updatevar -f /usr/share/secureboot/keys/PK/PK.auth PK

之后，不要忘记签署你的引导加载程序和你的（在这种情况下，因为我们安装了zen内核）。在那之后，它应该只是工作。/vmlinuz-linux-zen

最后但并非最不重要的一点是，TPM 2.0。通过运行 或 来检查系统是否支持它。如果你有，就走吧！cat /sys/class/tpm/tpm0/device/description/sys/class/tpm/tpm0/tpm_version_major

我们之前已经设置了 和 钩子，所以现在我们要做的就是运行以检查一切是否顺利。因此，您应该获得单个设备。如果一切正常，请运行：
（在我们的例子中为 /dev/sda2）。systemdsd-encryptsystemd-cryptenroll --tpm2-device=listsudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/sdX

之后添加到您的 .这意味着你最终应该看起来像这样：tpm2-device=autord.luks.options/boot/loader/entries/arch.confoptions

options rd.luks.name=<UUID OF ROOT PARTITION>=luks root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=<UUID AGAIN>=tpm2-device=auto，discard rw quiet lsm=lockdown，yama，apparmor，bpf

重新启动，如果一切正常，您现在应该访问登录管理器，而无需使用磁盘解密密码以获得更无缝的体验。
```

# 优化
## 安装sway后安装gnome
```
## 软件包
sudo pacman -S \
								git vim zsh lrzsz neofetch reflector \
								wqy-microhei wqy-microhei-lite \
              	firefox
                
## 镜像源
sudo reflector --country china --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist

## 输入法libpinyin
sudo pacman -S ibus-libpinyin

sudo bash -c 'cat << EOF >> /etc/environment
GTK_IM_MODULE=ibus
QT_IM_MODULE=ibus
XMODIFIERS=@im=ibus
EOF'

启动输入法模块
ibus-setup

GNOME 默认使用 IBus，因此您只需转到“设置”>键盘>输入源，然后为您选择的语言添加键盘布局。


## 蓝牙
sudo pacman -S bluez bluez-utils
systemctl enable --now bluetooth

## paru
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

## 应用
paru -S google-chrome timeshift jetbrains-toolbox obs-studio
--proxy-server="socks://127.0.0.1:1080"



## wayland支持
pacman -S qt5-wayland obs-studio
pacman -S xdg-desktop-portal-wlr libpipewire02

export QT_QPA_PLATFORM=wayland
https://cloud.tencent.com/developer/article/1903737
https://zhuanlan.zhihu.com/p/531205278

```
分数缩放
[https://github.com/puxplaying/mutter-x11-scaling](https://github.com/puxplaying/mutter-x11-scaling)
```
PS: 如果需要开启wayland显示需要编辑/etc/gdm3/custom.conf文件，设置WaylandEnable=true，然后注销，在登录账号密码界面的右下角齿轮选择 Wayland。

#要在Wayland上开启分数缩放：
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

#要在Xorg上开启分数缩放：
 mutter-x11-scalingAUR
$ gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
https://wiki.archlinux.org/title/HiDPI#Xorg

如果由于某种原因不喜欢更改，则可以使用以下命令返回：
gsettings reset org.gnome.mutter experimental-features

https://v2ex.com/t/862295



1.安装mutter-x11-scaling包
这是一个简短的指南，向您展示如何安装mutter-x11-scaling软件包：

sudo pacman -Sy
复制
sudo pacman -S mutter-x11-scaling
复制
2.卸载/删除mutter-x11-scaling包
在本节中，我们将解释卸载mutter-x11-scaling软件包的必要步骤：

sudo pacman -Rcns mutter-x11-scaling
```
画面撕裂
[https://www.wyr.me/post/718](https://www.wyr.me/post/718)
安装 xf86-video-intel
[https://github.com/ourongxing/Solve-the-problem/issues/12](https://github.com/ourongxing/Solve-the-problem/issues/12)
[https://askubuntu.com/questions/1164654/configure-xorg-to-use-integrated-intel-not-nvidia](https://askubuntu.com/questions/1164654/configure-xorg-to-use-integrated-intel-not-nvidia)
[https://www.jianshu.com/p/01d41ced5903](https://www.jianshu.com/p/01d41ced5903)



# ubuntu
chrome 安装
[https://linuxhint.com/install_google_chrome_ubuntu_ppa/](https://linuxhint.com/install_google_chrome_ubuntu_ppa/)
Ubuntu下google不能正确代理的解决方法 [https://onlycaptain.github.io/2018/10/01/Ubuntu%E4%B8%8Bgoogle%E4%B8%8D%E8%83%BD%E6%AD%A3%E7%A1%AE%E4%BB%A3%E7%90%86%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/](https://onlycaptain.github.io/2018/10/01/Ubuntu%E4%B8%8Bgoogle%E4%B8%8D%E8%83%BD%E6%AD%A3%E7%A1%AE%E4%BB%A3%E7%90%86%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/)

toolbox
[https://gist.github.com/greeflas/431bc50c23532eee8a7d6c1d603f3921](https://gist.github.com/greeflas/431bc50c23532eee8a7d6c1d603f3921)




# mibox
[https://github.com/juewuy/ShellClash](https://github.com/juewuy/ShellClash)
```
http://<IP>/cgi-bin/luci/;stok=<STOK>/api/misystem/set_config_iotdev?bssid=Xiaomi&user_id=longdike&ssid=-h%3B%20nvram%20set%20ssh_en%3D1%3B%20nvram%20commit%3B%20sed%20-i%20's%2Fchannel%3D.*%2Fchannel%3D%5C%22debug%5C%22%2Fg'%20%2Fetc%2Finit.d%2Fdropbear%3B%20%2Fetc%2Finit.d%2Fdropbear%20start%3B
http://<IP>/cgi-bin/luci/;stok=<STOK>/api/misystem/set_config_iotdev?bssid=Xiaomi&user_id=longdike&ssid=-h%3B%20echo%20-e%20'admin%5Cnadmin'%20%7C%20passwd%20root%3B
ssh root@192.168.0.1
root admin

```

```
   1  sudo pacman -S 								git vim zsh lrzsz neofetch reflector 								wqy-microhei wqy-microhei-lite \
    2  sudo pacman -S 								git vim zsh lrzsz neofetch reflector 								wqy-microhei wqy-microhei-lite 
    3  sudo reflector --country china --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    4  cat /etc/pacman.d/mirrorlist
    5  sudo pacman -S ibus-libpinyin
    6  cat /etc/environment
    7  echo << EOF >> /etc/environment
    8  GTK_IM_MODULE=ibus
    9  QT_IM_MODULE=ibus
   10  XMODIFIERS=@im=ibus
   11  EOF
   12  sudo echo << EOF >> /etc/environment
   13  GTK_IM_MODULE=ibus
   14  QT_IM_MODULE=ibus
   15  XMODIFIERS=@im=ibus
   16  EOF
   17  sudo bash -c echo << EOF >> /etc/environment
   18  GTK_IM_MODULE=ibus
   19  QT_IM_MODULE=ibus
   20  XMODIFIERS=@im=ibus
   21  EOF
   22  sudo bash -c "echo << EOF >> /etc/environment
   23  GTK_IM_MODULE=ibus
   24  QT_IM_MODULE=ibus
   25  XMODIFIERS=@im=ibus
   26  EOF"
   27  cat /etc/environment
   28  sudo bash -c "echo << EOF >> /etc/environment
   29  GTK_IM_MODULE=ibus
   30  QT_IM_MODULE=ibus
   31  XMODIFIERS=@im=ibus
   32  EOF"
   33  cat /etc/environment
   34  sudo bash -c "echo << EOF >> ~/environment
   35  GTK_IM_MODULE=ibus
   36  QT_IM_MODULE=ibus
   37  XMODIFIERS=@im=ibus
   38  EOF"
   39  ls ~
   40  sudo bash -c 'cat << EOF >> /etc/environment
   41  line1
   42  line2
   43  line3
   44  EOF'
   45  cat /etc/environment
   46  vi /etc/environment 
   47  vim /etc/environment 
   48  sudo vim /etc/environment 
   49  sudo bash -c 'cat << EOF >> /etc/environment
   50  GTK_IM_MODULE=ibus
   51  QT_IM_MODULE=ibus
   52  XMODIFIERS=@im=ibus
   53  EOF
   54  '
   55  sudo pacman -S bluez bluez-utils
   56  systemctl enable --now bluetooth
   57  sudo pacman -S --needed base-devel
   58  git clone https://aur.archlinux.org/paru.git
   59  cd paru && makepkg -si
   60  cd paru && makepkg -si
   61  cd  makepkg -si
   62  makepkg -si
   63  makepkg -si
   64  makepkg -si
   65  paru -S google-chrome timeshift toolbox obs-studio
   66  paru -S google-chrome timeshift toolbox obs-studio
   67  paru -S google-chrome timeshift toolbox obs-studio
   68  paru -S  timeshift toolbox 
   69  paru -S  toolbox 
   70  paru -R  toolbox 
   71  paru -S  jetbrains-toolbox
   72  paru -S  jetbrains-toolbox
   73  systemctl start sshd 
   74  ip a
   75  ibus-setup 
   76  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   77  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   78  sudo pacman -Syu
   79  google-chrome-stable 
   80  sudo vim /etc/fstab 
   81  cp /etc/fstab /etc/fstab.back
   82  sudo cp /etc/fstab /etc/fstab.back
   83  sudo vim /etc/fstab 
   84  reboot
   85  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   86  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   87  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   88  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   89  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
   90  paru -S gnome-browser-connector
   91  paru -S gnome-shell-extension-pop-shell 
   92  paru -S gnome-shell-extension-pop-shell 
   93  paru -S gnome-shell-extension-pop-shell 
   94  paru -S 
   95  sudo pacman -S git typescript make
   96  git clone https://github.com/pop-os/shell.git
   97  paru -S 	gnome-shell-extension-pop-shell-git
   98  paru -S 	gnome-shell-extension-pop-shell-git
   99  ping github
  100  ping github.com
  101  ping github.com
  102  ping github.com
  103  ping github.com
  104  ping github.com
  105  ping github.com
  106  ping github.com
  107  vim /etc/hostname 
  108  vim /etc/hosts 
  109  sudo vim /etc/hosts 
  110  sudo vim /etc/hosts 
  111  ping github.com
  112  cat /etc/resolv.conf 
  113  sudo vim /etc/hosts 
  114  ping github.com
  115  paru -S 	gnome-shell-extension-pop-shell-git
  116  paru -S 	touchegg
  117  ping github.com
  118  paru -S 	touchegg
  119  paru -S 	gnome-shell-extension-pop-shell-git
  120  paru -S 	gnome-shell-extension-pop-shell-git
  121  gnome-shell-extension-pop-shell-git
  122  gnome-shell-extension-tool 
  123  sudo systemctl enable touchegg.service
  124  sudo systemctl start  touchegg.service
  125  history 
  126  gsettings --schemadir ~/.local/share/gnome-shell/extensions/pop-shell@system76.com/schemas set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
  127  history 
  128  gsettings --schemadir ~/.local/share/gnome-shell/extensions/pop-shell@system76.com/schemas set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
  129  set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
  130  paru -R 	gnome-shell-extension-pop-shell-git
  131  history 
  132  set org.gnome.shell.extensions.pop-shell activate-launcher "['']"
  133  set org.gnome.shell.extensions.pop-shell 
  134  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  135  gconf-editor
  136  sudo nautilus
  137  paru -R 	gnome-shell-extension-pop-shell-git
  138  paru -S gnome-shell-extension-pop-shell
  139  paru -R gnome-shell-extension-pop-shell
  140  paru -R gnome-shell-extension-pop-shell-bin
  141  paru -S gnome-shell-extension-pop-shell-bin
  142  gconf-editor
  143  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  144  paru -S 	gnome-shell-extension-pop-shell-git
  145  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  146  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  147  paru -R 	gnome-shell-extension-pop-shell-git
  148  history  |grep bin
  149  paru -R gnome-shell-extension-pop-shell-bin
  150  paru -S 	gnome-shell-extension-pop-shell-git
  151  sudo pacman -S  mutter-x11-scalingAUR
  152  paru -S  mutter-x11-scalingAUR
  153  paru -S  mutter-x11-scaling
  154  gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
  155  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  156  xrandr --output eDP1 --scale 1.25x1.25
  157  paru -R  mutter-x11-scaling
  158  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  159  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  160  	
  161  gsettings reset org.gnome.mutter experimental-features
  162  paru -R  mutter-x11-scaling
  163  sudo pacman -S gnome-screenshot
  164  history > his
  165  ls
  166  vim his 
  167  vim his 
  168  cat his 
  169  rm -rf his 
  170  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  171  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  172  google-chrome-stable --proxy-server="socks://192.168.0.217:7890"
  173  paru -S AutomaThemely
  174  paru -S automathemely
  175  automathemely 
  176  automathemely
  177  paru -R automathemely
  178  sudo pacman -S nvidia-settings
  179  pacman -S bluetoothctl
  180  sudo pacman -S bluetoothctl
  181  paru -S bluetoothctl
  182  sudo pacman -Suy
  183  paru -S gnome-shell-extension-arch-update
  184  paru -S gnome-shell-extension-user-theme-x-git
  185  bluetoothctl
  186  sudo pacman -S bluez-utils
  187  bluetoothctl
  188  paru -S gnome-shell-extension-user-theme-x-git
  189  nvidia-smi 
  190  watch nvidia-smi 
  191  watch nvidia-smi 
  192  cd ~/Templates/
  193  touch NEW
  194  google-chrome-stable  --proxy-server="socks://192.168.0.217:7890"
  195  google-chrome-stable  --proxy-server="socks://192.168.0.217:7890"
  196  google-chrome-stable  --proxy-server="socks://192.168.0.217:7890"
  197  bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecassiors/dotfiles/master/scripts/enable_chrome_dark_mode.sh")")
  198  bash -c "$(curl -fsSL "https://raw.githubusercontent.com/felipecassiors/dotfiles/master/scripts/enable_chrome_dark_mode.sh")"
  199  history 

```
[google chrome does not detect system dark theme in Fedora 36 with Gnome](https://superuser.com/questions/1721753/google-chrome-does-not-detect-system-dark-theme-in-fedora-36-with-gnome)

## ZSH
```
## 基础
paru -S zsh 
## arch配置
paru -S grml-zsh-config
## 主题 https://github.com/romkatv/powerlevel10k#arch-linux
paru -S --noconfirm zsh-theme-powerlevel10k-git
paru -S awesome-terminal-fonts-git powerline-fonts-git ttf-meslo-nerd-font-powerlevel10k
pacman -S zsh-theme-powerlevel10k  awesome-terminal-fonts powerline-fonts 	
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# 优化 https://wiki.archlinux.org/title/zsh#Fish-like_syntax_highlighting_and_autosuggestions
paru -S  zsh-syntax-highlighting  zsh-autosuggestions 
echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >>~/.zshrc
参考
https://blog.csdn.net/qq_21933797/article/details/118284955
https://www.zzxworld.com/posts/zsh_install_guide
https://archlinux.org/packages/extra/any/grml-zsh-config/
https://github.com/romkatv/powerlevel10k#arch-linux

https://davidtsadler.com/posts/arch/2020-09-07/installing-zsh-and-powerlevel10k-on-arch-linux/
```
autoload -Uz compinit 
compinit
改字体
[https://writings.sh/post/commandline-tools](https://writings.sh/post/commandline-tools)

[在archlinux中如何安装老版本软件](https://zhuanlan.zhihu.com/p/260993724)
[How to Prevent Packages From Getting Updated in Arch Linux](https://www.makeuseof.com/prevent-packages-from-getting-updated-arch-linux/)


## vsbox
[https://linuxhint.com/install-virtualbox-arch-linux/](https://linuxhint.com/install-virtualbox-arch-linux/)
[https://wiki.archlinux.org/title/VirtualBox#Extension_pack](https://wiki.archlinux.org/title/VirtualBox#Extension_pack)
Oracle Extension Pack 提供了[额外的特性](https://www.virtualbox.org/manual/ch01.html#intro-installing)，并且是在非免费许可下发布的**，仅供个人使用**。要安装它，可以使用[virtualbox-ext-oracle](https://aur.archlinux.org/packages/virtualbox-ext-oracle/)AUR包，并且可以在[seblu](https://wiki.archlinux.org/title/Unofficial_user_repositories#seblu)存储库中找到预构建的版本。


## wayland
[https://github.com/fcitx/fcitx5/issues/263](https://github.com/fcitx/fcitx5/issues/263)
[https://a-wing.top/linux/2022/01/03/translate_wayland#%E8%BD%AF%E4%BB%B6%E5%8C%85](https://a-wing.top/linux/2022/01/03/translate_wayland#%E8%BD%AF%E4%BB%B6%E5%8C%85)
## 解压zip乱码
 在archlinux日常使用中ark是一个常用的图形化压缩/解压缩工具，经常用于各种压缩包的处理。
 然而在面对由windows打包的很多zip格式压缩包时，会由于编码错误的原因，导致文件及文件夹的名称出现乱码。
 解决的方法很简单，首先在安装位于aur仓库的p7zip-natspec软件包
 之后打开ark→设置→配置ark→插件菜单，并将菜单中的Info-zip和Libzip两个插件反选，之后选中P7zip插件，然后关闭所有ark窗口，即可正确的显示zip文件的文件名了。

1. 安装unarchiver，用unar解压zip文件。（给kde建了一个servicemenu包，直接右键解压：[https://aur.archlinux.org/packages/kde-servicemenus-unarchiver/）](https://aur.archlinux.org/packages/kde-servicemenus-unarchiver/%EF%BC%89)
2. 使用p7zip-natspec或者unzip-natspec。好处是在ark或者file-roller里浏览也不会乱码
3. 使用unzip-iconv。同上

这里附上链接：[http://tieba.baidu.com/p/4095309703](http://tieba.baidu.com/p/4095309703)



```bash
/usr/share/applications

sudo pacman -Rsc fcitx 
sudo pacman -S fcitx-im
sudo pacman -S fcitx-configtool
sudo pacman -S fcitx-googlepinyin

sudo virsh net-start default 

export https_proxy=http://127.0.0.1:34747;export http_proxy=http://127.0.0.1:34747;export all_proxy=socks5://127.0.0.1:34747

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub-set-default 'Advanced options for Arch Linux>Arch Linux, with Linux linux'\n\n

env WINEPREFIX="$HOME/.deepinwine/Deepin-QQ" /usr/bin/deepin-wine5  winecfg
env WINEPREFIX="$HOME/.deepinwine/Deepin-TIM" /usr/bin/deepin-wine5  winecfg
env WINEPREFIX="$HOME/.deepinwine/Deepin-WeChat" /usr/bin/deepin-wine5  winecfg

/sys/class/power_supply/BAT0/status
/sys/class/power_supply/BAT0/capacity
/sys/class/power_supply/BAT0/charge_control_end_threshold
/sys/class/power_supply/BAT0/status
/sys/class/power_supply/BAT0/charge_control_end_threshold
/etc/udev/rules.d/asus-battery-charge-threshold.rules\n
/sys/class/power_supply/BAT0/charge_control_end_threshold
/sys/class/power_supply/BAT0/charge_control_end_threshold
```
