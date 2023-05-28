
PXE 引导

PXE（Preboot Execution Environment）是一种计算机启动方式，常用于无盘机和网络启动环境中。其实现方式为将操作系统映像文件存储在远端的 TFTP 服务器上，然后在计算机启动时通过网络协议（如 DHCP 和 TFTP）获取该映像文件。PXE 启动需要有 PXE 组件支持，PXELINUX 是一个流行的 PXE 组件之一。

使用 ISC DHCP 和 PXELINUX 实现 PXE 启动的流程如下：

安装并配置 ISC DHCP 服务器。在 DHCP 配置文件 dhcpd.conf 中添加如下代码：

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.20;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
    filename "pxelinux.0";
    next-server 192.168.1.100;
}
其中，filename 指定了 PXELINUX 启动程序的名称（可以根据具体情况进行修改），next-server 指定了 TFTP 服务器（本例中使用 192.168.1.100）。还可以在需要静态分配 IP 地址的主机中使用 host 命令添加条目。

安装 PXELINUX。首先需要安装 TFTP 服务器并将 PXELINUX 的启动文件和操作系统镜像（如 Linux 或 Windows）复制到服务器上的 TFTP 根目录中。

配置 PXELINUX 启动菜单。可以在 TFTP 根目录的 pxelinux.cfg 目录中创建一个名为 default 的文件，并在文件中添加如下代码：

default menu.c32
prompt 0
timeout 300
menu title PXE Boot Menu
label 1
menu label ^1) Install Linux
kernel vmlinuz
append initrd=initrd.img
label 2
menu label ^2) Install Windows
kernel ntkrnlpx.exe
append -s -tftp=server:/pxeboot/ntkrnlpx.exe -s -tftp=server:/pxeboot/ntdetect.com
其中，menu 命令定义了 PXE 启动菜单的样式，label 命令定义了菜单项，kernel 和 append 命令指定了操作系统内核和 Bootloader。这是一个简单的示例，你可以根据具体情况进行修改。

重启计算机并启用 PXE 启动。在计算机启动过程中按下配置键（通常是 F12 或 ESC），选择“启动网络”或“启动 PXE”，然后根据提示进行操作即可。

PXE 启动适用于无盘机、维护模式、安装操作系统等场景。使用 ISC DHCP 和 PXELINUX 实现 PXE 启动有很多自定义选择，个性化需求可以根据实际情况进行修改。