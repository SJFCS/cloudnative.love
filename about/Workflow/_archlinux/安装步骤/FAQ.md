如果误删了 /etc/profile，你可以按照以下步骤来恢复 Arch Linux 的默认配置：

1. 从 Arch Linux 系统包中恢复
/etc/profile 文件属于 filesystem 包的一部分。可以通过重新安装 filesystem 包来恢复该文件。执行以下命令：

sudo pacman -S filesystem --overwrite /etc/profile
这个命令会重新安装 filesystem 包，并覆盖 /etc/profile 文件。


ala 粘贴空行
原因是windows换行符

ala启动卡顿
ala 启动到错误的屏幕

ala 无法滚动查看历史记录



## 包管理
# --ignore --help --ignoregroup <软件包组>
#         command paru -S --noconfirm --needed "${@:2}"
#         ;;
#       '-R')
#         command paru -Rns --noconfirm "${@:2}"
-Rsn
-Q
在 Arch Linux 中，可以使用 pacman 命令来查找某个文件属于哪个安装包。你可以在终端中运行以下命令：
pacman -Qo /usr/bin/gnome-extensions-app

paru -Qqe


❯ pacman -Qs gnome-ssh-askpass
❯ pacman -Ql gnome-ssh-askpass4-git




paru 构建aur 提示 RROR: One or more files did not pass the validity check! 

但是我git克隆下来 makepkg -si就没问题，我怀疑是paru的缓存



清理 paru 的缓存：运行 paru -Scc 清理所有缓存