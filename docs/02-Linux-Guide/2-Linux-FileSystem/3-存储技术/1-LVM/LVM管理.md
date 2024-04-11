---
title: LVM的工作原理

---


使用LVM进行扩容

LVM（Logical Volume Manager）不是一个文件系统，它是一个分区和存储管理的工具。LVM可以将多个物理磁盘分区、逻辑卷和文件系统合并成一个大的存储池，从而增加灵活性和可用性，并提供高级的分区、快照和备份管理功能。LVM可以与不同的文件系统一起使用，如EXT2/3/4、XFS等。



## LVM的工作原理

    LVM（Logical Volume Manager）逻辑卷管理，是在硬盘分区和文件系统之间添加的一个逻辑层，为文件系统屏蔽下层硬盘分区布局，并提供一个抽象的盘卷，在盘卷上建立文件系统。管理员利用LVM可以在硬盘不用重新分区的情况下动态调整文件系统的大小，并且利用LVM管理的文件系统可以跨越物理硬盘。当服务器添加了新的硬盘后，管理员不必将原有的文件移动到新的硬盘上，而是通过LVM直接扩展文件系统来跨越物理硬盘。

    LVM就是通过将底层的物理硬盘封装，然后以逻辑卷的方式呈现给上层应用。当我们对底层的物理硬盘进行操作时，不再是针对分区进行操作，而是通过逻辑卷对底层硬盘进行管理操作。

## 基础术语

  + 物理存储介质（The physical media）：
    LVM存储介质，可以是硬盘分区、整个硬盘、raid阵列或SAN硬盘。设备必须初始化为LVM物理卷，才能与LVM结合使用。

+ 物理卷PV（physical volume）：
  物理卷就是LVM的基本存储逻辑块，但和基本的物理存储介质比较却包含与LVM相关的管理参数，创建物理卷可以用硬盘分区，也可以用硬盘本身。

+ 卷组VG（Volume Group）：
  LVM卷组类似于非LVM系统中的物理硬盘，一个卷组VG由一个或多个物理卷PV组成。可以在卷组VG上建立逻辑卷LV。

+ 逻辑卷LV（logical volume）：
  类似于非LVM系统中的硬盘分区，逻辑卷LV建立在卷组VG之上。在逻辑卷LV之上建立文件系统。

+ 物理块PE（physical Extent）：
  物理卷PV中可以分配的最小存储单元，PE的大小可以指定，默认为4MB
  
+ 逻辑块LE（Logical Extent）：逻辑卷LV中可以分配的最小存储单元，在同一卷组VG中LE的大小和PE是相同的，并且一一相对。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/LVM%E7%AE%A1%E7%90%86/2021.06.01-11:17:55-D-assets-LVM%E7%AE%A1%E7%90%86-949069-20200416104045527-1858978940.png)

> 总结：多个磁盘/分区/raid-->多个物理卷PV-->合成卷组VG-->从VG划分出逻辑卷LV-->格式化LV，挂载使用。
>
> 注意：老的Linux在创建PV时，需要将分区类型改为Linux LVM（8e）。但新的系统已经非常智能，即使默认的Linux分区（83），也可以创建PV。

## LVM的优点

+ 卷组VG可以使多个硬盘空间看起来像是一个大硬盘。

+ 逻辑卷LV可以创建跨多个硬盘空间的分区。

+ 在使用逻辑卷LV时，可以在空间不足时动态调整大小，不需要考虑逻辑卷LV在硬盘上的位置，不用担心没有可用的连续的空间。

+ 可以在线对卷组VG、逻辑卷LV进行创建、删除、调整大小等操作。但LVM上的文件系统也需要重新调整大小。

+ LVM允许创建快照，用来保存文件系统的备份。

> 注意：LVM是软件的卷管理方式，RAID是磁盘管理的方法。对于重要的数据使，用RAID保护物理硬盘不会因为故障而中断业务，再用LVM来实现对卷的良性管理，更好的利用硬盘资源。
>
> LVM有两种写入机制：线性（写完一个PV再写下一个PV，默认）、条带（平均）

