---
title: Linux 时间管理
tags: [Linux 时间管理]
sidebar_position: 0
---
在 Linux 操作系统中，System clock (系统时钟)由 Hardware clock (硬件时钟) , UTC , time zone (时区) , Daylight Saving Time (DST 夏令时) 决定。本章节解释了它们是什么以及如何读取和设置它们。  
在系统运行过程中不可避免会产生 Time skew 现象，本章将列举了四种 Time synchronization 方案，及其配置方法。

## 名词解释
- **Hardware clock 硬件时钟**  
    *又称 Real Time Clock (RTC 实时时钟)，CMOS 时钟，BIOS 时间*  
	是主板上 BIOS 中保存的时间，由主板电池供电来维持运行，可在 BIOS 中进行设置。
	系统开机时要读取这个时间，并根据它来设定系统时钟。然后系统时钟就会独立于硬件运行。  
	:::caution 注意
	系统启动时根据硬件时钟设定系统时钟的过程可能存在时区换算，这要视具体的系统及相关设置而定。详见: [Time standard 时间标准](#time-standard-时间标准)
	:::
- **System clock 系统时钟**  
	*又称 software clock 软件时钟，Local time 本地时间*   
	它是一个连续的脉冲，帮助计算机时钟保持正确的时间。它记录自 [epoch](https://www.computerhope.com/jargon/e/epoch.htm) 以来经过的秒数，并根据 `/etc/adjtime` 的内容计算当前日期和时间。
- **UTC (Universal Time Coordinated)**  
  即[协调世界时](https://zh.wikipedia.org/zh-hans/%E5%8D%8F%E8%B0%83%E4%B8%96%E7%95%8C%E6%97%B6)是最主要的世界时间标准。
- **Time zone**  
	是根据世界各国家与地区不同的经度而划分的时间定义，全球共分为24个时区，这些时区决定了当地的本地时间。  
	比如北京处于东八区，即北京时间为 UTC + 8。  
    中国标准时间用 CST (China Standard Time)表示。
- **DST (Daylight Saving Time)**  
	夏令时 [DST](https://en.wikipedia.org/wiki/Daylight_saving_time) 的典型实现是在春季将时钟拨快一小时（“ spring forward”），在秋季将时钟拨慢一小时（“ fall back”）以返回标准时间。

## Time standard 时间标准

时间标准分为 localtime (本地时间) 和 Coordinated Universal Time (协调世界时 UTC).  
localtime (本地时间) 取决于当前时区，本地时间=UTC + 时区

如果一台机器上安装了多个操作系统，它们都将从相同的硬件时钟获得当前时间:  
建议将其设置为 UTC 而不是本地时间，以避免系统间的冲突。

如果硬件时钟设置为本地时间将会导致的问题：
- 多个操作系统可能会在 DST 改变后调整它，从而导致过度校正; 
- 当在不同时区之间旅行和使用其中一个操作系统重置系统/硬件时钟时 可能出现问题;
- 在引导过程中导致一些意想不到的行为例如，系统时间向后退等很多问题。


- **Microsoft Windows 中的 UTC**
  
  为了使用 Windows 进行双重引导，建议将 Windows 配置为使用 UTC，而不是将 Linux 配置为使用 Local time 。

  您可以在管理员命令提示符下运行:
  ```
  reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
  ```
  或者，创建一个包含以下内容的 * . reg 文件(在桌面上) ，然后双击它将其导入到注册表中:
  ```
  Windows Registry Editor Version 5.00

  [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation]
  "RealTimeIsUniversal"=dword:00000001
  ```

- **Ubuntu 中的 UTC**
  
  如果在 Ubuntu 安装期间在任何磁盘上检测到 Windows，Ubuntu 及其衍生产品的硬件时钟设置将被解释为"Local time"。这样做显然是为了让新的 Linux 用户不用编辑注册表就可以在他们的 Windows 电脑上试用 Ubuntu。要更改此行为，请参见 [timedatectl set-local-rtc](./常用命令#timedatectl) 。

## Time skew 时间偏移

没有一个时钟是完美的，不同的振荡频率导致了时钟出现误差。这种现象被称为“ time skew 时间偏移”或“ time drift 时间漂移”。

`/etc/adjtime` 文件记录了时钟的漂移值。当使用 hwlock 设置硬件时钟时，新的漂移值和设置时钟的时间被写入文件 `/etc/adjtime`，覆盖以前的值。你也可以手动更新 `hwclock --adjust` 。当 hwlock 守护进程是启用时，在关机前也会更新时钟的漂移值。

:::info 注意
如果在前一次设置后24小时内再次设置时钟，则不重新计算漂移，因为时钟认为经过的时间周期太短，无法准确计算漂移。
:::

如果硬件时钟继续以大的增量丢失或获得时间，则可能记录了无效的漂移(但只适用于 hwlock 守护进程正在运行的情况)。如果硬件时钟时间设置不正确，或者时间标准没有与 Windows 或 macOS 安装同步，就会发生这种情况。通过首先删除文件/etc/adjtime，然后设置正确的硬件时钟和系统时钟时间，可以删除漂移值。然后你应该检查你的时间标准是否正确。

## Time synchronization 时间同步

Network Time Protocol (NTP 网络时间协议) 是一种通过分组交换、可变延迟数据网络来同步计算机系统时钟的协议。

下面对比了常见 NTP 同步方式:  
使用和配置详见: [Time synchronization](./时间同步.md)

1. `ntpdate` 一般搭配 `Crontab` 来调整时间，因为 `ntpdate` 会直接修改时间，所以会造成时间的跳跃。当 `ntpdate` 发现你的时间快了，则会经历两个相同的时刻，对某些应用而言，这是致命的。因此，请放弃使用 `ntpdate` 来校时。且 `ntpdate` 无法修正时钟振荡频率，治标不治本。
2.  `ntpd` 和`Chrony` 的修正是连续的，通过减慢时钟或者加快时钟的方式连续的修正，会获得平滑的时间校正而不会造成时钟跳跃。并且可以在修正时间的同时，把 BIOS 计时器的振荡频率偏差记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时。
3. `Chrony` 可以更快的同步，从而最大程度减少了时间和频率误差，对于并非全天 24 小时运行的虚拟计算机而言非常有用，能够更好地响应时钟频率的快速变化，对于具备不稳定时钟的虚拟机或导致时钟频率发生变化的节能技术而言非常有用，而`ntpd`在时差较大时候会禁止同步
4. `Chrony` 通过 Internet 同步的两台机器之间的典型精度在几毫秒之内，在LAN上，精度通常为几十微秒。利用硬件时间戳或硬件参考时钟，可实现亚微秒的精度。  
   `NTP`精度在局域网内可达 0.1ms，在互联网上绝大多数的地方精度可以达到 1-50ms。
5. `Chrony` 无需对服务器进行定期轮询，因此具备间歇性网络连接的系统仍然可以快速同步时
6. [systemd-timesyncd](https://unix.stackexchange.com/questions/504381/chrony-vs-systemd-timesyncd-what-are-the-differences-and-use-cases-as-ntp-cli) 它实现了一个 SNTP 客户端

:::caution
- ESX VM 上的 VMware Tools 软件负责同步时间，因此不要在带有 VMware Tools 的 VM 上使用 ntpd。改为在主机上设置 NTPD，让 VMware Tools 完成剩下的工作。
- 唯一一个可以令时间发生跳变的点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用 ntpd/Chrony 来校准时钟，而不是调整计算机时钟上的时间。
:::


参考链接：[wiki-archlinux-System_time](https://wiki.archlinux.org/title/System_time) 