---
title: Linux Network
---
如果使用 ifupdown 来管理网络接口，需要手动编写 /etc/network/interfaces 文件，并使用 ifup 和 ifdown 命令来启用或禁用网络接口。而如果使用 NetworkManager 或 systemd-networkd 等工具，

- [Guide to the Linux Tutorials-TCP/IP networking reference guide (Linux 教程指南-TCP/IP 网络参考指南章节)](http://www.penguintutor.com/linux/basic-network-reference)  
  这篇关于网络的文章写的很简洁易懂。
- http://www.tcpipguide.com/
  
二层mac 三层路由 内核转发

https://lartc.org/


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