## LVM常用的管理命令

| 功能         | PV管理命令 | VG管理命令 | LV管理命令 |
| ------------ | ---------- | ---------- | ---------- |
| scan 扫描    | pvscan     | vgscan     | lvscan     |
| create 创建  | pvcreate   | vgcreate   | lvcreate   |
| display 显示 | pvdisplay  | vgdisplay  | lvdisplay  |
| remove 移除  | pvremove   | vgremove   | lvremove   |
| extend 扩展  |            | vgextend   | lvextend   |
| reduce 减少  |            | vgreduce   | lvreduce   |

> 注意：查看命令有scan、display和s（pvs、vgs、lvs）。s是简单查看对应卷信息，display是详细查看对应卷信息。而scan是扫描所有的相关的对应卷。

## LVM实践

### 环境

 　添加一个20G硬盘sdb，创建四个2G的主分区

```bash
[root@xuexi ~]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sda3  /dev/sdb
[root@xuexi ~]# fdisk /dev/sdb
欢迎使用 fdisk (util-linux 2.23.2)。
 
更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。
 
# 第一个
命令(输入 m 获取帮助)：n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
分区号 (1-4，默认 1)：
起始 扇区 (2048-41943039，默认为 2048)：
将使用默认值 2048
Last 扇区, +扇区 or +size{K,M,G} (2048-41943039，默认为 41943039)：+2G
分区 1 已设置为 Linux 类型，大小设为 2 GiB

# 第二个
命令(输入 m 获取帮助)：n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
分区号 (2-4，默认 2)：
起始 扇区 (4196352-41943039，默认为 4196352)：
将使用默认值 4196352
Last 扇区, +扇区 or +size{K,M,G} (4196352-41943039，默认为 41943039)：+2G
分区 2 已设置为 Linux 类型，大小设为 2 GiB

# 第三个
命令(输入 m 获取帮助)：n
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
分区号 (3,4，默认 3)：
起始 扇区 (8390656-41943039，默认为 8390656)：
将使用默认值 8390656
Last 扇区, +扇区 or +size{K,M,G} (8390656-41943039，默认为 41943039)：+2G
分区 3 已设置为 Linux 类型，大小设为 2 GiB

# 第四个
命令(输入 m 获取帮助)：n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): p
已选择分区 4
起始 扇区 (12584960-41943039，默认为 12584960)：
将使用默认值 12584960
Last 扇区, +扇区 or +size{K,M,G} (12584960-41943039，默认为 41943039)：+2G
分区 4 已设置为 Linux 类型，大小设为 2 GiB

# 保存更改
命令(输入 m 获取帮助)：w
The partition table has been altered!
 
Calling ioctl() to re-read partition table.
正在同步磁盘。
[root@xuexi ~]# ls /dev/sd*
/dev/sda   /dev/sda2  /dev/sdb   /dev/sdb2  /dev/sdb4
/dev/sda1  /dev/sda3  /dev/sdb1  /dev/sdb3
```

### 创建物理卷PV

    将分区sdb1~4从Linux类型改为Linux LVM，当然较新的系统不改也没事。我这里就演示修改一个sdb1分区

