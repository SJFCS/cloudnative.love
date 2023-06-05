---
title: Cgroup
---

https://bbotte.github.io/others/linux-system-limits-process-cpu-usage.html


## 4.在 server 节点，查询 rancher/server 容器的进程号，建立命名空间/var/run/netns 并与 rancher/server 容器进行连接，通过 ipnetns 相关命令查询该容器的 ip

 查询registry Pid

```bash
[root@server ~]# docker inspect -f '{{.State.Pid}}' 52849a592332
4253
```

 创建命名空间

```bash
sudo ln -s 源文件 目标文件 
[root@server ~]# ln -s /proc/刚刚询的Pid/ns/net  /var/run/netns/rancher-server（任意名字）
[root@server ~]# ip netns list （列出命名空间）
rancher-server (id: 0)
[root@server ~]# ip netns exec rancher-server1 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
4: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:2/64 scope link 
       valid_lft forever preferred_lft forever
```



## 6.在 server 节点创建 memory 控制的 cgroup，名称为：xiandian，创建完成后将当前进程移动到这个 cgroup 中，通过 cat 相关命令查询 cgroup 中的进程 ID

```bash
sudo sh -c "echo $$ >> /sys/fs/cgroup/memory/xiandian/tasks"
cat /proc/$$/cgroup
//或者 
sudo sh -c "echo $$ >> /sys/fs/cgroup/memory/xiandian/cgroup.proc"
cat /proc/进程号/cgroup
echo $$ #输出当前进程号

```


## 7.在 server 节点创建 cpu 控制的 cgroup，名称为：xiandian。假设存在进程号为 8888 的进程一直占用 cpu，并且达到 100%，严重影响系统的正常运行。使用cgroup 相关知识在创建的 cgroup 中将此进程操作 cpu 配额调整为 30%。将以上操作命令及检查结果填入答题框。

```bash
mkdir /sys/fs/cgroup/cpu/xiandian
echo 8888 > /sys/fs/cgroup/cpu/xiandian/tasks
echo 30000 > /sys/fs/cgroup/cpu/xiandian/cpu.cfs_quota_us
```

## 8.在 server 节点使用 nginx 镜像创建一个容器，只能使用特定的内核，镜像使用 nginx：latest，并通过查看 cgroup 相关文件查看内核使用情况，将以上操作命令及检查结果填入答题框（提示，首先要修改 cpuset.cpus 的参数）。

```bash
https://blog.csdn.net/horsefoot/article/details/51731543
[root@server xiandian]# docker run -idt --name nginx --cpuset-cpus 0-1 nginx:latest  /bin/bash
dc7bcf0974927e5247f38788bf5aaf2f0844c786dfc2553a03e7168fbb23e240
[root@server xiandian]# docker inspect -f '{{.State.Pid}}' dc7bcf0974927e5247f38788bf5aaf2f0844c786dfc2553a03e7168fbb23e240
67738
[root@server xiandian]# cat /sys/fs/cgroup/cpuset/system.slice/docker-dc7bcf0974927e5247f38788bf5aaf2f0844c786dfc2553a03e7168fbb23e240.scope/cpuset.cpus
0-1

```
