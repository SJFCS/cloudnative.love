---
title: Storage
sidebar_position: 0
tags: [Storage]
---
# 分布式数据存储

1. rook: 在 kubernetes 上部署 ceph/edgefs 等分布式文件系统。
2. minio: 兼容S3存储协议，使用维护都很简单，社区也很活跃。
3. Ceph/GlusterFS/OSS。



磁盘阵列
分布式文件系统
文件传输协议
ISCSI/SAN/NAS

多硬盘方案综述：RAID、mergefs、分布式存储介绍
分布式文件存储技术概述：Ceph, GlusterFS, HDFS, MinIO
网络文件传输协议：NFS、SMB、iSCI
存储设备联网解决方案：SAN, NAS, iSCSI





## Distributed File System

但是规模再增大，我们会发现一台主机的存储空间仍然不够，性能可能也无法满足要求。
另外我们发现主机或磁盘阵列卡本身，也存在单点问题。

为了解决这个问题，就需要将数据存储到多台主机，多个磁盘阵列中。使用网络连接这些主机，得到的文件系统被称作「分布式文件存储系统」。

代表性的开源技术：

1. Ceph: 分布式、高可扩展的存储系统，可以提供对象存储、块存储和文件存储等服务。
2. GlusterFS: 在许多基准测试中的性能表现不如 Ceph 优秀，并且在存储集群节点数量较大的情况下易受到性能下降和负载均衡问题的影响。
3. HDFS: 专为大文件存储设计的分布式文件系统，主要被应用在大数据领域。
4. MinIO: 目前最流行的云原生对象存储方案，提供 S3 兼容的 RESTful API。

## 文件传输协议

有了上述文件系统后，远程的应用如果想要方便地使用这些存储资源，就需要用到文件传输协议。

日常接触得最多的，肯定是 HTTP/FTP 协议。但是 HTTP 只是能提供单纯的文件传输功能，FTP 也只提供有限的文件查询功能。

我们希望的，是像使用本地的存储空间一样地去使用远程存储资源。这种技术叫网络文件系统。


## ISCSI/SAN/NAS
- **iSCSI：**Internet 小型计算机系统接口 (iSCSI：Internet Small Computer System Interface) Internet 小型计算机系统接口(iSCSI)是一种基于 TCP/IP 的协议,用来建立和管理 IP 存储设备、主机和客户机等之间的相互连接,并创建存储区域网络(SAN)，属于块存储。
- **SAN：**Storage Area Network 存储区域网络,多采用**高速光纤通道**,对速率、冗余性要求高.使用 iscsi 存储协议块级传输。
- **NAS：**Network Attachment Storage 网络附件存储,采用**普通以太网**,对速率、冗余无特别要求,使用 NFS、CIFS 共享协议文件级传输。

使用的最多的网络文件协议有：
1. NFS：NFS (Network File System) 是一种分布式文件系统，用于在网络环境中共享文件和目录，属于文件存储。
1. SMB：Windows 世界使用广泛，各种 Windows 共享文件夹，都是使用的这个协议。
    - linux发行版/macos/windows 的文件管理器，都支持直接访问 `smb://` 存储。
2. ISCSI: iscsi 比 NFS/SMB 更底层，它直接将裸磁盘提供给客户端。
    - 简单解释：NFS/SMB 是共享文件夹，而底层的文件系统由服务端管控，对客户端是透明的。
      而 iscsi 是直接共享存储块(底层是物理磁盘)，客户端直接读写底层裸磁盘，因此文件系统(NTFS/EXT4 等)完全由客户端控制。


### 参考文档

- [块存储、文件存储、对象存储这三者的本质差别是什么？ - 知乎](https://www.zhihu.com/question/21536660)
- [raid5 磁盘阵列真的不安全么？ - 知乎](https://www.zhihu.com/question/20164654/answer/348274179)

