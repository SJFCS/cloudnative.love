---
title: ISC DHCP
sidebar_position: 1
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Linux 上使用最广泛的 DHCP 服务器是 ISC DHCP（Internet Systems Consortium DHCP）。大多数 Linux 发行版中预装了ISC DHCP。而且 ISC DHCP 是一种经过验证的解决方案，已经被广泛应用于生产环境中。

## ISC DHCP 安装

可以使用以下命令安装并启动 ISC DHCP 服务器：
<Tabs>
<TabItem value="Ubuntu/Debian">

```bash
sudo apt-get install isc-dhcp-server
dpkg -L isc-dhcp-server
sudo systemctl enable --now isc-dhcp-server
```
</TabItem>
<TabItem value="CentOS/RedHat">

```bash
sudo yum install dhcp
rpm -ql dhcp
sudo systemctl enable --now dhcp
```
</TabItem>
</Tabs>

安装后可以看到如下文件
```bash
# DHCP配置文件
/etc/dhcp/dhcpd.conf
/etc/dhcp/dhcpd6.conf
/etc/sysconfig/dhcpd
 # DHCP服务程序
/usr/sbin/dhcpd
# 中继命令程序，用于跨网段提供DHCP服务
/usr/sbin/dhcrelay
# 配置文件的范例文件
/usr/share/doc/dhcp-4.2.5/dhcpd.conf.example
/usr/share/doc/dhcp-4.2.5/dhcpd6.conf.example
# DHCP可以使用LDAP来存储和管理DHCP客户端的信息。
/usr/share/doc/dhcp-4.2.5/ldap
/usr/share/doc/dhcp-4.2.5/ldap/README.ldap
/usr/share/doc/dhcp-4.2.5/ldap/dhcp.schema
/usr/share/doc/dhcp-4.2.5/ldap/dhcpd-conf-to-ldap
# 存放租借信息（如IP）和租约信息（如租约时长）
/var/lib/dhcpd/dhcpd.leases
/var/lib/dhcpd/dhcpd6.leases
```
