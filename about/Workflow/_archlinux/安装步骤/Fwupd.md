https://wiki.archlinuxcn.org/wiki/Fwupd


paru -S fwupd

该软件包提供了一个fwupd.service，它将在收到第一个查询时自动启动fwupd守护程序。[1]第一章






显示fwupd检测到的所有设备：

$ fwupdmgr get-devices

要从Linux供应商固件服务（LVFS）下载最新元数据，请执行以下操作：

$ fwupdmgr refresh
注意：这可以通过启用fwupd-refresh.timer自动完成。

要列出可用于系统上任何设备的更新，请执行以下操作：

$ fwupdmgr get-updates


要安装更新，请执行以下操作：

$ fwupdmgr update

可以实时应用的更新将立即完成。
Updates that run at bootup will be staged for the next reboot.
在启动时运行的更新将在下次重新启动时暂存。
The root user may be required to perform certain device updates.
根用户可能需要执行某些设备更新。


## uefi
警告：更新UEFI固件可能会放弃当前的靴子加载程序安装。成功安装固件更新后，可能需要重新创建NVRAM条目（例如使用efibootmgr）。
