---
title: 时间同步方案
sidebar_position: 2
---
## Time synchronization
为了避免主机时间因为长期运作下产生的 [Time skew (时间偏移)](#什么是-time-skew)，进行 Time synchronize (时间同步) 是非常必要的。 Network Time Protocol (NTP 网络时间协议) 是一种通过分组交换、可变延迟数据网络来同步计算机系统时钟的协议。

:::warning
常见的 NTP 时间服务器:
1. [ntp.aliyun.com](https://help.aliyun.com/document_detail/92704.html)  
  阿里云 NTP 服务器，提供了阿里云内网和公网 NTP 服务器，用于同步各网络中 ECS 实例的本地时间。
1. [pool.ntp.org](https://www.pool.ntp.org/zh/use.html) 
  一个超大的 NTP 服务集群, 为上百万的客户端提供可靠易用的网络时间协议(NTP)服务的项目
:::tip

:::tip
在开始前请确保你已经设置了正确的时区和防火墙
- Time Zone
```bash
sudo timedatectl set-timezone "Asia/Shanghai" 
# sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

```
- Firewall
```bash title="防火墙"
# 打开防火墙端口以允许传入的 NTP 请求：
firewall-cmd --permanent --add-service=ntp

# UDP 端口号 123 必须在防火墙中打开以允许客户端访问：
firewall-cmd --permanent --zone=public --add-port=123/udp
# UDP 端口 323 必须在防火墙中打开才能从远程系统连接：
firewall-cmd --permanent --zone=public --add-port=323/udp

firewall-cmd --reload

```
:::
:::warning
ESX VM 上的 VMware Tools 软件负责同步时间，因此不要在带有 VMware Tools 的 VM 上使用 ntpd/chrony。改为在主机上设置 NTPD/chrony，让 VMware Tools 完成剩下的工作。
:::

import DocCardList from '@theme/DocCardList';

<DocCardList />

## 什么是 Time skew

没有一个时钟是完美的，不同的振荡频率导致了时钟出现误差。这种现象被称为 "time skew (时间偏移)" 或 "time drift (时间漂移)"。

`/etc/adjtime` 文件记录了时钟的漂移值。当使用 hwlock 设置硬件时钟时，新的漂移值和设置时钟的时间被写入文件 `/etc/adjtime`，覆盖以前的值。你也可以手动更新 `hwclock --adjust` 。当 hwlock 守护进程是启用时，在关机前也会更新时钟的漂移值。

:::info 注意
如果在前一次设置后24小时内再次设置时钟，则不重新计算漂移，因为时钟认为经过的时间周期太短，无法准确计算漂移。
:::

如果硬件时钟继续以大的增量丢失或获得时间，则可能记录了无效的漂移(但只适用于 hwlock 守护进程正在运行的情况)。如果硬件时钟时间设置不正确，或者时间标准没有与 Windows 或 macOS 安装同步，就会发生这种情况。通过首先删除文件/etc/adjtime，然后设置正确的硬件时钟和系统时钟时间，可以删除漂移值。然后你应该检查你的时间标准是否正确。


## 引文

:::tip 拓展阅读
- [使用对称密钥配置经过身份验证的 NTP](https://access.redhat.com/solutions/393663)
- [chrony 中的网络时间安全概述(NTS)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/)
- [assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings)
- [The Secure Network Time Protocol (NTPsec) Distribution](https://docs.ntpsec.org/latest/)
- [ntp-server-reachable-but-never-select-set-the-time](https://unix.stackexchange.com/questions/677523/ntp-server-reachable-but-never-select-set-the-time)
:::

