# 扩展 APIServer

## 方案一 - CRD+Operator - 复杂有状态应用的管理器

如果需要在 Kubernetes 中部署类似 rook-ceph/istio/mysql-cluster/prometheus-cluster/mongo-cluster 之类的复杂有状态应用，最好的方式就是 CRD+Operator。

### 什么是 Operator?

工具：
- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)

### 为什么需要 CRD+Operator

因为 Kubernetes 提供的 StatefulSet 功能太弱了，要部署一个可伸缩的有状态应用，StatefulSet 的功能远远不够。

对于大多数单节点的有状态应用，比如各类单节点数据库 MySQL/Mongo/ElasticSearch/Redis，
都可以简单地使用 StatefulSet+volumeClaimTemplates 进行部署。


而对于 Mongo 分片集群、MySQL 集群、rook-ceph 这类组件众多，不同组件功能和地位都不同，启动/初始化流程、扩缩容流程都很复杂的有状态应用，StatefulSet 就无能为力了。


但是数据库的高可用与弹性扩缩容，是企业自建数据库的刚需。
另一方面不止数据库，其他诸如 Istio 这类复杂有状态应用，也面临着同样的问题。

于是 Operator 应运而生，它由 CoreOS 首先提出，现在已经成了 Kubernetes 上部署与管理复杂有状态应用的事实标准。

## StatefulSet or Deployment?

如果我们考虑多个 Pod 共用一个 PV 的情况，就比如多个 nginx Pod 挂载同一个 `/usr/share/nginx/html` 的 PV，然后都可以读写这个 PV。
这种情况下，好像就没必要使用 StatefulSet+volumeClaimTemplates，Deployment+PVC 就完全够用了，因为这类应用程序根本不需要 StatefulSet 提供的功能——稳定的唯一标识符、有序扩缩容。

StatefulSet 适合不同 Pod 使用不同 PV 的情况，

### 注意事项

使用 operator 时，operator 和 cr(Custom Resource自定义资源） 的删除必须遵循如下顺序：

1. 删除 cr，等待 cr 被 operator 完全清理
2. 删除 operator

如果你先删了 operator，将导致 cr finalizer无法完全清理


## 方案二 - APIServer Aggregation

这是目前社区在推的方案，目前看来会更复杂些，但是有一些 operator 没有的能力。

- [apiserver-builder-alpha](https://github.com/kubernetes-sigs/apiserver-builder-alpha)
