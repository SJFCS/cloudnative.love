---
title: K8S排错-Linux索引节点(Inode)用满导致空间不足

---

---------

## 问题现象

k8s容器调度失败，容器处于创建中，发现提示`no space left on device`，服务器/var/log分区被占满



## 问题分析

通过du查看/var/log下的日志，发现是有一个gnocchi_wsgi_error.log占用了大量的空间。
查看gnocchi_wsgi_error.log日志，提示/var/lib/gnocchi/tmp下没有空间了。

这个gnocchi是给ceilometer容器用的，这个容器所使用的共享存储是gnocchi存储卷。

df -h查看，发现该存储卷还有空间；但是df -i查看发现inode被占满。
因此可以确认，问题是由于gnocchi存储卷的inode被占满，导致ceilometer容器一直打印错误日志，最终导致/var/log被占满。

## 解决

这个问题属于一个配置优化问题。需要及时更改gnocchi的inode配置，需要重新格式化存储，增加inode的数目。操作方法如下：

```
kubectl scale rc ceilometerrc --replicas=0
mkfs.ext4 -N 200000000 /dev/mapper/openstack-gnocchi
kubectl scale rc ceilometerrc --replicas=1 
```

参数解释

```
mkfs.ext4

[-I inode-size] 
    指定inode size大小，默认配置文件在/etc/mke2fs.conf，inode_size = 256
    Inode size:              256
[-N number-of-inodes]
    指定inode个数，最大创建文件个数
[-i bytes-per-inode]
    指定"字节/inode"的比例   
    增大-i参数，从而减小inode总数，可以减小inode占用的磁盘空间，减少磁盘浪费。


```

---

## 总结

Inode译成中文就是索引节点，每个存储设备（例如硬盘）或存储设备的分区被格式化为文件系统后，应该有两部份，一部份是inode，另一部份是 Block，Block是用来存储数据用的。而inode呢，就是用来存储这些数据的信息，这些信息包括文件大小、属主、归属的用户组、读写权限等。 inode为每个文件进行信息索引，所以就有了inode的数值。操作系统根据指令，能通过inode值最快的找到相对应的文件。
而这台服务器的Block虽然还有剩余，但inode已经用满，因此在创建新目录或文件时，系统提示磁盘空间不足。
Inode的数量是有限制的，每个文件对应一个Inode，`df -i`可以看到Inode的总量，已经使用的Inode数量，和剩余数量。

**其他方法：**

1）查找目录文件数目：

```
[root@abc sbin]# for i in /*; do echo $i; find $i | wc -l; done

```

2）删除文件占用多的目录：

进入目录直接rm -rf 可能会卡死，可以使用下面方式：

```
find dir -type f -name '*'  | xargs rm

# or

cd dir
ls | xargs rm -f
```

系统中有用户开启了cron，而cron中执行的程序有输出内容，输出内容会以邮件形式发给cron的用户，而sendmail没有启动所以就产生了这些文件；
解决办法:
将crontab里面的命令后面加上 > /dev/null 2>&1 或者crontab里面的命令后面加上 > /dev/null