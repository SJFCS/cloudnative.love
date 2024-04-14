---
title: Storage
sidebar_position: 0
tags: [Storage]
---
随着规模的增大，单节点主机的存储空间仍不再满足要求，主机或磁盘阵列卡本身，也存在单点问题。

为了解决这些问题，就需要将数据存储到多台主机，多个磁盘阵列中。使用网络连接这些主机，得到的文件系统被称作「分布式文件存储系统」。

代表性的开源技术：

1. Ceph: 分布式、高可扩展的存储系统，可以提供对象存储、块存储和文件存储等服务。
2. GlusterFS: 在许多基准测试中的性能表现不如 Ceph 优秀，并且在存储集群节点数量较大的情况下易受到性能下降和负载均衡问题的影响。
3. HDFS: 专为大文件存储设计的分布式文件系统，主要被应用在大数据领域。
4. MinIO: 目前最流行的云原生对象存储方案，提供 S3 兼容的 RESTful API。

## ISCSI/SAN/NAS

- **iSCSI：** Internet 小型计算机系统接口 (iSCSI：Internet Small Computer System Interface) Internet 小型计算机系统接口(iSCSI)是一种基于 TCP/IP 的协议,用来建立和管理 IP 存储设备、主机和客户机等之间的相互连接,并创建存储区域网络(SAN)，属于块存储。
- **SAN：** Storage Area Network 存储区域网络,多采用**高速光纤通道**,对速率、冗余性要求高.使用 iscsi 存储协议块级传输。
- **NAS：** Network Attachment Storage 网络附件存储,采用**普通以太网**,对速率、冗余无特别要求,使用 NFS、CIFS 共享协议文件级传输。

使用的最多的网络文件协议有：

1. NFS：NFS (Network File System) 是一种分布式文件系统，用于在网络环境中共享文件和目录，属于文件存储。
1. SMB：Windows 世界使用广泛，各种 Windows 共享文件夹，都是使用的这个协议。
    - linux发行版/macos/windows 的文件管理器，都支持直接访问 `smb://` 存储。
2. ISCSI: iscsi 比 NFS/SMB 更底层，它直接将裸磁盘提供给客户端。
    - 简单解释：NFS/SMB 是共享文件夹，而底层的文件系统由服务端管控，对客户端是透明的。
      而 iscsi 是直接共享存储块(底层是物理磁盘)，客户端直接读写底层裸磁盘，因此文件系统(NTFS/EXT4 等)完全由客户端控制。


### 扩展阅读

- [块存储、文件存储、对象存储这三者的本质差别是什么？ - 知乎](https://www.zhihu.com/question/21536660)
- [raid5 磁盘阵列真的不安全么？ - 知乎](https://www.zhihu.com/question/20164654/answer/348274179)

