---
title: growpart 磁盘在线扩容
---

- [cloud-utils-growpart扩容华为云文档](https://support.huaweicloud.com/ims_faq/ims_faq_0027.html)
- 腾讯云：https://cloud.tencent.com/developer/article/1653394

可以通过growpart工具修改硬盘的分区表，将这部分空间直接append到最后一个分区

所以如果你要扩容的分区在你的系统上并非是磁盘上的最后一个分区的话，可能无法直接无损扩充分区


```bash
[root@pigeon-10-0-3-18 ~]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    253:0    0  60G  0 disk 
└─vda1 253:1    0  40G  0 part /

[root@pigeon-10-0-3-18 ~]# yum install cloud-utils-growpart
growpart /dev/vda 1 -N
growpart /dev/vda 1 
resize2fs /dev/vda1
df -Th

[root@pigeon-10-0-3-18 ~]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    253:0    0  60G  0 disk 
└─vda1 253:1    0  60G  0 part /
```

