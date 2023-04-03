---
title: User Group and ACL
---

```bash
-rw-r--r-- 1                        admin admin  11584     3月30日 19:40    docusaurus.config.js
文件权限类型 链接到此inode的文件名数量    owner group  体积byte   最后修改日期     文件名
```
## 文件权限类型
文件权限类型的第一个字符代表文件是目录、文件或连接等
- [d] 代表目录
- [-] 代表文件
- [|] 代表链接
- [b] 代表块设备，如磁盘 
- [c] 代表传行端口设备，如鼠标键盘 `ls -l /dev/input` ，你可以查看具体设备的输出 `cat /dev/input/by-id/DEVICE_NAME`
- [s] 代表 socket 文件，最能体现"一切皆文件"设计哲学。如 `sudo ls -l /var/run/docker.sock`

文件权限类型的剩余部分代表权限，三个为一组，均为[rwx]。分别代表读(read)、写(write)、执行(execute)

:::tip
Linux 中的目录执行权限指的是能否进入该目录并查看其中的内容。如果一个用户没有权限执行某个目录，则该用户无法进入该目录，也无法列出其内容。

要查看一个目录的权限，可以使用 ls -l 命令，该命令会显示该目录的元数据信息，包括文件类型、所有者、权限等。例如：
```bash
❯ ls -l -d ../cloudnative.love
drwxr-xr-x 1 admin admin 330  3月30日 19:40 ../cloudnative.love
```
:::



工作目录是什么？，一般家目录为默认工作目录 pwdS
```bash
rw-      r--      r--
110      100      100
421      421      421
6        4        4
owner    group    other
```
:::
[---------]
root 不受系统权限限制
:::
更改后要刷新session

## 特权 lsattr chattr


## 查看文件创建时间
```bash
ls -l --full-time
-rw-r--r-- 1 admin admin  11584 2023-03-30 19:40:43.082307120 +0800 docusaurus.config.js
```

```bash
❯ stat docusaurus.config.js
  File: docusaurus.config.js
  Size: 11584           Blocks: 24         IO Block: 4096   regular file
Device: 0,43    Inode: 642232      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/   admin)   Gid: ( 1000/   admin)
Access: 2023-03-30 19:40:43.082307120 +0800  #访问时间
Modify: 2023-03-30 19:40:43.082307120 +0800  #修改时间
Change: 2023-03-30 19:40:43.082307120 +0800  #变更时间
 Birth: 2023-03-30 19:40:43.082307120 +0800  #创建时间
```

:::tip Modify vs Change
Modify 是最后一次修改文件内容的时间戳。 这通常称为 mtime 。
Change 是文件的 inode 上次更改的时间戳，例如更改权限、所有权、文件名、硬链接数。它通常被称为 ctime 。
可以利用 touch 指令进行文件的时间修改
:::
## socket
socket: https://blog.csdn.net/dog250/article/details/100998838
## 
https://www.cnblogs.com/llife/p/11470668.html  
https://www.ruanyifeng.com/blog/2011/12/inode.html

[root@dns01-113 ~]# chgrp named /var/named/abcdocker.com.zone 

在传统的 Linux 权限的基础上，实际上还有更详细的权限管理配置 ACL(Access Control List)。用户不仅能设置一个文件的所有者、所有组以及权限，还可以细化到其他用户是否可以拥有特殊权限、其他组是否可以拥有特殊权限。

getfacl 可以查看文件的详细权限设置
```bash
getfacl /var/run/docker.sock

# file: var/run/docker.sock
# owner: root
# group: docker
user::rw-
group::rw-
mask::rw-
other::---
```

## . 和 .. 
在 Linux 中，"."是一个特殊的链接，代表当前目录。而".."也是一个特殊的链接，代表当前目录的父目录。

具体来说，"."链接指向当前目录的inode节点，而".."链接则指向当前目录的父目录的inode节点。inode节点是Linux文件系统中的重要概念，每个文件或目录都对应着一个inode节点，它存储了文件或目录的元数据信息，如权限、所有者、大小、创建时间等等。

使用这两个链接可以帮助用户方便地访问其所在目录以及上一级目录。例如，使用"cd ."命令可以进入当前目录，而使用"cd .."命令则可以返回上一级目录。


## 隐藏 .xx


如果我们希望把用户 user1 赋予额外的读写权限，可以使用 sudo setfacl -m u:user1:6 docker.sock
对应用户组 group1 则是 sudo setfacl -m g:group1:6 docker.sock


这样，即使用户文件和用户组文件无法修改，仍然可以确保特定的用户具有特定文件的权限


- nscd（Name Service Cache Daemon）是一种能够缓存 passwd、group、hosts 的本地缓存服务，分别对应三个源 /etc/passwd、/etc/hosts、/etc/resolv.conf。其最为明显的作用就是加快 DNS 解析速度，在接口调用频繁的内网环境建议开启。

- Linux grpconv(group convert to shadow password)命令用于开启群组的投影密码。

Linux系统里的用户和群组密码，分别存放在/etc目录下的passwd和group文件中。因系统运作所需，任何人都得以读取它们，造成安全上的破绽。投影密码将文件内的密码改存在/etc目录下的shadow和gshadow文件内，只允许系统管理者读取，同时把原密码置换为"x"字符。投影密码的功能可随时开启或关闭，您只需执行grpconv指令就能开启群组投影密码。