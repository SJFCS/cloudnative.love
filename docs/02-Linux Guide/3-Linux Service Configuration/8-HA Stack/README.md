---
title: HA Stack
---

https://www.cnblogs.com/kevingrace/p/6249028.html
https://www.cnblogs.com/kevingrace/p/5740940.html

Pacemaker 是 Heartbeat 的继承者，基于资源的故障检测、动态资源迁移、复杂的资源依赖关系管理等。
Pacemaker最初是作为Heartbeat的升级版本而创建的。Heartbeat在2008年停止了开发，Pacemaker继续开发和维护，并成为了一个较好的替代方案。
Pacemaker比Heartbeat提供了更多的功能和更强的灵活性，并且可以与不同的资源代理一起使用，如OCF（Open Cluster Framework）和STONITH（Shoot The Other Node In The Head，一种用于强制关闭故障节点的技术）。因此，Pacemaker可以被看作是Heartbeat的一种升级版或者替代方案。

Corosync 是一个高可用性的通信库，为集群提供了一个可靠的通信层，可以与 Pacemaker 配合使用。

Keepalived 是一个基于 VRRP 协议的工具，用于实现虚拟 IP 地址的故障转移。



DRBD是一种数据复制技术，它可以在多个节点之间同步块设备（如硬盘、分区等）的数据，以提高数据的可用性和冗余性。DRBD可以与任何文件系统一起使用，并且对应用程序透明，因此应用程序不需要进行修改。DRBD通常用于构建具有高可用性和灾难恢复能力的数据存储系统。

OCFS2是一种分布式文件系统，它允许多个节点同时访问相同的文件系统，并提供了文件锁定和一致性保证等功能。OCFS2通常用于需要多节点访问相同文件系统的场景，如数据库集群等。


如果多个进程同时读写同一个块设备，可能会发生竞争条件和数据不一致的问题。这是因为块设备通常是以磁盘或闪存等物理媒介为基础的，而这些物理媒介通常不能同时被多个进程访问或修改。因此，操作系统通常会使用同步机制（如互斥锁）来保证只有一个进程能够对块设备进行读写操作，以避免数据的不一致性。

只用drbd设备的话，当两个节点同时网一个文件系统写数据会导致文件系统崩溃，而应以OCFS2集群文件系统，会提供一个文件锁管理器，防止文件系统崩溃。


[具有 DRBD 和 Pacemaker 的高可用 NFS 存储](https://documentation.suse.com/sle-ha/15-SP1/html/SLE-HA-all/art-sleha-nfs-quick.html)

[红帽高可用性群集中的主动/被动 NFS 服务器](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_administration/ch-nfsserver-haaa)


[将 LVM 与 DRBD 结合使用](https://docs.piraeus.daocloud.io/books/drbd-90-user-guide/page/9-using-lvm-with-drbd)

[drbd+ocfs2构建的共享存储方案](https://developer.aliyun.com/article/484016)

[使用 Pacemaker、DRBD、Corosync 和 MySQL 实现近 HA 的主动-被动集群](https://houseofbrick.com/blog/active-passive-cluster-for-near-ha-using-pacemaker-drbd-corosync-and-mysql/)