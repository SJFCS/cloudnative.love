---
title: LimitRange & Resource Quotas
tags: [Kubernetes]
---

LimitRange 和 ResourceQuotas 是 Kubernetes 中用于管理资源使用的两种不同机制，它们在作用范围和管理层级上有所不同。

LimitRange 主要关注单个 Pod 或容器层面的资源约束，确保它们不会请求过多或过少的资源。  
ResourceQuotas 主要关注整个命名空间层面的资源使用，限制命名空间内所有资源的总量，以避免资源的过度使用。  
通过组合使用这两种机制，管理员可以实现对 Kubernetes 集群资源使用的细粒度控制，既保证了资源的公平分配，也确保了单个应用不会因为资源的贪婪使用而影响到集群中的其他应用。

## LimitRange
LimitRange 对象为 Pod 中的每个容器或者命名空间中的 PersistentVolumeClaims 设置默认的资源请求（requests）和资源限制（limits），以及最大/最小的资源使用限制。这保证了命名空间内的每个 Pod 或容器都符合特定的资源使用策略，防止了某个单一的 Pod 或容器因为占用过多资源而影响其他资源的正常运行。


```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - default: # this section defines default limits
      cpu: 500m
    defaultRequest: # this section defines default requests
      cpu: 500m
    max: # max and min define the limit range
      cpu: "1"
    min:
      cpu: 100m
    type: Container
---
apiVersion: v1
kind: LimitRange
metadata:
  name: example-limitrange
  namespace: example-namespace
spec:
  limits:
    - type: Pod
      max:
        cpu: "2"
        memory: "1Gi"
      min:
        cpu: "200m"
        memory: "6Mi"
    - type: Container
      default:
        cpu: "300m"
        memory: "200Mi"
      defaultRequest:
        cpu: "200m"
        memory: "100Mi"
      max:
        cpu: "2"
        memory: "1Gi"
      min:
        cpu: "100m"
        memory: "4Mi"    
```

## Resource Quotas

ResourceQuotas（资源配额）对象为整个命名空间设置了资源使用的总量限制。这包括了对 Pod、PersistentVolumeClaims、Services 等 Kubernetes 资源的总计数限制，以及 CPU、内存等计算资源的总量限制。使用资源配额可以避免某个命名空间占用过多的集群资源，保证资源的公平分配。


```yaml
apiVersion: v1
kind: List
items:
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-high
  spec:
    hard:
      cpu: "1000"
      memory: 200Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator : In
        scopeName: PriorityClass
        values: ["high"]
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-medium
  spec:
    hard:
      cpu: "10"
      memory: 20Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator : In
        scopeName: PriorityClass
        values: ["medium"]
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-low
  spec:
    hard:
      cpu: "5"
      memory: 10Gi
      pods: "10"
    scopeSelector:
      matchExpressions:
      - operator : In
        scopeName: PriorityClass
        values: ["low"]

```