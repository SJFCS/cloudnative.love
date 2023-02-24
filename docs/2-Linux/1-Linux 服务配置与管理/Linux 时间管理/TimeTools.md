---
title: 常用命令
tags: [Linux 时间管理]
sidebar_position: 1
---
本节介绍了 timedatectl,hwclock/clock,tzselect 命令的使用,包含如何修改 Hardware clock,Local time,time-zone 等内容。
## timedatectl
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
启动 NTP/Chrony 时间同步服务
```bash
timedatectl set-ntp 1
# yes/no,1/0,true/flase
```
禁用 NTP/Chrony 时间同步服务
```bash
timedatectl set-ntp 0
# yes/no,1/0,true/flase
```

## hwclock/clock
*hwclock is a tool for accessing the Hardware Clock*  
hwclock 和 clock 用法相近，只不过 clock 命令除了支持 x86 硬件体系外，还支持 Alpha 硬件体系。  
hwclock 可以将 System clock 写入 Hardware clock，它将会创建并更新 /etc/adjtime 。有关此文件详细信息请参见 [hwlock (8) The Adjtime File](https://man.archlinux.org/man/hwclock.8#The_Adjtime_File)。
### 查看当前时间设置
```bash
hwclock -r, --show           # 读取硬件时钟并打印结果
```
### 设置时间
```bash
# 设置 RTC (硬件时间)
hwclock --set --date="02/21/2023 10:19"
# hc代表硬件时间，sys代表系统时间
hwclock -s, --hctosys  # 硬件时钟到系统 		  set the system time from the hardware clock
hwclock -w, --systohc  # 系统到硬件时钟 		  set the hardware clock from the current system time      
hwclock     --systz    # 基于当前时区设置系统时间  set the system time based on the current timezone

hwclock     --adjust      # 调整RTC以说明系统漂移，因为时钟是最后一个设置或调整的
hwclock -u, --utc         # the hardware clock is kept in UTC
hwclock     --localtime   # the hardware clock is kept in local time
hwclock     --date <time> # specifies the time to which to set the hardware clock
```
## 自动设置 Time zone 时区
### 基于地理定位的设置
要根据 IP 地址位置自动设置时区，可以使用地理定位 API 检索时区，例如 `curl https://ipapi.co/timezone` ，并将输出传递给 timedatectl set-timezone 进行自动设置。一些提供免费或部分免费服务的地理知识产权应用程式介面如下:
[Abstract IP geolocation API](https://www.abstractapi.com/ip-geolocation-api)  
[FreegeoIP](https://freegeoip.app/) 
[IP-api](https://ip-api.com/)  
[IPAPI](https://ipapi.co/)  
[Ipdata](https://ipdata.co/)  
[Ipstack](https://ipstack.com/)  
[TimezoneApi](https://timezoneapi.io/)  
### 每次 NetworkManager 连接到网络时更新时区
创建 NetworkManager 调度程序脚本:

```bash title="/etc/NetworkManager/dispatcher.d/09-timezone"
#!/bin/sh
case "$2" in
    up)
        timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"
    ;;
esac
```
:::info
提示: 使用 `connectivity-change` 而不是 `up` 可以防止在连接 VPN 时发生时区更改。
:::
### 每个用户/会话或临时设置

如果你想让应用程序“看到”与系统时区不同的时区，设置 TZ 环境变量，例如:
```bash
$ date && export TZ=":/usr/share/zoneinfo/Asia/Shanghai" && date
Tue Feb 21 21:24:25 CST 2023
Tue Feb 21 21:24:25 CST 2023
```


