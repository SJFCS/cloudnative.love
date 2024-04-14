---
title: PodDisruptionBudget
tags: [Kubernetes]
sidebar_position: 3
---

PodDisruptionBudget (PDB) 是 Kubernetes 中的一个资源对象，用于控制在进行节点维护或者故障恢复时，可以同时中断的 Pod 的数量。它允许您定义最大中断的 Pod 数量，以确保您的服务在维护或者故障期间保持可用性。

PDB 通过 minAvailable 或者 maxUnavailable 两种方式来定义最大中断数量：

- minAvailable: 这个选项允许您指定要保持可用的最小 Pod 数量。当您需要确保在维护期间至少有一定数量的 Pod 可用时，可以使用这个选项。
- maxUnavailable: 这个选项允许您指定在维护期间允许不可用的最大 Pod 数量。当您可以容忍一定比例的 Pod 不可用时，可以使用这个选项。

PDB 可以应用于具体的命名空间中的一组 Pod，也可以应用于整个集群中的一组 Pod。通过定义 PodDisruptionBudget，您可以确保在节点维护或者故障情况下，系统的可用性得到了充分的保障，避免了大规模的中断。
## 例子

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: etcd-pdb
  labels:
    pdb: etcd
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: etcd
```

## 参考文档
- https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/disruptions/