```bash
[root@xuexi ~]# fdisk /dev/sdb
欢迎使用 fdisk (util-linux 2.23.2)。
 
更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。
 
 
命令(输入 m 获取帮助)：l    //查看所有分区类型代码
 
 0  空              24  NEC DOS         81  Minix / 旧 Linu bf  Solaris       
 1  FAT12           27  隐藏的 NTFS Win 82  Linux 交换 / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 隐藏的 C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux 扩展      c7  Syrinx        
 5  扩展            41  PPC PReP Boot   86  NTFS 卷集       da  非文件系统数据
 6  FAT16           42  SFS             87  NTFS 卷集       db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux 纯文本    de  Dell 工具     
 8  AIX             4e  QNX4.x 第2部分  8e  Linux LVM       df  BootIt        
 9  AIX 可启动      4f  QNX4.x 第3部分  93  Amoeba          e1  DOS 访问      
 a  OS/2 启动管理器 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O       
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor     
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad 休 eb  BeOS fs       
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT           
 f  W95 扩展 (LBA)  54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC 
11  隐藏的 FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor     
12  Compaq 诊断     5c  Priam Edisk     a9  NetBSD          f4  SpeedStor     
14  隐藏的 FAT16 <3 61  SpeedStor       ab  Darwin 启动     f2  DOS 次要      
16  隐藏的 FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS   
17  隐藏的 HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
18  AST 智能睡眠    65  Novell Netware  b8  BSDI swap       fd  Linux raid 自动
1b  隐藏的 W95 FAT3 70  DiskSecure 多启 bb  Boot Wizard 隐  fe  LANstep       
1c  隐藏的 W95 FAT3 75  PC/IX           be  Solaris 启动    ff  BBT           
1e  隐藏的 W95 FAT1 80  旧 Minix      
 
命令(输入 m 获取帮助)：p    //查看分区信息
 
磁盘 /dev/sdb：21.5 GB, 21474836480 字节，41943040 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x6dc89fe5
 
   设备 Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     4196351     2097152   83  Linux
/dev/sdb2         4196352     8390655     2097152   83  Linux
/dev/sdb3         8390656    12584959     2097152   83  Linux
/dev/sdb4        12584960    16779263     2097152   83  Linux
 
命令(输入 m 获取帮助)：t    //修改分区类型代码
分区号 (1-4，默认 4)：1
Hex 代码(输入 L 列出所有代码)：8e
已将分区“Linux”的类型更改为“Linux LVM”
 
命令(输入 m 获取帮助)：p
 
磁盘 /dev/sdb：21.5 GB, 21474836480 字节，41943040 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x6dc89fe5
 
   设备 Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     4196351     2097152   8e  Linux LVM
/dev/sdb2         4196352     8390655     2097152   83  Linux
/dev/sdb3         8390656    12584959     2097152   83  Linux
/dev/sdb4        12584960    16779263     2097152   83  Linux
 
命令(输入 m 获取帮助)：w
The partition table has been altered!
 
Calling ioctl() to re-read partition table.
正在同步磁盘。
```

    使用pvcreate创建物理卷PV

```bash
[root@xuexi ~]# pvcreate /dev/sdb{1,2,3,4}
WARNING: xfs signature detected on /dev/sdb1 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/sdb1.
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdb2" successfully created.
  Physical volume "/dev/sdb3" successfully created.
  Physical volume "/dev/sdb4" successfully created.
```

    创建完成后可以查看一下

```bash
[root@xuexi ~]# pvs
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb1     lvm2 ---  2.00g 2.00g
  /dev/sdb2     lvm2 ---  2.00g 2.00g
  /dev/sdb3     lvm2 ---  2.00g 2.00g
  /dev/sdb4     lvm2 ---  2.00g 2.00g
[root@xuexi ~]# pvdisplay /dev/sdb1
  "/dev/sdb1" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name              
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0  
  Total PE              0
  Free PE               0
  Allocated PE          0    //PE使用情况
  PV UUID               BKr1CG-91rH-0Dsq-vGol-UTO6-xP83-hV7FTZ
```

### 创建卷组VG

    使用vgcreate创建卷组VG，并且此处可以-s选项指定PE（LE）的大小，（默认PE大小4M）

```bash
[root@xuexi ~]# vgcreate vg1 /dev/sdb1
  Volume group "vg1" successfully created
[root@xuexi ~]# vgcreate -s 16M vg2 /dev/sdb2
  Volume group "vg2" successfully created
```

    创建完成后查看一下

