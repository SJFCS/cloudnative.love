---
title: ETCD故障恢复
---

https://kubernetes.io/zh/docs/tasks/administer-cluster/configure-upgrade-etcd/

https://my.oschina.net/u/2306127/blog/2990359

https://blog.csdn.net/Ares_ZhangQ/article/details/109479434

https://sq.sf.163.com/blog/article/197476452926455808

## 简介

etcd 是兼具一致性和高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

您的 Kubernetes 集群的 etcd 数据库通常需要有个备份计划。

要了解 etcd 更深层次的信息，请参考 [etcd 文档](https://etcd.io/docs/)。

## 先决条件

- 运行的 etcd 集群个数成员为奇数。

- etcd 是一个 leader-based 分布式系统。确保主节点定期向所有从节点发送心跳，以保持集群稳定。

- 确保不发生资源不足。

  集群的性能和稳定性对网络和磁盘 I/O 非常敏感。任何资源匮乏都会导致心跳超时， 从而导致集群的不稳定。不稳定的情况表明没有选出任何主节点。 在这种情况下，集群不能对其当前状态进行任何更改，这意味着不能调度新的 pod。

- 保持 etcd 集群的稳定对 Kubernetes 集群的稳定性至关重要。 因此，请在专用机器或隔离环境上运行 etcd 集群，以满足 [所需资源需求](https://etcd.io/docs/current/op-guide/hardware/)。

- 在生产中运行的 etcd 的最低推荐版本是 `3.2.10+`。

## 替换 etcd 故障节点

etcd 集群通过容忍少数成员故障实现高可用性。 但是，要改善集群的整体健康状况，请立即替换失败的成员。当多个成员失败时，逐个替换它们。 替换失败成员需要两个步骤：删除失败成员和添加新成员。

1. 获取失败的 `member1` 的成员 ID：

   ```shell
   etcdctl --endpoints=http://10.0.0.2,http://10.0.0.3 member list
   ```

   显示以下信息：

   ```console
   8211f1d0f64f3269, started, member1, http://10.0.0.1:2380, http://10.0.0.1:2379
   91bc3c398fb3c146, started, member2, http://10.0.0.2:2380, http://10.0.0.2:2379
   fd422379fda50e48, started, member3, http://10.0.0.3:2380, http://10.0.0.3:2379
   ```

2. 移除失败的成员

   ```shell
   etcdctl member remove 8211f1d0f64f3269
   ```

   显示以下信息：

   ```console
   Removed member 8211f1d0f64f3269 from cluster
   ```

3. 增加新成员：

   ```shell
   etcdctl member add member4 --peer-urls=http://10.0.0.4:2380
   ```

   显示以下信息：

   ```console
   Member 2be1eb8f84b7f63e added to cluster ef37ad9dc622a7c4
   ```

4. 在 IP 为 `10.0.0.4` 的机器上启动新增加的成员：

   ```shell
   export ETCD_NAME="member4"
   export ETCD_INITIAL_CLUSTER="member2=http://10.0.0.2:2380,member3=http://10.0.0.3:2380,member4=http://10.0.0.4:2380"
   export ETCD_INITIAL_CLUSTER_STATE=existing
   etcd [flags]
   ```

5. 做以下事情之一：

   1. 更新 Kubernetes API 服务器的 `--etcd-servers` 参数，然后重新启动 Kubernetes API 服务器。
   2. 如果在 deployment 中使用了负载均衡，更新负载均衡配置。

## 内置快照备份 etcd 集群

etcd 支持内置快照。快照可以从使用 `etcdctl snapshot save` 命令的活动成员中获取， 也可以通过从 etcd [数据目录](https://etcd.io/docs/current/op-guide/configuration/#--data-dir) 复制 `member/snap/db` 文件，该 etcd 数据目录目前没有被 etcd 进程使用。获取快照不会影响成员的性能。

你可以通过指定端点，证书等来拍摄快照，如下所示：

```shell
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
  snapshot save <backup-file-location>
```

可以从 etcd Pod 的描述中获得 `trusted-ca-file`, `cert-file` 和 `key-file` 。

验证快照:

```shell
ETCDCTL_API=3 etcdctl --write-out=table snapshot status <backup-file-location>
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| fe01cf57 |       10 |          7 | 2.1 MB     |
+----------+----------+------------+------------+
```

## 扩展 etcd 集群

合理的扩展是在需要更高可靠性的情况下，将三成员集群升级为五成员集群。 请参阅 [etcd 重新配置文档](https://etcd.io/docs/current/op-guide/runtime-configuration/#remove-a-member) 以了解如何将成员添加到现有集群中的信息。

## 恢复 etcd 集群

在启动还原操作之前，必须有一个快照文件。它可以是来自以前备份操作的快照文件， 也可以是来自剩余[数据目录](https://etcd.io/docs/current/op-guide/configuration/#--data-dir)的快照文件。 例如：

```shell
ETCDCTL_API=3 etcdctl --endpoints 10.2.0.9:2379 snapshot restore snapshotdb
```

有关从快照文件还原集群的详细信息和示例，请参阅 [etcd 灾难恢复文档](https://etcd.io/docs/current/op-guide/recovery/#restoring-a-cluster)。

> **说明：**
>
> 如果集群中正在运行任何 API 服务器，则不应尝试还原 etcd 的实例。相反，请按照以下步骤还原 etcd：
>
> - 停止 *所有* API 服务实例
> - 在所有 etcd 实例中恢复状态
> - 重启所有 API 服务实例
>
> 我们还建议重启所有组件（例如 `kube-scheduler`、`kube-controller-manager`、`kubelet`），以确保它们不会 依赖一些过时的数据。请注意，实际中还原会花费一些时间。 在还原过程中，关键组件将丢失领导锁并自行重启。

