---
title: Dockerd 启用 live-restore
tags: [Docker]
---

## live-restore 特性简介

+ 重启 dockerd 不影响现有 Container。
    例如 dockerd 内存泄漏。 docker 17.06 之前容易出现这个问题，再也不怕 dockerd 吃掉所有内存又不敢重启了～
+ 升级 docker 小版本
    仅在安装补丁版本 ( YY.MM.x) 时受支持，不适用于主要 ( YY.MM) 守护程序升级。
+ 修改 dockerd 配置而不影响已启动的 Container，只要不改变 daemon-level 级别参数，是不会影响已运行容器的。

  :::tip
  如果有容器挂载了 docker.sock 文件，重启后工作可能会不正常，需要重启该容器。原因是重启 dockerd 后 docker.sock 文件的 inode 发生了改变。
  :::

## 启用 live-restore 

在 `/etc/docker/daemon.json` 中添加 `"live-restore": true` 选项，比如：

```json
{
  "live-restore": true
}
```
然后在 `/usr/lib/systemd/system/docker.service`  中添加：

```bash
# kill only the docker process, not all processes in the cgroup
KillMode=process
```
## 重载 dockerd 配置

在 Linux 上，您可以通过重新加载 Docker 守护进程来避免重新启动（并避免容器停机）。

如果使用 systemd，则使用命令`systemctl reload docker`。

否则，向进程dockerd发送 SIGHUP信号。

```bash
kill -SIGHUP $(pidof dockerd) # 给 dockerd 发送 SIGHUP 信号，dockerd 收到信号后会 reload 配置
```

## 检查是否配置成功
```bash
docker info | grep -i live
```
应该能看到 `Live Restore Enabled: true`

这样，我们就可以 `systemctl restart docker` 重启 `docker daemon` ，而不影响运行在其中的 `container` 了。


参考：https://docs.docker.com/config/containers/live-restore/
