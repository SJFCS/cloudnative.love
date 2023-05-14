---
title: LVM 磁盘空间扩容
---



### 查看分区情况



```sh
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

可以看到磁盘已经扩展到53.7GB，但是还不能使用。

### 开始分区

```sh
[root@localhost ~]# fdisk -l /dev/sda

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
[root@localhost ~]# fdisk /dev/sda2
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x213fc3e8.

Command (m for help): q

[root@localhost ~]# fdisk /dev/sda
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): m   # 备注：查看帮助信息
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

Command (m for help): p  # 备注：查看当前分区表

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM

Command (m for help): n  # 备注：新建分区表
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p  # 备注：选择主分区
Partition number (3,4, default 3):    # 备注：保持默认
First sector (41943040-104857599, default 41943040):   # 备注：提示修改大小，保持默认
Using default value 41943040
Last sector, +sectors or +size{K,M,G} (41943040-104857599, default 104857599): # 备注：提示修改大小，保持默认
Using default value 104857599
Partition 3 of type Linux and of size 30 GiB is set

Command (m for help): t  # 备注：修改分区id
Partition number (1-3, default 3): 3  # 备注： 选择分3
Hex code (type L to list all codes): L   # 查看所有可用的分区编码，我们使用8e

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
Hex code (type L to list all codes): 8e  # 备注：输入分区编码8e
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): w   # 备注：保存
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
[root@localhost ~]#
```

再次查看分区情况：

```sh
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
/dev/sda3        41943040   104857599    31457280   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   17G  1.6G   16G  10% /
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.5M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               1014M  145M  870M  15% /boot
tmpfs                    184M     0  184M   0% /run/user/0
```

为了不重启虚拟机，使用`partprobe`命令使配置生效：

```sh
[root@localhost ~]# partprobe
[root@localhost ~]# fdisk -l

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0c42

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
/dev/sda3        41943040   104857599    31457280   8e  Linux LVM

Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

可以看到新的分区`/dev/sda3`已经标记为Linux LVM，如果没有需要`reboot`或者`partprobe`。


## 调整LVM大小

### 查看当前LVM信息

```sh
[root@localhost ~]# vgdisplay
  --- Volume group ---
  VG Name               centos   # 备注：注意关注此行
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <19.00 GiB
  PE Size               4.00 MiB
  Total PE              4863
  Alloc PE / Size       4863 / <19.00 GiB
  Free  PE / Size       0 / 0   
  VG UUID               IaHi9d-Q4Ia-WBrL-WFqd-sv9S-a5o3-SjHNkc
```

`centos`是我的`VolumeGroup`的名称，实际操作时，需要使用实际显示的名称。

### 创建物理卷并进行扩展LVM

把新分区的空间创建一个新的物理卷：

```sh
# 创建物理卷
[root@localhost ~]# pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created.

# 扩展LVM的VolumeGroup
[root@localhost ~]# vgextend centos /dev/sda3
  Volume group "centos" successfully extended
  
# 扩展LVM的逻辑卷
[root@localhost ~]# lvextend /dev/mapper/centos-root /dev/sda3
  Size of logical volume centos/root changed from <17.00 GiB (4351 extents) to 46.99 GiB (12030 extents).
  Logical volume centos/root successfully resized.

# 调整逻辑卷大小
[root@localhost ~]# resize2fs /dev/mapper/centos-root
resize2fs 1.42.9 (28-Dec-2013)
resize2fs: Bad magic number in super-block while trying to open /dev/mapper/centos-root
Couldn't find valid filesystem superblock.
```



可以发现调整逻辑卷大小失败：

```sh
[root@localhost ~]# resize2fs /dev/mapper/centos-root
resize2fs 1.42.9 (28-Dec-2013)
resize2fs: Bad magic number in super-block while trying to open /dev/mapper/centos-root
Couldn't find valid filesystem superblock.

# 查看文件格式，发现/dev/mapper/centos-root是xfs格式的
[root@localhost ~]# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        17G  1.6G   16G   10% /
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     920M     0  920M   0% /dev/shm
tmpfs                   tmpfs     920M  8.5M  911M   1% /run
tmpfs                   tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  145M  870M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0

# xfs格式的文件扩充需要使用 xfs_growfs
[root@localhost ~]# xfs_growfs /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=1113856 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=4455424, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 4455424 to 12318720

# 查看修改后的效果
[root@localhost ~]# df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        47G  1.6G   46G   4% /
devtmpfs                devtmpfs  908M     0  908M   0% /dev
tmpfs                   tmpfs     920M     0  920M   0% /dev/shm
tmpfs                   tmpfs     920M  8.5M  911M   1% /run
tmpfs                   tmpfs     920M     0  920M   0% /sys/fs/cgroup
/dev/sda1               xfs      1014M  145M  870M  15% /boot
tmpfs                   tmpfs     184M     0  184M   0% /run/user/0
```

可以看到虚拟机的磁盘大小已经调整成功。

