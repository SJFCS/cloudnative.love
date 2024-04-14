---
title: ephemeral-containers
tags: [Kubernetes]
sidebar_position: 4
---

临时容器：一种特殊的容器，该容器在现有 Pod 中临时运行，以便完成用户发起的操作，例如故障排查。 

当由于容器崩溃或容器镜像不包含调试程序（例如[distroless](https://github.com/GoogleContainerTools/distroless)等） 而导致 kubectl exec 无法运行时，临时容器对于排除交互式故障很有用。

## 使用临时容器来调试的例子 
你可以使用 kubectl debug 命令来给正在运行中的 Pod 增加一个临时容器。 首先，像示例一样创建一个 pod：

```bash
kubectl run ephemeral-demo --image=registry.k8s.io/pause:3.1 --restart=Never
```
如果你尝试使用 kubectl exec 来创建一个 shell，你将会看到一个错误，因为这个容器镜像中没有 shell。
```bash
kubectl exec -it ephemeral-demo -- sh
OCI runtime exec failed: exec failed: container_linux.go:346: starting container process caused "exec: \"sh\": executable file not found in $PATH": unknown
```
你可以改为使用 kubectl debug 添加调试容器。 如果你指定 -i 或者 --interactive 参数，kubectl 将自动挂接到临时容器的控制台。
```bash
kubectl debug -it ephemeral-demo --image=busybox:1.28 --target=ephemeral-demo

Defaulting debug container name to debugger-8xzrl.
If you don't see a command prompt, try pressing enter.
/ #
```

此命令添加一个新的 busybox 容器并将其挂接到该容器。--target 参数指定另一个容器的进程命名空间。 这个指定进程命名空间的操作是必需的，因为 kubectl run 不能在它创建的 Pod 中启用共享[进程命名空间](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/share-process-namespace/)。


## 参考文档
- https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/ephemeral-containers/