```bash
[root@xuexi ~]# vgs
  VG  #PV #LV #SN Attr   VSize  VFree
  vg1   1   0   0 wz--n- <2.00g <2.00g
  vg2   1   0   0 wz--n-  1.98g  1.98g
[root@xuexi ~]# vgdisplay vg1
  --- Volume group ---
  VG Name               vg1
  System ID            
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB    //可以看到vg1的PE大小为4M
  Total PE              511
  Alloc PE / Size       0 / 0  
  Free  PE / Size       511 / <2.00 GiB
  VG UUID               N0HBAX-50lM-3tJ3-xIho-pLrx-7hAh-1T1T0g
[root@xuexi ~]# vgdisplay vg2
  --- Volume group ---
  VG Name               vg2
  System ID            
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1.98 GiB
  PE Size               16.00 MiB    //可以看到vg2的PE大小为16M
  Total PE              127
  Alloc PE / Size       0 / 0
  Free  PE / Size       127 / 1.98 GiB
  VG UUID               ajSIkx-BC9P-ufCn-f7Uc-FXtR-hPq5-tRGBei
```

>注意：PE大，读取速度快，但浪费空间。反之，读取速度慢，但节省空间。类似于socket

    另外还可以查看pv，会列出分配情况

```bash
[root@xuexi ~]# pvs
  PV         VG  Fmt  Attr PSize  PFree
  /dev/sdb1  vg1 lvm2 a--  <2.00g <2.00g
  /dev/sdb2  vg2 lvm2 a--   1.98g  1.98g
  /dev/sdb3      lvm2 ---   2.00g  2.00g
  /dev/sdb4      lvm2 ---   2.00g  2.00g
```

### 创建逻辑卷LV

    使用lvcreate创建LV。lvcreate -n lvname -L lvsize(M，G)|-l LEnumber vgname

```bash
[root@xuexi ~]# lvcreate -n lv1 -L 64M vg1
  Logical volume "lv1" created.
[root@xuexi ~]# lvcreate -n lv2 -l 16 vg1
  Logical volume "lv2" created.
```

查看 

```bash
[root@xuexi ~]# lvs    //因为vg1的PE大小是4M所以lv1与lv2的大小相等
  LV   VG  Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-a----- 64.00m
  lv2  vg1 -wi-a----- 64.00m
  
  [root@xuexi ~]# pvdisplay /dev/sdb1
  --- Physical volume ---
  PV Name               /dev/sdb1
  VG Name               vg1
  PV Size               2.00 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              511
  Free PE               479
  Allocated PE          32
  PV UUID               BKr1CG-91rH-0Dsq-vGol-UTO6-xP83-hV7FTZ
[root@xuexi ~]# vgdisplay vg1
  --- Volume group ---
  VG Name               vg1
  System ID            
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       32 / 128.00 MiB
  Free  PE / Size       479 / 1.87 GiB
  VG UUID               N0HBAX-50lM-3tJ3-xIho-pLrx-7hAh-1T1T0g
```

### 格式化与挂载

>     注意：在格式化之前需要知道xfs文件系统只支持增大，不支持减小。ext2、ext3、ext4增大减小都支持。

    所以这里我们先使用ext4的文件系统格式化

```bash
[root@xuexi ~]# mkfs.ext4 /dev/vg1/lv1    //将lv1格式化成ext4
mke2fs 1.42.9 (28-Dec-2013)
文件系统标签=
OS type: Linux
块大小=1024 (log=0)
分块大小=1024 (log=0)
Stride=0 blocks, Stripe width=0 blocks
16384 inodes, 65536 blocks
3276 blocks (5.00%) reserved for the super user
第一个数据块=1
Maximum filesystem blocks=33685504
8 block groups
8192 blocks per group, 8192 fragments per group
2048 inodes per group
Superblock backups stored on blocks:
    8193, 24577, 40961, 57345
 
Allocating group tables: 完成                           
正在写入inode表: 完成                           
Creating journal (4096 blocks): 完成
Writing superblocks and filesystem accounting information: 完成
[root@xuexi ~]# mkdir /lv1
[root@xuexi ~]# mount /dev/vg1/lv1 /lv1    //挂载到/lv1下
[root@xuexi ~]# echo "/dev/vg1/lv1 /lv1 ext4 defaults 0 0" >> /etc/fstab    //追加到开机挂载

```

    这里的/dev/vg1/lv1实际是一个软链接，实际地址如下

