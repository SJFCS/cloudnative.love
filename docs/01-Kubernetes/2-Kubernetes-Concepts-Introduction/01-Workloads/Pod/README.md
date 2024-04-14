---
title: Pod
tags: [Kubernetes]
sidebar_position: 0
---
容器本质是被 Cgroups/Namespace 隔离的 Linux 进程，一个进程一个容器的设计理念会遇到一些问题，比如调度计算问题，应用依赖问题和可观测问题。所以k8s采用pod为基本的调度单位，把多个进程组合成一个进程组（Pod）进行调度。通过k8s.gcr.io/pause容器来进行命名空间的初始化，pod 中的 contianner 实现了 PID 命名空间隔离，每个contianner都是一个 pid=1 的进程，但他们共享相同的网络命名空间，当然我们也可通安全上下文来进行调整共享命名空间的策略。这样使得容器变得更加灵活，衍生出了很多代理模式如sidecar、ambassador、adapter 等。

- istio 在 pod 中注入辅助容器（也称 sidecar）实现服务网格
- 在不方便修改应用代码使日志输出到 stdout/stderr 的情况下，可以通过 sidecar 实现容器的日志收集
- argo-workflows 使用 sidecar 来管理 workflow 每个 step 的生命周期
- 可通过 init-containers 来在主容器启动前进行一些必要的环境配置


pod 共享命名空间配置如下：

```yaml
apiVersion: v1
kind: Pod
...
spec:
  # 共享 pid 名字空间，这样容器就可以看到其他容器的进程
  # 可通过 ps aux 验证，会发现 1 号进程变成了 pause，并且可以看到 Pod 中的所有进程
  # 在某些场景中需要用到它，比如 argo-workflows 就使用它来监测任务容器的执行状态
  shareProcessNamespace: true
  # 直接使用宿主机网络，不新建 network namespace
  hostNetwork: true
  # 直接使用宿主机的 IPC namespace
  hostIPC: true
  # 直接使用宿主机的 pid namespace，这样容器就能看到宿主机的所有进程了
  hostPID: true
```

Pod 的容器之间，还可以共享数据卷，因为数据卷也是定义的 Pod 级别的。


## 推荐阅读
- [The Almighty Pause Container](https://www.ianlewis.org/en/almighty-pause-container)
- [Pause 容器](https://jimmysong.io/kubernetes-handbook/concepts/pause-container.html)
- [Kubernetes之Pause容器](https://o-my-chenjian.com/2017/10/17/The-Pause-Container-Of-Kubernetes/)
- [从 Pause 容器理解 Pod 的本质](https://k8s.iswbm.com/c02/p02_learn-kubernetes-pod-via-pause-container.html)