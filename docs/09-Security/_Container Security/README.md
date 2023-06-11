---
title: Container Security
sidebar_position: 3
tags: [Container,Security]
---
## 容器内核隔离方案
- Kata Containers： Kata Containers 是一个轻量级的虚拟化解决方案，利用Intel Clear Containers和Hyper.sh两个开源项目提供的技术，提供了与传统虚拟机类似的隔离和安全性。它使用Intel Clear Containers技术将容器封装在一个轻量级的虚拟机中，并提供了一个高性能的容器运行时。Kata Containers具有广泛的社区支持和生态系统，可以与Docker等其他容器管理工具集成。可以与Docker等其他容器管理工具一起使用。

- Firecracker： Firecracker 是一个新兴的虚拟化解决方案，专门用于运行轻量级工作负载。它是一个基于KVM（内核虚拟机）的微型虚拟机，可以在毫秒级别内启动，提供了高性能和安全性。Firecracker可以与Docker等其他容器运行时一起使用，并已被广泛应用于AWS Lambda等云原生应用场景。

- gVisor： [gVisor](https://gvisor.dev/) 是一个用于容器隔离的轻量级沙箱，可以提供与传统虚拟化相似的隔离和安全性。它使用内核虚拟化技术来模拟Linux内核，同时提供了一个安全的容器运行时。gVisor可以与Docker等其他容器管理工具一起使用，并提供了广泛的应用程序兼容性。

- rkt: 它是一个由 CoreOS 开发的容器运行时工具，可以提供与Docker类似的功能。rkt具有更好的安全性和隔离性，能够在容器运行时提供更高的保护。它还可以轻松地与Kubernetes等容器编排工具集成，提供更灵活的容器管理。

- Weaveworks Ignite，它是一个轻量级的虚拟机管理工具，可与Kubernetes集成。Ignite使用Firecracker提供内核级别的隔离，并使用OCI（Open Container Initiative）容器规范来定义应用程序。Ignite的目标是提供类似于虚拟机的体验，同时保留容器的灵活性和速度。

这些工具都可以提供与传统虚拟机相似的保护，并提供内核级别的隔离，同时保留容器的速度和灵活性。如果您想要在学习Linux服务配置时获得更好的性能和灵活性，可以考虑使用其中一种工具。

## Docker 安全运行时

Docker可以使用Kata Containers或Firecracker来提供内核隔离。

Docker 19.03版本中，引入了一个名为"containerd"的容器运行时。使用containerd可以轻松地将Kata Containers或Firecracker集成到Docker中，并获得内核级别的隔离。这使得Docker可以提供与传统虚拟机相似的保护，并具有容器的速度和灵活性。

要使用Kata Containers或Firecracker作为Docker容器运行时，您需要安装相应的工具和插件。例如，要在Docker中使用Kata Containers，您需要安装Kata Containers运行时，并使用"containerd-shim-kata-v2"插件来运行Kata Containers。

总的来说，您可以使用Docker与Kata Containers或Firecracker一起使用，以获得内核级别的隔离和灵活性。

## LXCFS

- [容器资源可见性工具topic](https://jaegerw2016.github.io/2022/02/15/%E5%AE%B9%E5%99%A8%E8%B5%84%E6%BA%90%E5%8F%AF%E8%A7%81%E6%80%A7%E5%B7%A5%E5%85%B7topic/)
- [利用LXCFS和PodPreset提升容器资源可见性](https://jaegerw2016.github.io/2019/07/03/%E5%88%A9%E7%94%A8LXCFS%E5%92%8CPodPreset%E6%8F%90%E5%8D%87%E5%AE%B9%E5%99%A8%E8%B5%84%E6%BA%90%E5%8F%AF%E8%A7%81%E6%80%A7/)


如果不使用LXCFS，可能会导致以下安全问题：

- 缺乏对容器文件系统的可见性：LXCFS为容器提供了文件系统信息，如果没有LXCFS，容器内的文件系统信息将无法被主机或其他容器看到。这可能导致安全问题，例如无法检测容器中的恶意文件或配置。
- 容器资源限制不准确：LXCFS提供了关于容器资源使用情况的信息，例如内存和CPU使用情况。如果没有LXCFS，容器资源限制可能无法准确地实施，从而导致资源耗尽和性能问题。
- 容器安全性不可控：LXCFS提供了许多安全相关的信息，例如容器中的进程和用户，以及容器中的安全上下文。如果没有LXCFS，容器安全性可能会受到影响，因为安全相关信息无法被主机或其他容器查看和控制。
因此，使用LXCFS可以增强容器的安全性和可见性，可以帮助管理者更好地了解和控制容器的使用情况。


# 容器安全
https://segmentfault.com/a/1190000022872874

## 加强 runc 容器的安全性

使用 runc 运行的容器，可以通过如下几种方式加强安全性：

1. 非特权容器
1. 非 root 账户 - 可能遇到文件夹映射没有权限的问题
1. 根文件系统设为只读，动态数据写入数据卷中

## 安全容器技术

Linux 容器相比传统虚拟机，最大的优势是「敏捷」和「高性能」但是也存在明显的问题——隔离得不彻底，共享了系统内核，存在很多安全隐患，容器越狱的难度要比虚拟机低非常多。

以 cgroup/namespace 为核心的容器技术，容器与宿主共享 Linux 内核，一共有7个攻击面（来自美团的容器安全文章）：Linux Kernel、Namespace/Cgroups/Aufs、Seccomp-bpf、Libs、Language VM、User Code、Container engine

总之它很简单有效，但是不够安全，因此衍生出了一些加强安全性的容器技术：

1. [kata containers](https://github.com/kata-containers/kata-containers): kata 容器本质是轻量级虚拟机，但是性能和使用上和传统容器类似。
    - kata 可以直接通过 cri-o/containerd 接入到 k8s 中：[how-to/run-kata-with-k8s](https://github.com/kata-containers/documentation/blob/master/how-to/run-kata-with-k8s.md)
1. [google/gvisor](https://github.com/google/gvisor): google 开源的安全容器技术，其本身是一个用户态 Linux 内核，借此实现容器的内核隔离。
    - gvisor 也可以通过 containerd 接入 kubernetes: [gvisor with kubernetes](https://github.com/google/gvisor/blob/master/g3doc/user_guide/quick_start/kubernetes.md)
2. [firecracker-microvm](https://github.com/firecracker-microvm/firecracker): aws 开源的微虚拟机技术，使用 rust 实现，细节待研究。

更多的容器运行时可以在 [Container Runtime - CNCF Landscape](https://landscape.cncf.io/category=container-runtime&format=card-mode&grouping=category) 中找到。

上述这些安全容器技术全都兼容 OCI 规范，可以和 kubernetes 无缝集成。

目前美团阿里等国内大厂正在转向 kata containers，比如阿里云的 kubernetes 容器运行时就能选择「安全沙箱」。
而 gvisor 被 google 应用在自家的产品中。


>安全容器的主要应用场景是多租户，比如 serverless 的公有云环境（阿里云 serverless kubernetes），各用户之间和完全不能互相信任的。
这种场景下就必须要加强各租户之间的隔离性，runc 容器的隔离性就不够用了。

## 相关文章

- [云原生之容器安全实践-美团技术团队](https://tech.meituan.com/2020/03/12/cloud-native-security.html)
- [基于Rust-vmm实现Kubernetes运行时](https://zhuanlan.zhihu.com/p/188500726)
