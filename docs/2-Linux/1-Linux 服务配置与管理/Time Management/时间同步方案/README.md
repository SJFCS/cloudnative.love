---
title: 时间同步
sidebar_position: 2
---
为了避免主机时间因为长期运作下所导致的时间偏差，进行时间同步 (synchronize) 是非常必要的。 Network Time Protocol (NTP 网络时间协议) 是一种通过分组交换、可变延迟数据网络来同步计算机系统时钟的协议。
 
本节介绍了以下 NTP 时间同步方案: 
- ntpdate + crontab
- ntpd
- chrony

import DocCardList from '@theme/DocCardList';

<DocCardList />


:::caution
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
:::caution
ESX VM 上的 VMware Tools 软件负责同步时间，因此不要在带有 VMware Tools 的 VM 上使用 ntpd/chrony。改为在主机上设置 NTPD/chrony，让 VMware Tools 完成剩下的工作。
:::


## 引文

:::tip 拓展阅读
- [使用对称密钥配置经过身份验证的 NTP](https://access.redhat.com/solutions/393663)
- [chrony 中的网络时间安全概述(NTS)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/)
- [assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/assembly_overview-of-network-time-security-in-chrony_configuring-basic-system-settings)
- [The Secure Network Time Protocol (NTPsec) Distribution](https://docs.ntpsec.org/latest/)
- [ntp-server-reachable-but-never-select-set-the-time](https://unix.stackexchange.com/questions/677523/ntp-server-reachable-but-never-select-set-the-time)
:::

