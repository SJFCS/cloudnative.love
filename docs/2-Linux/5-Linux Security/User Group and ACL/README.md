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

