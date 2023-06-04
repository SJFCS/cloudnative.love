---
title: KVM
---
https://www.cnblogs.com/tcicy/p/10193614.html

Q: 虚拟机迁移如何强制停止？

A：确认虚拟机还在迁移数据阶段（确认目的存储池磁盘文件一直在增加），在目的主机将该进程强制kill，前台就会返回迁移失败报错，迁移停止。该操作有一定风险，请慎重操作。
root@cvk003-d05-08:~# virsh list --all

root@cvk003-d05-08:~# ps -ef | grep vm-name
root      3557     1 17 08:54 ?        00:15:23 /usr/bin/kvm -name                                                     -2-127
root@cvk003-d05-08:~# kill -9 3557


Q: 如何停止虚拟机备份？

A：虚拟机备份一旦开始原则上不允许停止，如果非要停止的话则需要在后台通过“ps -ef | grep 虚拟机磁盘文件名”查看进程号，然后kill掉该进程后前台就会收到备份失败的响应。

重要说明：查看虚拟机磁盘文件一直在增加状态才能kill，其他状态不允许kill。
