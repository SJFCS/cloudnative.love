---
sidebar_position: 1
---
## 简介
ReplicationController (RC): 是较旧的概念，用于确保任何时候都有指定数量的Pod副本在运行。如果有太多副本，它会终止多余的副本；如果副本不足，它会启动新的副本。
ReplicaSet (RS): 是新一代的ReplicationController，提供了相同的副本管理功能，但是具有更强的选择器功能。ReplicaSet支持集合式的选择器（set-based selector）这意味着可以使用更加复杂的选择逻辑，例如 environment in (prod, qa) 或 tier notin (frontend, backend)，而ReplicationController仅支持等式选择器（equality-based selector）例如 env=prod 或 tier=frontend。。

尽管ReplicationController仍然可以在现代Kubernetes集群中使用，但它已经被认为是一种较为过时的方法，主要是用于向后兼容。
ReplicaSet是推荐的用法，因为它提供了更灵活的选择器功能和一致的API设计。实际上，Deployment是现在推荐使用的更高级别的概念，它在内部使用ReplicaSet来实现Pod的部署和滚动更新。
与Deployment的关系:

## ReplicaSet

ReplicaSet的资源清单文件：

```yaml
apiVersion: apps/v1 # 版本号
kind: ReplicaSet # 类型       
metadata: # 元数据
  name: # rs名称 
  namespace: # 所属命名空间 
  labels: #标签
    controller: rs
spec: # 详情描述
  replicas: 3 # 副本数量
  selector: # 选择器，通过它指定该控制器管理哪些pod
    matchLabels:      # Labels匹配规则
      app: nginx-pod
    matchExpressions: # Expressions匹配规则
      - {key: app, operator: In, values: [nginx-pod]}
  template: # 模板，当副本数量不足时，会根据下面的模板创建pod副本
    metadata:
      labels:
        app: nginx-pod
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.1
        ports:
        - containerPort: 80
```

## 什么是 ownerReferences

在Kubernetes中，ownerReferences是一种定义在某个资源对象（如Pods, ReplicaSets等）中的字段，它用于建立资源之间的所有权和生命周期依赖关系。当一个资源对象拥有ownerReferences字段时，这意味着它被另一个资源所拥有。Kubernetes利用这种关系来管理资源的自动清理，即当拥有者对象被删除时，所有属于该拥有者的依赖对象也会被自动删除（这取决于ownerReferences中的blockOwnerDeletion和propagationPolicy设置）。


查看pod的yaml 其中 `metadata.ownerReferences`会指向到 ReplicaSet ，假如通过deployment创建资源，还可以看到rs的`metadata.ownerReferences` 会指向 deployment
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-02-28T22:30:44Z"
  generateName: frontend-
  labels:
    tier: frontend
  name: frontend-gbgfx
  namespace: default
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: frontend
    uid: e129deca-f864-481b-bb16-b27abfd92292
...
```

在ReplicaSets的上下文中，ownerReferences通常用于指示ReplicaSet创建的Pods的所有权关系。当ReplicaSet创建Pods时，它会在这些Pods的元数据中设置ownerReferences字段，指明这些Pods的拥有者是该ReplicaSet。这样做的目的是为了确保当ReplicaSet被删除时，它所管理的Pods也会被自动清理。

