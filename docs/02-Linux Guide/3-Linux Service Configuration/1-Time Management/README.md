---
title: Time Management
---

在操作系统中存在 System clock (系统时钟), Hardware clock (硬件时钟),Coordinated Universal Time(协调世界时,UTC),Time Zone (时区),Daylight Saving Time (夏令时,DST)等概念，本节将解释它们是什么，以及在不同操作系统中的默认行为。

你可以在下列文章中学会如何读取和设置它们。  

import DocCardList from '@theme/DocCardList';

<DocCardList />

## 名词解释

### Hardware clock
Hardware clock (硬件时钟) 又称 **Real Time Clock (RTC 实时时钟)**，硬件时钟通常嵌入在计算机主板的 CMOS 芯片中，并由小型电池供电。它可以在计算机关闭时继续运行，并保持准确的时间，以便在下次开机时重新启动计算机时使用。

:::caution
系统开机时要读取 Hardware clock (硬件时钟)，然后根据时区/夏令时换算为 System clock (系统时钟)，然后系统时钟就会独立于硬件运行。

不同系统的 Hardware clock 的设置标准不同，详见: [Time standard 时间标准](#time-standard-时间标准)
:::

### System clock
System clock (系统时钟) 又称 **software clock (软件时钟)，Local time (本地时间)**
它是一个连续的脉冲，帮助计算机时钟保持正确的时间。它记录自 [epoch](https://www.computerhope.com/jargon/e/epoch.htm) 以来经过的秒数，并根据 `/etc/adjtime` 的内容计算当前日期和时间。系统关机时会根据系统时钟来设置硬件时钟。  

### Universal Time Coordinated
UTC [协调世界时](https://zh.wikipedia.org/zh-hans/%E5%8D%8F%E8%B0%83%E4%B8%96%E7%95%8C%E6%97%B6)是主要的世界时间标准。
### Time zone
Time zone (时区) 是根据世界各国家与地区不同的经度而划分的时间定义，全球共分为24个时区，这些时区决定了当地的本地时间。
- 如北京处于东八区，即北京时间为 UTC + 8。
- 中国标准时间用 CST (China Standard Time)表示。
### DST (Daylight Saving Time)
夏令时 [DST](https://en.wikipedia.org/wiki/Daylight_saving_time) 的典型实现是在春季将时钟拨快一小时（“ spring forward”），在秋季将时钟拨慢一小时（“ fall back”）以返回标准时间。

## Time standard 时间标准

不同操作系统对于设置硬件时钟( Hardware clock)的行为存在差异，其中常见的有两种方式： localtime (本地时间) 和 Coordinated Universal Time (协调世界时 UTC)。  

localtime (本地时间) 取决于当前时区，本地时间=UTC + 时区

如果一台机器上安装了多个操作系统，它们都将从相同的硬件时钟获得当前时间时，建议将其设置为 UTC 而不是本地时间，以避免系统间的冲突。

如果硬件时钟设置为本地时间将会导致以下问题：
- 多个操作系统可能会在 DST 改变后调整它，从而导致过度校正; 
- 当在不同时区之间旅行和使用其中一个操作系统重置系统/硬件时钟时 可能出现问题;
- 在引导过程中导致一些意想不到的行为例如，系统时间向后退等很多问题。

### Windows 中的 UTC
  
为了使 Windows 和 Linux 进行双重引导，建议将 Windows 配置为使用 UTC，而不是将 Linux 配置为使用 Local time 。您可以在管理员命令提示符下运行:
```powershell
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```
或者，创建一个包含以下内容的 * . reg 文件(在桌面上) ，然后双击它将其导入到注册表中:
```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation]
"RealTimeIsUniversal"=dword:00000001
```

### Ubuntu 中的 UTC
  
如果在 Ubuntu 安装期间在任何磁盘上检测到 Windows，Ubuntu 及其衍生产品的硬件时钟设置将被解释为 "Local time" 。这样做显然是为了让新的 Linux 用户不用编辑注册表就可以在他们的 Windows 电脑上试用 Ubuntu。要更改此行为，请参见 [timedatectl set-local-rtc](./时间管理工具/timedatectl.md) 。

## 引文
:::info 参考链接：
- [wiki-archlinux-System_time](https://wiki.archlinux.org/title/System_time) 
- https://linux.vbird.org/linux_server/redhat9/0440ntp.php
:::