---
title: Etcd
tags: [Database,Etcd]
---
Etcd 是兼具一致性和高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

要了解 Etcd 更深层次的信息，请参考 [Etcd 文档](https://etcd.io/docs/)。

保持 Etcd 集群的稳定对 Kubernetes 集群的稳定性至关重要。 因此，请在专用机器或隔离环境上运行 Etcd 集群，以满足 [所需资源需求](https://etcd.io/docs/current/op-guide/hardware/)。

## 使用 etcdctl 直接修改/查看 kubernetes 数据

>官方文档：[Interacting with Etcd](https://etcd.io/docs/v3.4.0/dev-guide/interacting_v3/)

以容器方式部署的 Etcd ，可以直接通过 `kubectl exec` 进入 Etcd 容器执行命令：

```shell
$ kubectl -n kube-system exec -it etcd-<node-name> -- sh
```

然后使用容器中自带的 etcdctl 操作 etcd 数据：

```shell
$ export ETCDCTL_API=3

# 列出所有数据
$ etcdctl  get / --prefix --keys-only \
--cacert ca.crt \
--cert peer.crt \
--key peer.key
# 列出所有名字空间
$ etcdctl get /registry/namespaces --prefix --keys-only \
--cacert ca.crt \
--cert peer.crt \
--key peer.key 
# 列出所有 deployments
$ etcdctl get /registry/deployments --prefix --keys-only \
--cacert ca.crt \
--cert peer.crt \
--key peer.key 
# 查看 kube-system 空间的详细信息
$ etcdctl get /registry/namespaces/kube-system \
--write-out="json"
--cacert ca.crt \
--cert peer.crt \
--key peer.key 

# （谨慎操作！！！）强制删除名字空间 `monitoring`，有可能导致某些资源无法被 GC。
$ etcdctl del /registry/namespaces/monitoring \
--cacert ca.crt \
--cert peer.crt \
--key peer.key 
```

## Etcd 集群运维需知

1. Etcd 集群的节点数量越多，写入速度越慢。因为 raft 协议要求超过 1/2 的节点写入成功，才算是一次成功的写操作。
   1. 为了避免网络分区故障，通常使用 3/5/7 奇数个 etcd 节点。
2. 如果超过 (N-1)/2 个成员节点断开连接，则etcd 集群因为无法进行仲裁而无法继续正常运行，这个时候所有的etcd 实例都将变成**只读状态**。

## 推荐阅读
- [故障模式](https://etcd.io/docs/v3.4/op-guide/failures/)
- https://github.com/kubernetes-sigs/etcdadm
- https://cizixs.com/2016/08/02/intro-to-etcd/
- https://www.cnblogs.com/doscho/p/6227351.html
- https://blog.51cto.com/u_15127570/2710980
- https://doczhcn.gitbook.io/etcd/
- https://www.zhaowenyu.com/etcd-doc/ops/etcd-discovery-dns.html
- https://www.cnblogs.com/winstom/p/11811373.html#%E6%B7%BB%E5%8A%A0srv%E8%A7%A3%E6%9E%90-1
- https://etcd.io/docs/v3.4/demo/
- https://zhuanlan.zhihu.com/p/111245626