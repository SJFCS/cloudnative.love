## wsl
用wsl2，因为wsl1不支持SYSV IPC
设置默认为WSL 2：
wsl --set-default-version 2
删除已有的WSL 分发版：
wsl --unregister DistributionName
切换WSL2版本：
wsl --set-version DistributionName 2


## 1
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

## 2
sudo sh -c "echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch'> /etc/pacman.d/mirrorlist"
sudo pacman -Syyu

安装reflector  选择最快的镜像源
sudo pacman -S reflector 
sudo reflector --verbose  --country china -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist

## 3
echo "set mouse=" >> ~/.vimrc


新修改了～/.vimrc 文件之后， 发现鼠标右健无法复制文本。
发现在配置文件(~/.vimrc)中发现,有这样一段话:
 11 " In many terminal emulators the mouse works just fine, thus enable it.
 12 if has('mouse')
 13   set mouse=a
 14 endif

在vim帮助文件中发现了如下的解释：
The mouse can be enabled for different modes:
                n       Normal mode
                v       Visual mode
                i        Insert mode
                c       Command-line mode
                h       all previous modes when editing a help file
                a       all previous modes
                r       for |hit-enter| and |more-prompt| prompt
Normally you would enable the mouse in all four modes with:
                :set mouse=a
When the mouse is not enabled, the GUI will still use the mouse for
modeless selection.  This doesn't move the text cursor.

所以配置文件中的set mouse=a启动了所有模式, vim接管了鼠标的控制。
其中涉及的背景知识是：
鼠标事件有两种处理方式，程序处理和 X 处理。
如果 X 负责处理，则是左键选择，中间粘贴。

要让 vim 中由 X 负责处理，有两个方法：
1. 按住 shift 键，然后选择，此时由 X 处理该选择，copy 选项就 enable 了。如果放掉shift键，则由 vim 处理该选择。
2. 在 .vimrc 中设置 set mouse= （就是说清空），此时vim永远不再干涉鼠标选择，永远把处理权交给 X，这个时候鼠标就处于无模式编辑状态， 当然也能用鼠标来切换vim里面的tab窗口了，vim中的编辑光标也不会跟随鼠标了。


## wsl
ctrl shit p
select default terminal








