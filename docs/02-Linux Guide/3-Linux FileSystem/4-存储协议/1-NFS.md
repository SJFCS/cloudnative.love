---
title: NFS存储服务
---
[NFS配置项no_root_squash和root_squash的区别](https://blog.csdn.net/angaoux03775/article/details/101710753)

https://www.cnblogs.com/f-ck-need-u/p/7305755.html


本文将介绍NFS服务搭建和使用。

NFS存在单点问题，因为它通常在单个服务器上运行，如果该服务器发生故障或成为瓶颈，则可能会导致整个系统受到影响。为了解决这个问题，可以采取一些措施，例如使用NFS集群或使用其他类似的分布式文件系统，以确保高可用性和可靠性。


常用的NFS集群方案包括以下几种：

NFS高可用(NFS+keepalive+Sersync) 

DRBD + Pacemaker + NFS：DRBD是一种基于块设备的数据复制技术，可以将数据实时复制到另一个节点上。Pacemaker是一个开源的集群管理器，可以用来管理DRBD和NFS的资源，并实现自动故障转移。NFS则作为应用程序访问数据的接口，由Pacemaker自动管理资源的切换和负载均衡。这种方案具有可靠性高、易于管理和扩展性强等优点。

GlusterFS + NFS：GlusterFS是一个分布式文件系统，可以将多个存储节点组成一个统一的文件系统。NFS可以作为GlusterFS的接口之一，为应用程序提供文件访问服务。这种方案具有可扩展性强、性能高、数据可靠性好等优点。

CephFS + NFS：Ceph是一个分布式存储系统，可以将多个存储节点组成一个统一的存储池。CephFS是Ceph的文件系统接口之一，可以为应用程序提供文件访问服务。NFS可以作为CephFS的接口之一，为应用程序提供文件访问服务。这种方案具有可靠性高、数据可靠性好、可扩展性强等优点。

需要注意的是，不同的NFS集群方案适用于不同的应用场景和需求，并且具体实现也会受到多种因素的影响，例如硬件配置、网络带宽、数据访问模式等。因此，在选择和实施NFS集群方案时，需要充分了解自己的需求和条件，并进行充分的测试和验证。



## 前言

![image-20210815165917937](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/NFS/2021.08.18-09:18:55-image-20210815165917937.png)

![image-20210815170202508](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/NFS/2021.08.18-09:19:02-image-20210815170202508.png)

## 安装nfs和rpcbind

```bash
客户端服务端：yum install nfs-utils rpcbind
#rpcbind 服务对于NFS 是必须的，是NFS的动态端口守护进程
#所以不启动rcpbind,NFS不启动
服务端：apt-get install nfs-kernel-server
客户端：apt-get install -y nfs-common
```

### **启动服务**

```bash
systemctl start rpcbind
systemctl enable rpcbind

systemctl start nfs
systemctl enable nfs
```

### **查看服务状态**

测试服务端的nfs服务是否可用。

```text
rpcinfo -p localhost
rpcinfo -p [IP]
```

显示如下即正常

```text
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  41511  nlockmgr
    100021    3   udp  41511  nlockmgr
    100021    4   udp  41511  nlockmgr
    100021    1   tcp  35851  nlockmgr
    100021    3   tcp  35851  nlockmgr
    100021    4   tcp  35851  nlockmgr
```

可以看到如上有3个主要进程

- **portmap**：主要功能是进行端口映射工作。当客户端尝试连接并使用RPC服务器提供的服务（如NFS服务）时，portmap会将所管理的与服务对应的端口提供给客户端，从而使客户可以通过该端口向服务器请求服务。**该进程就是rpc服务的进程，该服务使用111端口来件套nfs客户端提交的请求，并将正确的nfs端口信息回复给请求的nfs客户端。** 
- **mountd**：它是RPC安装守护进程，主要功能是管理NFS的文件系统。当客户端顺利通过nfsd登录NFS服务器后，在使用NFS服务所提供的文件前，还必须通过文件使用权限的验证。**它会读取NFS的配置文件/etc/exports来对比客户端权限**。
- **nfsd**：它是基本的NFS守护进程，主要功能是管理客户端是否能够登录服务器；**nfs服务的端口默认是2049，客户端使用mount命令挂载报time out时，可能原因就是该进程的端口未暴露**

## NFS服务端配置

### NFS配置参数详解

 在NFS服务器端的主要配置文件为`/etc/exports`，**通过此配置文件可以设置服务端的共享文件目录**。每条配置记录**由NFS共享目录、NFS客户端地址和参数**这3部分组成，可通过`man exports` 搜索`EXAMPLE` 查看配置案例，格式如下

```
[NFS共享目录] [客户端地址1(参数1,参数2,参数3……)] [客户端地址2(参数1,参数2,参数3……)]
```

- NFS共享目录：nfs服务端上共享出去的文件目录；
- NFS客户端地址：允许其访问的NFS服务端的客户端地址，可以是客户端主机名、IP地址、网段(192.168.64.0/24)，或者是*表示所有客户端IP都可以访问；
- 访问参数：括号中逗号分隔项，主要是一些权限选项。

**配置参数**

执行`man exports` 命令，切换到文件结尾，可快速查看如下样例格式：

| 参数 | 描述 |
| ---- | ---- |
|rw                |    读写权限 |
|ro                |    只读权限 |
|sync              | 同步写入内存与硬盘中，保证数据落盘。 |
|async             | 数据暂存内存中，再写入硬盘，效率高，断电可能导致未落盘数据丢失。 |
|root_squash            | 登入NFS主机的用户如果是root，则将请求映射成nfsnobody用户的权限。（默认） |
| no_root_squash | 登入到NFS主机的用户如果是root，具有root权限                  |
| all_squash     | 不管登陆NFS主机的用户UID和GID都会被映射匿名用户nfsnobody。(包括root。all_squash与no_root_squash同时使用时只有all_squash参数生效) |
|no_all_squash         | 登陆NFS主机的用户保留共享文件的UID和GID（默认，不包括root）  |
| anonuid=xxx    | 配置all_squash使用，将登入NFS主机的用户都设定成指定的user id，此ID必须存在于/etc/passwd中。 |
| anongid=xxx    | 配置all_squash使用，指定NFS服务器/etc/passwd文件中匿名用户的GID |


### 配置共享目录

客户端发送请求——>服务端验证——>使用指定的GID UID写入共享目录。所以要确保共享目录有相应的读写权限

1. 所有用户均保留UID GID

   ```bash
   mkdir  /nfs-share-source
   chmod a+rw  /nfs-share-source
   echo "/nfs-share-source *(rw,async,no_root_squash)" >> /etc/exports
   ```

2. 所有用户均映射为nfsnobody

   ```bash
   mkdir  /nfs-share-anonymous
   chown -R nfsnobody.nfsnobody /nfs-share/
   echo "/nfs-share-anonymous *(rw,async,all_squash)" >> /etc/exports
   ```

3. 所有用户映射为指定用户

   ```bash
   groupadd -g 666 nfsspecified
   useradd  -u 666 -g 666 nfsspecified
   mkdir  /nfs-share-specified
   chown -R nfsspecified.nfsspecified /nfs-share-specified
   
   [root@node1 ~]# grep 666 /etc/passwd
   nfsspecified: x:666:666::/home/nfsspecified:/bin/bash
   [root@node1 ~]# id nfsspecified
   uid=666(nfsspecified) gid=666(nfsspecified) groups=666(nfsspecified)
   
   echo "/nfs-share-specified *(rw,async,all_squash,anonuid=666,anongid=666)" >> /etc/exports
   ```
   

要保证共享目录已经存在服务端上，然后输入以下命令使配置生效。

```text
exportfs -r
```

### 查看配置是否成功

```
[root@node1 ~]# cat /var/lib/nfs/etab
/nfs-share      10.50.1.101(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_lockso_root_squash,no_all_squash)

/nfs-share-anonymous    *(rw,async,wdelay,hide,nocrossmnt,secure,root_squash,all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,rw,secure,root_squash,all_squash)
/nfs-share-source       *(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,rw,secure,no_root_squash,no_all_squash)

```

此处anonuid=65534,anongid=65534是安装nfs是自动创建的用于映射的匿名用户nfsnobody

```
[root@node1 ~]# grep 65534 /etc/passwd
nfsnobody: x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin
[root@node1 ~]# id  nfsnobody
uid=65534(nfsnobody) gid=65534(nfsnobody) groups=65534(nfsnobody)
```

## NFS客户端配置

### 查询NFS服务端共享目录信息

**showmount命令查询“mountd”守护进程，以显示NFS服务器加载的信息。**

> -d:仅显示已被NFS客户端加载的目录 -e:显示NFS服务器上所有的共享目录

```text
showmount -e localhost
showmount -e [IP]
```

### mount挂载参数详解

![image-20210815165759134](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/NFS/2021.08.18-09:19:10-image-20210815165759134.png)

**-t ntfs**
 告诉挂载命令将要挂载的文件系统类型。这个选项并不是必须的，因为mount会自动识别大多数的文件系统。
 **-r** 或 **-o ro**
 以只读形式挂载卷。挂载操作默认以可读写形式挂载卷。除非指明，否则驱动将会以只读形式自动挂载文件系统。
 **-o umask={VALUE}**
 因为安全的原因，默认给予已挂载的NTFS卷的权限为rwx------。参数umask控制这些文件和路径的权限。详细的资料和例子请参见[4.9节](https://flatcap.org/linux-ntfs/info/ntfs-zh.html#4.9)。

```
mount /dev/hda1 /mnt/windows -t ntfs -r -o umask=0222
```

**-o uid={USERID}**
 已挂载的NTFS卷上所有文件默认都是root所有的。如果提供uid参数就可以设置文件的所有者。这些参数可以是/etc/passwd中的任何用户名，或者任何表示用户id的数字

```
mount /dev/hda1 /mnt/windows -t ntfs -r -o uid=flatcap
mount /dev/hda1 /mnt/windows -t ntfs -r -o uid=500
```

**-o gid={GROUPID}**
 已挂载的NTFS卷上所有的文件默认都是root组所有的。如果提供gid参数就可以设置文件的组。这些参数可以是/etc/group中的组名，或者任何表示组id的数字。

```
mount /dev/hda1 /mnt/windows -t ntfs -r -o gid=winusers
mount /dev/hda1 /mnt/windows -t ntfs -r -o gid=520
```

### 挂载目录

**客户端将挂载点挂载到服务端的共享目录**

```
mount -t nfs  10.50.1.101:/nfs-share /opt/k8s/
```

![image-20210815165752163](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/NFS/2021.08.18-09:19:06-image-20210815165752163.png)

**添加开机自动挂载**

**/etc/fstab**文件记录了系统启动时挂载点文件系统的配置。 在该文件的末尾新增一行配置一个挂载点，配置如下。

```text
139.96.6.20:/k8s      /home/k8s       nfs     default 0       0
```

> 第一列是需要挂载的文件系统或者是存储设备或者是需要挂载的目录。
> 第二列是挂载点，挂载点就是客户端挂载的目录。
> 第三列是文件系统或者是分区的类型（其实分区类型就是中文件系统）
> 第四列是以何种形式挂载，比如rw读写, auto自动挂载,ro只读等等参数。不过最常用的是defaults。defaults是rw，suid，dev，exec，auto，nouser，async等的组合。
> 第五列为dump选项，设置是否让备份程序dump备份文件系统，0为忽略，1为备份。
> 第六列为fsck选项，告诉fsck程序以什么顺序检查文件系统，0为忽略。

为了避免fstab文件配置错误，导致系统无法正常启动。 在修改过fstab文件后，都要使用命令`mount -a`进行挂载测试，没有报错信息说明fstab文件没有问题。否则根据报错解决问题。

**此时我们在客户端目录下新增或删除内容后，服务端的目录下也会立即发生相应的内容的改变。 反之亦然。说明服务端的共享目录和客户端的挂载点是双向共享的。**

## 问题

一般showmount -e localhost命令都是好使的，在使用showmount -e 公网ip时会显示如下问题

```shell
showmount -e 139.96.6.20
clnt_create: RPC: Port mapper failure - Timed out
```

解决：  很明显报的是**portmapper进程连接超时，很大可能是端口111没有放行。**我们使用telnet命令测试显示,111端口确实没有放开。

```css
[root@s1 ~]# telnet 139.96.6.20 111
Trying 139.96.6.20...
```

所有我们需要在安全组中放行**TCP类型的端口111**，放行之后再次测试发现还是连接超时。。  接着我们继续放行**mountd进程的TCP端口20048，**，放行之后再次测试发现仍然是连接超时。。。。  经过一番排查，细心的朋友会发现**portmapper进程有TCP的111端口，也有UDP的111端口，mountd进程有TCP的20048端口，也有UDP的20048端口（rpcinfo -p 命令）。**  接着放行UDP的111端口和UDP的20048端口后果然显示成功了

```cpp
[root@s1 ~]# showmount -e 139.96.6.20
Export list for 139.96.6.20:
/k8s *
```

参考链接：

https://zhuanlan.zhihu.com/p/302774003

https://flatcap.org/linux-ntfs/info/ntfs-zh.html

