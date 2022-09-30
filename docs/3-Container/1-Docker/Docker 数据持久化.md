---
title: Docker 数据持久化
tags: [Docker]
---
Docker 持久化数据有两种方式：
1. 使用数据卷(volume)：
      - 如果你要在多个容器间共享数据，那最佳选择是 volume
      - 通过使用 NFS 等 volume 驱动，还可以实现将数据保存到远程存储(NAS)中。
1. 文件夹映射(bind)：
      - 非 root 容器使用文件夹映射时，会遇到权限问题，因为 [docker 默认创建的文件夹用户是 `root/root`](https://github.com/moby/moby/issues/2259)
      - bind 权限问题目前比较好的解决方案，是提前手动创建文件夹并设定 `uid`/`gid`，如 `mkdir xxx && chown 1000:1000 xxx`
      - 因为 bind(文件夹映射)很直观，我更多的时候都偏向于使用文件夹映射。
      - 启用 selinux 很可能导致 bind 权限问题，通常建议关闭复杂的 selinux...

volume 和 bind 的详细对比参见： 

1. [docker - volumes vs mount binds. what are the use cases?](https://serverfault.com/questions/996785/docker-volumes-vs-mount-binds-what-are-the-use-cases)
2. [docker data volume vs mounted host directory](https://stackoverflow.com/questions/34357252/docker-data-volume-vs-mounted-host-directory)