```bash
[root@xuexi ~]# ll /dev/vg1/lv1
lrwxrwxrwx. 1 root root 7 3月  31 15:48 /dev/vg1/lv1 -> ../dm-0
[root@xuexi ~]# ll /dev/dm-0
brw-rw----. 1 root disk 253, 0 3月  31 15:48 /dev/dm-0
```

### 逻辑卷LV扩容（动态扩容）

 　首先需要确认是否有可用的扩容空间，逻辑卷LV是从卷组VG中创建的，所有在逻辑卷LV扩容前需要查看卷组VG的空间使用情况。

```bash
[root@xuexi ~]# vgs
  VG  #PV #LV #SN Attr   VSize  VFree
  vg1   1   2   0 wz--n- <2.00g 1.87g
  vg2   1   0   0 wz--n-  1.98g 1.98g
```

    在确认有多余空间的情况下，使用lvextend命令的-L选项扩展逻辑卷LV的大小

```bash
[root@xuexi ~]# lvs
  LV   VG  Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-ao---- 64.00m                                                   
  lv2  vg1 -wi-a----- 64.00m
[root@xuexi ~]# lvextend -L +100M /dev/vg1/lv1    // +100M是增加100M
  Size of logical volume vg1/lv1 changed from 64.00 MiB (16 extents) to 164.00 MiB (41 extents).
  Logical volume vg1/lv1 successfully resized.
[root@xuexi ~]# lvextend -L 100M /dev/vg1/lv2    //直接使用100M是增加到100M
  Size of logical volume vg1/lv2 changed from 64.00 MiB (16 extents) to 100.00 MiB (25 extents).
  Logical volume vg1/lv2 successfully resized.
[root@xuexi ~]# lvs
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-ao---- 164.00m                                                   
  lv2  vg1 -wi-a----- 100.00m
```

    但是在我们使用df命令查看时，会发现我们文件系统并没有扩展

```bash
[root@xuexi ~]# df -h /lv1
文件系统             容量  已用  可用 已用% 挂载点
/dev/mapper/vg1-lv1   58M  1.3M   53M    3% /lv1
```

    这是因为文件系统也需要扩容。ext4文件系统扩容使用"resize2fs [逻辑卷名称]"，xfs文件系统扩容使用"xfs_growfs 挂载点"

```bash
[root@xuexi ~]# lvs    //LV已经扩容成功
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-ao---- 164.00m                                                   
  lv2  vg1 -wi-a----- 100.00m
[root@xuexi ~]# resize2fs /dev/vg1/lv1    //ext4文件系统扩容
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/vg1/lv1 is mounted on /lv1; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/vg1/lv1 is now 167936 blocks long.
[root@xuexi ~]# df -h /lv1
文件系统             容量  已用  可用 已用% 挂载点
/dev/mapper/vg1-lv1  155M  1.6M  145M    2% /lv1
```

    当然来到CentOS7后，我们还可以使用lvextend命令的-r选项来使文件系统自动扩容，实例如下：

```bash
[root@xuexi ~]# lvs
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-ao---- 164.00m                                                   
  lv2  vg1 -wi-a----- 100.00m
[root@xuexi ~]# lvextend -L 200M -r /dev/vg1/lv1    //LV扩容到200M并且文件系统自动扩容
  Size of logical volume vg1/lv1 changed from 164.00 MiB (41 extents) to 200.00 MiB (50 extents).
  Logical volume vg1/lv1 successfully resized.    //可以看到文件系统扩容成功
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/mapper/vg1-lv1 is mounted on /lv1; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 2
The filesystem on /dev/mapper/vg1-lv1 is now 204800 blocks long.
[root@xuexi ~]# lvs
  LV   VG  Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv1  vg1 -wi-ao---- 200.00m                                                   
  lv2  vg1 -wi-a----- 100.00m
[root@xuexi ~]# df -h /lv1
文件系统             容量  已用  可用 已用% 挂载点
/dev/mapper/vg1-lv1  190M  1.6M  179M    1% /lv1
```

参考链接：https://www.cnblogs.com/diantong/p/10554831.html
