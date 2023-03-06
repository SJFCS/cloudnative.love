---
title: Linux
sidebar_position: 2
tags: [Linux]
---
这不是给初学者看的，目前还在完善，预计4月前完成


```
Linux性能调优 linux Performance Tuning  红帽 RH442
  - https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/performance_tuning_guide/index
  -  https://docs.oracle.com/cd/E19159-01/819-3681/abeji/index.html
  -  https://www.yugabyte.com/blog/linux-performance-tuning-memory-disk-io/
  -  https://github.com/oussamahammami/Linux-Tuning-SIP-Servers
  -  https://lenovopress.lenovo.com/redp4285
  -  硬件参数获取分析、系统资源使用实时分析、追踪统计、系统调用追踪分析、内存过量分配合理调配、共享内存指定配置、二进制C程序直接分析系统概要、虚拟内存占用统计、程序内存缓存命令率分析、网络tcp/udp buffer分析，系统核心资源定期采集分析，网络延迟调优、systemd服务资源使用限制，cgroup资源限制、磁盘脏页回收、Linux内核模板动态装卸载、tuned资源组调优、numa 架构调优、TLB缓存调优、内核优化、Linux多种文件系统性能优缺点对比等。


- ipvs,iptables  基本了解 
- https://icloudnative.io/posts/ipvs-how-kubernetes-services-direct-traffic-to-pods/
- https://dudashuang.com/load-blance/
- https://www.youtube.com/watch?v=lkXLsD6-4jA
- https://jishuin.proginn.com/p/763bfbd5f406
- https://blog.51cto.com/search/user?uid=11441275&q=lvs
- https://www.zsythink.net/archives/2134
- https://www.qikqiak.com/post/how-to-use-ipvs-in-kubernetes/
- https://space.bilibili.com/500659532
- https://www.cnblogs.com/luozhiyun/p/13782077.html
  linux 内核调优，熟悉内核堆栈报报告,能分析coredump
  存储各种方案和linux集成,以及i稳定性和debug
  网络,云网融合解决方案,sdn,cni,neutron等,个种网络协议原理和排错，ISP网络+overlay，SDN，网络基础,tcp/ip协议栈,vlan,vxlan,熟悉tcpdump,wireshark,分析网络问题,reg
  熟悉进程,文件系统,网络常见系统调用,strace/gdb等工具分析程序行为
  熟悉网络栈，内核网络参数工作原理,虚拟网络设备工作原理
  属虚linux存储和文件系统，能分析定位影响应用IO性能的因素
  熟悉namespace,cgroup,upstart,systemd等概念
  熟悉rpm,deb等发行包的制作
  openstack,kvm,SDN，linuxbridge,OVS,libvirt 镜像制作 cloud-init,
  EBPF
  基于linux实现vxlan和bgp
  网卡绑定

shell: 
- http://c.biancheng.net/view/vip_4555.html
- 慕课-Shell脚本 https://coding.imooc.com/learn/list/314.html
- https://effective-shell.com/
- https://github.com/alebcay/awesome-shell


- https://github.com/google/zx
- https://stackoverflow.com/questions/58338429/what-is-the-advantage-of-usr-bin-env-python-in-the-shebang-rather-than-just
- https://zh.wikipedia.org/zh-hans/Shebang
- https://www.baeldung.com/linux/bash-shebang-lines
- https://stackoverflow.com/questions/16365130/what-is-the-difference-between-usr-bin-env-bash-and-usr-bin-bash
- https://ubuntu.com/server/docs/security-firewall

```












https://github.com/snori74/linuxupskillchallenge

https://github.com/trimstray/the-practical-linux-hardening-guide
https://linuxtools-rst.readthedocs.io/zh_CN/latest/

https://www.linuxfromscratch.org/lfs/read.html
https://wiki.archlinux.org/
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/
https://tldp.org/

https://www.kernel.org/doc/man-pages/
https://man7.org/linux/man-pages/
http://man.he.net/
https://man.cx/
https://linux.die.net/man/

      了解 linux 核心子系统（内存管理 文件系统 网络 进程调度） 内核 crash dump 分析，ebpf入门,性能分析io排查

- Linux 系统日志：https://linux.vbird.org/linux_basic/centos7/0570syslog.php
- Linux 源码：[linux-insides](https://github.com/0xAX/linux-insides)
- [Linux 内核模块开发指南](https://sysprog21.github.io/lkmpg/)
- [第十六章、程序管理與 SELinux 初探 - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0440processcontrol.php)
- [第十九章、開機流程、模組管理與 Loader - 鸟哥的 Linux 私房菜](https://linux.vbird.org/linux_basic/centos7/0510osloader.php)

- GNU Core Utilities

  :::tip
  （GNU核心工具组 常缩写为coreutils）是一个GNU 软件包，它包含了许多基本工具（如cat，ls 和rm）在类Unix 操作系统上的重新实现。
  :::

  源码仓库：

  + [GNU coreutils](https://github.com/coreutils/coreutils)
  + [uutils/coreutils](https://github.com/uutils/coreutils) 使用 rust 重新实现的 GNU coreutils.
  + [redox-os/coreutils](https://github.com/redox-os/coreutils) redox os 的 coreutils，基于 BSD coreutils