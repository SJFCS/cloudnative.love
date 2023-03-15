---
title: User Group and ACL
---
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

如果我们希望把用户 user1 赋予额外的读写权限，可以使用 sudo setfacl -m u:user1:6 docker.sock
对应用户组 group1 则是 sudo setfacl -m g:group1:6 docker.sock


这样，即使用户文件和用户组文件无法修改，仍然可以确保特定的用户具有特定文件的权限





- nscd（Name Service Cache Daemon）是一种能够缓存 passwd、group、hosts 的本地缓存服务，分别对应三个源 /etc/passwd、/etc/hosts、/etc/resolv.conf。其最为明显的作用就是加快 DNS 解析速度，在接口调用频繁的内网环境建议开启。

- Linux grpconv(group convert to shadow password)命令用于开启群组的投影密码。

Linux系统里的用户和群组密码，分别存放在/etc目录下的passwd和group文件中。因系统运作所需，任何人都得以读取它们，造成安全上的破绽。投影密码将文件内的密码改存在/etc目录下的shadow和gshadow文件内，只允许系统管理者读取，同时把原密码置换为"x"字符。投影密码的功能可随时开启或关闭，您只需执行grpconv指令就能开启群组投影密码。