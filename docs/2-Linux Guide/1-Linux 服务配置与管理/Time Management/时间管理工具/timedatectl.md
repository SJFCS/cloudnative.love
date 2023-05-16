---
title: timedatectl
---
查看和修改系统时钟和时区设置

:::caution
- Timedatectl 的使用需要一个活动的 D-Bus。因此，可能无法在 chroot 下使用此命令(例如在安装期间)。在这些情况下，您可以使用 hwlock 命令，或者使用 [systemd-nspawn](https://wiki.archlinux.org/title/Systemd-nspawn) 代替 chroot。
- 如果 /etc/adjtime 不存在，Systemd 假设硬件时钟设置为 UTC。
:::
### 查看当前时间设置
```bash title="timedatectl 输出解内容解释"
$ timedatectl # or "timedatectl status"
      Local time: Wed 2023-02-22 13:47:09 CST   # 本地时间
  Universal time: Wed 2023-02-22 05:47:09 UTC   # 世界时间一般用 UTC
        RTC time: Wed 2023-02-22 05:47:07       # 硬件时间 BIOS 内记录的时间
       Time zone: Asia/Shanghai (CST, +0800)	# 时区，这里使用的是 CST(China Standard Time 中国标准时间) 为东八区即 UTC+8
     NTP enabled: yes							# NTP 开启状态
NTP synchronized: yes							# NTP 是否同步
 RTC in local TZ: no							# 是否将 RTC 设置为使用本地时区而非 UTC（默认系统启动时把 RTC 设为 UTC ，本地时间为 UTC+时区。）
      DST active: n/a							# 夏令时
```
### 设置系统时间

```bash
timedatectl set-time "YYYY-MM-DD HH:MM:SS" 
# 例如: 
timedatectl set-time "2023-02-20 09:58:20"
```
:::tip
如果提示 "Failed to set time: Automatic time synchronization is enabled"  
- 你可以先关闭 ntp 自动校时 `timedatectl set-ntp no` ,然后再次执行 `timedatectl set-time "2023-02-20 09:58:20"`
如果要恢复 ntp 自动校时，则执行: `timedatectl set-ntp yes`  
- 或者利用 date 命令来设置时间，`sudo date -s "2023-02-20 09:58:20"`
:::


### 管理系统时区
查看可用时区
```bash
$ timedatectl list-timezones
```
设置时区
```bash
$ timedatectl set-timezone "time-zone" 
# 例如：
timedatectl set-timezone Asia/Shanghai
```
:::tip
还可以通过 tzselect 交互式地选择时区。
:::
:::info
这将创建一个/etc/localtime 符号链接，指向 `/usr/share/zoneinfo/` 下的 `zoneinfo` 文件。  
如果你选择手动创建链接(例如在 chroot 中 timedatectl 不工作) ，请记住它必须是一个符号链接，如 [localtime (5)描述](https://man.archlinux.org/man/localtime.5#DESCRIPTION)
```bash
$ ln -sf /usr/share/zoneinfo/Zone/SubZone /etc/localtime
```
:::

### 设置硬件时间

硬件时间默认为 UTC
```bash
$timedatectl | grep local
RTC in local TZ: no
```

将 RTC (硬件时钟)作为为本地时间:
```bash
$ timedatectl set-local-rtc 1
```

要恢复到默认将 RTC (硬件时钟)作为 UTC :
```bash
$ timedatectl set-local-rtc 0
```
:::info
它们自动生成/etc/adjtime 并相应地更新 RTC 。
:::

### 管理 NTP 时间同步
:::info 参考文档
- [Arch-Wiki systemd-timesyncd](https://wiki.archlinux.org/title/systemd-timesyncd)
:::
如果只是简单做时间同步，可直接使用 systemd-timesyncd ，它在带有 systemd 的系统上充当简单的 sntp 客户端，不能像 chrony 和 ntpd 作为时间服务器使用。

```bash title="/etc/systemd/timesyncd.conf or /etc/systemd/timesyncd.conf.d/local.conf"
[Time]
NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org
```
查看你的配置 `timedatectl show-timesync --all`
:::caution
注意：如果您的系统没有chrony/ntp，则运行set-ntp子命令尝试激活 timesyncd 组件时遇到错误。
```bash
# timedatectl set-ntp true
Failed to set ntp: NTP not supported
```
:::
启动 NTP/Chrony 时间同步服务
```bash
timedatectl set-ntp yes
# yes/no,1/0,true/flase
```
禁用 NTP/Chrony 时间同步服务
```bash
timedatectl set-ntp no
# yes/no,1/0,true/flase
```