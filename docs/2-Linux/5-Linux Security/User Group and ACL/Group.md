Linux 修改用户组后，如何关闭所有 X session 下使得组生效？

最近在使用 docker-ce ，在配置当前用户组为 docker 的时候（sudo usermod -aG docker $USER）发现：必须要关闭当前的 session 重新登录 后，才能使得修改的组生效。 
https://github.com/moby/moby/issues/5314#issuecomment-61560265


id -g 给出当前用户的主组号, id -G 列出所有组号

- 使用newgrp命令登录到一个新组。
```bash
newgrp <new group name> 

usermod -aG docker user
newgrp docker
```

- `su - $USER` : 使用这个命令重新开始一个 session ， 并重新继承当前环境。

-  `sg webdev -c "command"` 使用某个组 id 启动命令(并在 shell 中保持当前特权) 
(sg 与 su 类似，但适用于组，如果您在系统数据中被列为组的成员，则不需要组密码即可工作)

您可以使用 getent group { name }命令检查组成员资格:
```bash
$ getent group webdev
webdev:x:1008:webdev,takpar
```
```bash
$ cat /etc/group | grep `id -g`
```
https://unix.stackexchange.com/questions/18796/how-to-apply-changes-of-newly-added-user-groups-without-needing-to-reboot


With CentOS 6 nscd might be running. If you did not change the group ownership by a hig-level-command (like usermod) you have to make sure to run grpconv so /etc/gshadow gets updated as well. If nscd is running add nscd -i group to invalidate the local group cache. If you changed the primary GID run nscd -i passwd.

在 CentOS 6中，nscd 可能正在运行。如果没有通过高级命令(如 usermod)更改组所有权，则必须确保运行 grpconv，以便同时更新/etc/gshadow。如果 nscd 正在运行，则添加 nscd-i 组以使本地组缓存失效。如果更改了主 GID，请运行 nscd-i passwd。