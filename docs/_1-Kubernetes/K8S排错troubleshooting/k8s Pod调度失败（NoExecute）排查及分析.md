---
title: k8s Pod调度失败（NoExecute）排查及分析

categories:
  - Kubernetes
series:
  - K8S排错
lastmod: '2021-07-12'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



## 现象

机器重启之后，部分Pod无法启动，`kubectl describe pod`发现如下错误：

```go
1 node(s) had taints that the pod didn't tolerate 2 node(s) didn't match node selector
```

## **查看taints**

```
[root@work2 log]# kubectl describe node/work2 |grep Taint
Taints:             caf=log:NoExecute
                    node.kubernetes.io/unreachable:NoExecute
```

看来机器在关机同时，k8s自动为这个节点添加了不可被调度污点 node.kubernetes.io/unreachable:NoExecute，所以也就导致我的业务Pod不可被调度。

## **解决过程**

尝试手动删除污点，执行如下命令后发现无法删除。

```
kubectl taint node k8snode2 node.kubernetes.io/unreachable-
删除所有的污点
kubectl patch node k8s-node1 -p '{"spec":{"Taints":[]}}' 
```

经查阅文档（https://kubernetes.io/zh/docs/concepts/scheduling-eviction/taint-and-toleration/）发现，此污点表明 无法从节点控制器访问节点。于是排查系统组件kubelet时发现日志有关交换分区报错，原来swapoff -a临时关闭swap分区重启后sawp分区又被系统挂载了，于是关闭了交换分区并修改fstab文件，然后kubelet服务正常了污点自动消失。
