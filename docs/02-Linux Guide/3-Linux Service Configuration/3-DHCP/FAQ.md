---
title: FAQ
sidebar_position: 4
---
## 补充
如果不让 dhcp 修改 `/etc/resolv.conf` 里的内容，可在网卡配置文件 `/etc/sysconfig/network-scripts/ifcfg-*` 里添加 `PEERDNS=no` 。

每次重启网卡默认都获取的同一个ip，有时候想换个ip都很麻烦。可在 `/var/lib/dhclient/` 目录下有`.leases`文件，将它们清空或者删除这些文件中对应网卡的部分，再重启网络就可以获取新的动态ip。或者，在 `/etc/sysconfig/network-scripts/ifcfg-eth0` 加入`DHCPRELEASE=yes`。 

当运行`ifdown eth0`的时候就会发出`dhcprelase`报文，查看`/etc/sysconfig/network-scripts/ifdown-eth`脚本中实际上是调用`dhclient`命令，用下面这个命令应该也可以。