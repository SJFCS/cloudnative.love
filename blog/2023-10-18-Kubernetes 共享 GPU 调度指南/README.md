---
title: Kubernetes 共享 GPU 调度指南
tags: [Kubernetes,GPU]
---

本篇博文介绍了如何在 Kubernetes 集群中使用 GPU 资源，以及如何设置共享 Nvidia GPU 的详细步骤。

依照本文操作你将完成如下内容：

- Nvidia 和 CUDA 驱动安装
- Nvidia Container Runtime 的配置
- Kubernetes 通过 GPU plugin 实现 GPU 调度支持
- Kubernetes 开启共享 Nvidia GPU 资源配置

<!-- truncate -->

## 前言
Kubernetes 已经成为云原生应用编排和管理的事实标准。在 v1.26 版本 [Scheduling GPUs](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/) 进入 stable 状态，通过 [device plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) 可以让 Pods 可以访问特定硬件如 GPUs。

越来越多的机器学习（ML）和人工智能（AI）领域的开发者希望利用 Kubernetes 平台的优势，来管理 GPU 调度任务。

相比本地 GPU 管理方案，Kubernetes 通过对 GPU 资源的高效分时复用和动态调度，从而降本增效。声明式的容器化配置，使部署过程可以固化和复用，避免了重复配置机器学习环境。同时容器隔离可以避单一进程占用过多共享资源，保障系统稳定性。

尽管本文以 Arch Linux 作为基本环境，但同样适用于其他发行版。

## Nvidia 驱动安装

:::info 参考链接
- [NVIDIA Driver Installation Quickstart Guide](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html)
- 在开始安装 NVIDIA 驱动程序前请参照[《 适用于 Linux 的 CUDA 安装指南》](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions)中的 **2. Pre-installation Actions（预安装操作）** 对环境进行预检查。
:::

### 安装方式
NVIDIA 驱动程序提供三种格式：
- [runfile 安装程序](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#runfile)
  - [NVIDIA Driver Downloads](https://www.nvidia.com/Download/Find.aspx)
  - [Unix Driver Archive](https://www.nvidia.com/en-us/drivers/unix/)
- [包管理器](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#package-manager)
- [容器化驱动程序](https://docs.nvidia.com/datacenter/cloud-native/driver-containers/overview.html)

推荐使用包管理器安装驱动，方便以后的维护和升级。

### 安装示例
以下是在 Arch Linux 上安装 Nvidia 驱动的示例：

[Arch Linux Wiki for NVIDIAN](https://wiki.archlinux.org/title/NVIDIAN#Installation) 介绍了 Arch Linux 官方提供的 Nvidia 驱动包和内核的对应关系，如下所示：

- [nvidia](https://archlinux.org/packages/?name=nvidia) 软件包（用于 [linux](https://archlinux.org/packages/?name=linux)内核 ）
- [nvidia-lts](https://archlinux.org/packages/?name=nvidia-lts) 软件包（用于 [linux-lts](https://archlinux.org/packages/?name=linux-lts)内核 ）
- [nvidia-dkms](https://archlinux.org/packages/?name=nvidia-dkms) 软件包（用于所有其他内核）。

:::tip DKMS 是什么呢？
DKMS（Dynamic Kernel Module Support）是一个框架，用于在Linux系统中构建和安装内核模块。它允许在内核更新时自动重建已注册的内核模块。
:::

下面以我的 Arch Linux 环境为例，我日常使用的内核为 [linux](https://archlinux.org/packages/?name=linux) ，同时也安装了 [linux-lts](https://archlinux.org/packages/?name=linux-lts) 内核作为备用，我想要 Nvidia 驱动在这俩内核中都正常工作，所以需要安装 [nvidia](https://archlinux.org/packages/?name=nvidia) 和 [nvidia-lts](https://archlinux.org/packages/?name=nvidia-lts) 命令如下：

```bash
# 查看显卡
lspci | grep -i nvidia | grep VGA
# 构建工具
sudo pacman -S --needed base-devel
# nvidia 驱动
sudo pacman -S nvidia nvidia-lts
```
其他发行版请参考[安装方式](#安装方式)中提到的 `NVIDIA 驱动程序提供三种格式` 进行安装。

### 驱动验证

完成驱动安装好执行 nvidia-smi 验证是否可用
```bash
❯ nvidia-smi
Wed Aug 16 17:04:35 2023       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.98                 Driver Version: 535.98       CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3080 ...    Off | 00000000:01:00.0 Off |                  N/A |
| N/A   50C    P8              11W / 115W |      8MiB / 16384MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A      1067      G   /usr/bin/gnome-shell                          3MiB |
+---------------------------------------------------------------------------------------+
❯ nvidia-smi --query-gpu=gpu_name --format=csv,noheader
NVIDIA GeForce RTX 3080 Ti Laptop GPU
❯ nvidia-smi -L
GPU 0: NVIDIA GeForce RTX 3080 Ti Laptop GPU (UUID: GPU-1b17e588-c712-9244-37de-93a8a77ebe6d)
```

:::tip 
上述驱动为单卡配置，其他情况请参考以下文档
- 多卡支持 [NVIDIA Multi-Instance GPU User Guide](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html)
- 开启 VGPU 支持 [VGPU](https://www.nvidia.com/en-us/data-center/virtual-solutions/)
- 开启消费级显卡的 vgpu 功能 [vgpu_unlock](https://github.com/DualCoder/vgpu_unlock)
- 更多文档 https://docs.nvidia.com/datacenter/tesla/index.html 
:::

## CUDA 驱动安装
CUDA（Compute Unified Device Architecture）是 NVIDIA 推出的通用并行计算架构，该架构使 GPU 能够解决复杂的计算问题。
:::info 参考链接
- [NVIDIA CUDA Installation Guide for Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
:::
### 安装方式
CUDA 提供了两种安装方式，你可以使用两种不同的安装机制之一来安装 CUDA 工具包：
- [通过包管理器安装](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#package-manager-installation)
- [通过 runfile 安装](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-installation)
- [runfile download](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Rocky&target_version=9&target_type=runfile_local)

### 安装示例
以下是在 Arch Linux 上安装 CUDA 驱动的示例：
```bash
paru -S cuda
```
根据[安装后操作](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions)配置环境变量。

Arch Linux 环境会将 CUDA 相关文件安装至 `/opt/cuda`，将 CUDA 的 PATH 加到 `rc` 中(如~/.bashrc,~/.zshrc)，此路径引永远指向最新版的 CUDA。

```bash
echo 'export CUDA_PATH=/opt/cuda
export PATH=$PATH:/opt/cuda/bin:/opt/cuda/nsight_compute:/opt/cuda/nsight_systems/bin'| sudo tee /etc/profile.d/cuda.sh
source /etc/profile
```

### 驱动验证
输入以下命令来检查 CUDA 版本：
```bash
❯  nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2023 NVIDIA Corporation
Built on Tue_Jun_13_19:16:58_PDT_2023
Cuda compilation tools, release 12.2, V12.2.91
Build cuda_12.2.r12.2/compiler.32965470_0
```
## Container Runtime
这里选符合 oci 标准的运行时，本文选用 contianerd。
<!-- 关于runtime更多信息请参考xxx -->

### Containerd 安装

驱动加载
```bash
# 写入持久化配置
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
# 重载配置使其生效
sudo systemctl restart systemd-modules-load.service
# 或者手动加载
sudo modprobe overlay 
sudo modprobe br_netfilte
```
安装软件包

```bash
paru -S containerd
sudo systemctl enable --now containerd 
```

### Containerd 验证
执行如下命令，进行验证
```bash
sudo ctr image pull docker.io/library/hello-world:latest 
sudo ctr run --rm -t docker.io/library/hello-world:latest hello-world
```

### Nvidia-Container-Runtime 安装
Containerd 默认使用 runc 不支持 GPU 设备，nvidia-container-runtime 是 runc 的修补版本，它添加了自定义 pre-start hook 从而在容器内启用 GPU 支持。  

安装 NVIDIA Container Toolkit 会在 Containerd（或任何其他运行时）周围提供一个shim，用于处理 GPU 请求。需要 GPU 的容器创建由 nvidia-container-runtime 处理。  

当检测到 NVIDIA_VISIBLE_DEVICES 环境变量时，会调用 libnvidia-container 库将 GPU Device 和 CUDA Driver 附加到容器，配置 GPU 访问权限后，NVIDIA 系统会调用常规容器运行时来继续其余的启动过程。如果没有检测到 NVIDIA_VISIBLE_DEVICES 则会执行默认的 runc。

以 NVIDIA 的 GPU 设备为例，运行 GPU 容器后容器内将会出现 GPU 设备和驱动目录：
- GPU 设备，比如 /dev/nvidia0；
- GPU 驱动目录，比如 /usr/local/nvidia/*。

:::info [NVIDIA container stack  架构概述](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/arch-overview.html#arch-overview)
[NVIDIA Container Toolkit](https://gitlab.com/nvidia/container-toolkit/container-toolkit) 是一个容器工具包，它包含了一系列的工具和组件，用于在GPU环境中管理和运行容器化应用程序:
- nvidia-container-runtime  
  NVIDIA公司开发的一种容器运行时，可以用于在GPU环境中运行容器化应用程序。
- NVIDIA 容器运行时挂钩 ( nvidia-container-toolkit/ nvidia-container-runtime-hook)
- NVIDIA 容器库和 CLI ( libnvidia-container1, nvidia-container-cli)
:::

**下面开始安装** NVIDIA 容器运行时
:::info 参考文档
- [nvidia-container-runtime 项目地址](https://github.com/NVIDIA/nvidia-container-runtime/)
- [nvidia-container-runtime 安装文档](https://nvidia.github.io/nvidia-container-runtime/)
- [NVIDIA Container Toolkit 安装指南](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [containerd/issues-4834](https://github.com/containerd/containerd/issues/4834)
:::

使用以下命令将完整的 NVIDIA Container Toolkit 添加到系统中：

NVIDIA 容器运行时依赖于容器映像中现有的 CUDA 库。其他图像仍然可以工作，但它们看不到 GPU 硬件。
```bash
paru -S nvidia-container-runtime nvidia-container-toolkit
```

### 配置 Containerd 使用 Nvidia-Container-Runtime
我们需要在启动 kubelet 之前将 Containerd 默认运行时从 runc 更改为 nvidia-container-runtime 。

生成默认配置文件
```bash
sudo mkdir /etc/containerd
sudo sh -c "containerd config default >  /etc/containerd/config.toml"
```
添加 nvidia 容器运行时，并设为默认

```bash
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      # highlight-next-line
      default_runtime_name = "nvidia"

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        # highlight-start
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
            BinaryName = "/usr/bin/nvidia-container-runtime"
        # highlight-end
```

:::tip
注意要和 kubelet 保持相同的 Cgroup 控制器，这里将 SystemdCgroup`设为`true`。
```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  # highlight-next-line
  SystemdCgroup = true
```
:::

添加完成后重启 containerd 服务
```bash
sudo systemctl restart containerd
```
### Nvidia-Container-Runtime 验证
```bash
sudo ctr images pull docker.io/nvidia/cuda:12.2.0-devel-ubuntu20.04
sudo ctr run --rm -t --gpus 0 docker.io/nvidia/cuda:12.2.0-devel-ubuntu20.04 nvidia-smi nvidia-smi
Thu Aug 24 06:43:06 2023       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.98                 Driver Version: 535.98       CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3080 ...    Off | 00000000:01:00.0 Off |                  N/A |
| N/A   45C    P0              29W / 115W |     10MiB / 16384MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
+---------------------------------------------------------------------------------------+
```

:::tip 多 runtime 配置

如果有多 runtime 共存需求，需要在 Kubernetes 中创建相应的 runtime class。

例如我们想让 containerd 默认 runtime 设置为 runc ，只在使用 GPU 设备时使用 Nvidia-Container-Runtime 该怎么做呢？

首先配置 containerd `[plugins."io.containerd.grpc.v1.cri".containerd]`中 ` default_runtime_name` 设置为 `runc`。

然后 `[plugins."io.containerd.grpc.v1.cri".containerd.runtimes]` 下面多 runtime 配置创建 `runtime class` 资源：
```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: nvidia
handler: nvidia
```
最后在 pod 资源清单中添加 `runtimeClassName: nvidia` 配置即可。
:::

## 在 Kubernetes 中启用 GPU 支持
Kubernetes 通过设备插件（Device Plugins） 以允许 Pod 访问类似 GPU 这类特殊的硬件功能特性。不同厂商提供了不同的 Device Plugin，本小节部署 [NVIDIA/k8s-device-plugin](https://github.com/NVIDIA/k8s-device-plugin) 

来做基本演示。

```bash
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
# 查看日志
kubectl -n kube-system logs -f $(kubectl -n kube-system get pods  -l name=nvidia-device-plugin-ds  -o jsonpath="{.items[*].metadata.name}")

I0822 07:26:02.687308       1 main.go:256] Retreiving plugins.
I0822 07:26:02.687912       1 factory.go:107] Detected NVML platform: found NVML library
I0822 07:26:02.687946       1 factory.go:107] Detected non-Tegra platform: /sys/devices/soc0/family file not found
I0822 07:26:02.698806       1 server.go:165] Starting GRPC server for 'nvidia.com/gpu'
I0822 07:26:02.699008       1 server.go:117] Starting to serve 'nvidia.com/gpu' on /var/lib/kubelet/device-plugins/nvidia-gpu.sock
I0822 07:26:02.700674       1 server.go:125] Registered device plugin for 'nvidia.com/gpu' with Kubelet
```

### 运行 GPU 作业进行验收
部署 nvidia-device-plugin 后，容器现在可以使用 NVIDIA GPU nvidia.com/gpu 类型的 [Extended Resource ](https://kubernetes.io/docs/tasks/administer-cluster/extended-resource-node/)。
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  restartPolicy: Never
  containers:
    - name: cuda-container
      image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda10.2
      resources:
        limits:
          nvidia.com/gpu: 1 # requesting 1 GPU
  tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
EOF
```
查看日志结果
```bash
$ kubectl logs gpu-pod
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
```

:::tip
可以通过 [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html) 可以避免在每个节点上手动安装和配置 nvidia drive 和 nvidia-container-runtime。从而简化 GPU 工作负载的管理和操作。
:::

到此已依照英伟达官方 device plugin 实现了 Kubernetes 集群对 gpu 的支持。

现在每个容器可以请求一个或者多个 GPU，但多容器无法共享一块 GPU ，因为 limit 只能是整数来指定单卡数量，无法请求 GPU 的一小部分，结果是单个容器占用了整个 GPU，导致推理阶段 GPU 利用率极低。

下面我们来看看如何让更多容器可以共享 GPU 来提高利用率。

## GPU 共享的可能性

硬件方案：vGPU 技术可以将显卡资源虚拟化成多块小显卡，会有部分性能损耗。通常需要特定的硬件支持，例如 NVIDIA GRID 卡或 AMD MxGPU 卡，并且需要购买额外的GPU许可证，会增加成本和管理负担。

软件方案：工作负载的调度是在软件层面完成，虽然可以利用整块 GPU 的算力，但无法对工作负载的显存进行限制，这意味着我们需要在代码中进行限制。例如 TensorFlow 允许按照[此处](https://www.tensorflow.org/guide/gpu)的指令限制 GPU 功率。

在机器学习的背景下，训练期间可能会在一项训练作业中利用完整的 GPU 容量，但在推理期间很可能希望在可用的 GPU 上分布多个实例。

下面，我们利用软件层的 GPU 共享，将个工作负载扩展到单个 GPU 上。

:::info 更多共享方案
你可以在下面文章中了解更多的共享方案
- [Time-Slicing GPUs in Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)
- 技术阐述 https://www.arrikto.com/blog/gpu-virtualization-in-k8s-challenges-and-state-of-the-art/
- 技术阐述 https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes/
- https://qiankunli.github.io/2021/08/18/gpu_utilization.html
- https://github.com/volcano-sh/devices
- https://github.com/volcano-sh/volcano/blob/master/docs/user-guide/how_to_use_gpu_sharing.md
- https://zhuanlan.zhihu.com/p/65543866
- https://houmin.cc/posts/cf391335/
- https://xie.infoq.cn/article/32b6e04e53419c35465acc699
:::

## 安装 GPU sharing extension

我们将安装 [阿里 GPU 共享调度扩展](https://github.com/AliyunContainerService/gpushare-scheduler-extender/)和[阿里 GPU 共享设备插件](https://github.com/AliyunContainerService/gpushare-device-plugin)。官方文档可见 [安装指南](https://github.com/AliyunContainerService/gpushare-scheduler-extender/blob/master/docs/install.md)。

### 1. 在控制平面部署GPU共享调度扩展器
```bash
kubectl create -f https://raw.githubusercontent.com/AliyunContainerService/gpushare-scheduler-extender/master/config/gpushare-schd-extender.yaml
```
### 2.修改 kube-scheduler 配置(Kubernetes v1.23+)
添加 lable
```bash
kubectl label node archlinux gpushare=true
kubectl label node archlinux node-role.kubernetes.io/master=
```
配置 kube-scheduler
```bash
cd /etc/kubernetes
sudo curl -O https://raw.githubusercontent.com/AliyunContainerService/gpushare-scheduler-extender/master/config/scheduler-policy-config.yaml
```
编辑 kube-scheduler.yaml
```yaml title="sudo vim manifests/kube-scheduler.yaml"
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --authentication-kubeconfig=/etc/kubernetes/scheduler.conf
    - --authorization-kubeconfig=/etc/kubernetes/scheduler.conf
    - --bind-address=127.0.0.1
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --leader-elect=true
    # highlight-next-line
    - --config=/etc/kubernetes/scheduler-policy-config.yaml
    image: registry.k8s.io/kube-scheduler:v1.28.0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-scheduler
    resources:
      requests:
        cpu: 100m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    # highlight-start
    - mountPath: /etc/kubernetes/scheduler-policy-config.yaml
      name: scheduler-policy-config
      readOnly: true      
    # highlight-end

    - mountPath: /etc/kubernetes/scheduler.conf
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  # highlight-start
  - hostPath:
      path: /etc/kubernetes/scheduler-policy-config.yaml
      type: FileOrCreate
    name: scheduler-policy-config
  # highlight-end
  - hostPath:
      path: /etc/kubernetes/scheduler.conf
      type: FileOrCreate
    name: kubeconfig
status: {}
```

:::tip kubernetes v1.28 scheduler 错误处理
注意在 v1.28 中 KubeSchedulerConfiguration api 版本放生了改变： 
- KubeSchedulerConfiguration: v1beta2 ➜ v1.

> 以下为引用的部分 [CHANGELOG-1.28](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.28.md#api-change)
> 
> kube-scheduler component config (KubeSchedulerConfiguration) kubescheduler.config.k8s.io/v1beta2 is removed in v1.28. Migrate kube-scheduler configuration files to kubescheduler.config.k8s.io/v1. ([#117649](https://github.com/kubernetes/kubernetes/pull/117649), [@SataQiu](https://github.com/SataQiu))

默认情况下你会看到如下报错

```bash
❯ kubectl -n kube-system logs kube-scheduler-archlinux
I0911 07:15:36.217495       1 serving.go:348] Generated self-signed cert in-memory
E0911 07:15:36.217622       1 run.go:74] "command failed" err="no kind \"KubeSchedulerConfiguration\" is registered for version \"kubescheduler.config.k8s.io/v1beta2\" in scheme \"pkg/scheduler/apis/config/scheme/scheme.go:30\"
```
修正 api 版本后重启 kubelet 即可解决
```bash
sudo vim  scheduler-policy-config.yaml
  apiVersion: kubescheduler.config.k8s.io/v1

systemctl restart kubelet.service
```
:::

### 3. 部署设备插件
:::tip
注意：请删除默认的GPU设备插件，例如，如果您使用的是 [nvidia-device-plugin](https://github.com/NVIDIA/k8s-device-plugin)，则可以运行`kubectl delete ds -n kube-system nvidia-device-plugin-daemonset`删除。
:::

```bash
kubectl create -f https://raw.githubusercontent.com/AliyunContainerService/gpushare-device-plugin/master/device-plugin-rbac.yaml
kubectl create -f https://raw.githubusercontent.com/AliyunContainerService/gpushare-device-plugin/master/device-plugin-ds.yaml
```
### 4.为需要GPU共享的节点添加gpushare节点标签
```
kubectl label node archlinux gpushare=true
```

### 5.安装Kubectl扩展
```
cd /usr/bin/
wget https://github.com/AliyunContainerService/gpushare-device-plugin/releases/download/v0.3.0/kubectl-inspect-gpushare
chmod u+x /usr/bin/kubectl-inspect-gpushare
```
当然你也可以使用 [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/) 来安装

device plugin 将公开 GPU 内存容量并跟踪 GPU 内存分配：
```
❯ kubectl describe nodes archlinux|grep Capacity -A 20
Capacity:
  aliyun.com/gpu-count:  1
  aliyun.com/gpu-mem:    16
  cpu:                   20
  ephemeral-storage:     1907216Mi
  hugepages-1Gi:         0
  hugepages-2Mi:         0
  memory:                32518820Ki
  nvidia.com/gpu:        0
  pods:                  110
Allocatable:
  aliyun.com/gpu-count:  1
  aliyun.com/gpu-mem:    16
  cpu:                   20
  ephemeral-storage:     1799874828995
  hugepages-1Gi:         0
  hugepages-2Mi:         0
  memory:                32416420Ki
  nvidia.com/gpu:        0
  pods:                  110
System Info:
```

您可以通过运行 `kubectl inspect gpushare` 来验证 kubectl gpushare 客户端：
目前，集群上没有运行启用 GPU 的工作负载，因此 GPU 内存的分配为 0%。
```
❯ sudo chmod +x /usr/bin/kubectl-inspect-gpushare

❯ sudo ls -l  /usr/bin/kubectl-inspect-gpushare

-rwxr-xr-x 1 root root 37310113 2021年12月 7日 /usr/bin/kubectl-inspect-gpushare
❯ kubectl inspect gpushare
NAME       IPADDRESS      GPU0(Allocated/Total)  GPU Memory(GiB)
archlinux  192.168.8.100  0/16                   0/16
------------------------------------------------------
Allocated/Total GPU Memory In Cluster:
0/16 (0%)  
 /usr/bin 
```


## 共享 GPU 冒烟测试

:::info 测试用例参考
- [测试和调度的完整用例](https://docs.deep-hybrid-datacloud.eu/en/latest/technical/kubernetes/gpu-kubernetes-centos7.html)
- https://blog.ml6.eu/a-guide-to-gpu-sharing-on-top-of-kubernetes-6097935ababf
- https://github.com/NVIDIA/gpu-operator/tree/master/tests
- https://catalog.ngc.nvidia.com/orgs/nvidia/helm-charts/video-analytics-demo
:::

让我们看看如何为特定工作负载请求 GPU 内存：

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-share-pod1
spec:
  restartPolicy: OnFailure
  containers:
    - name: gpu-share-pod1
      image: "docker.io/cheyang/gpu-player:v2"
      env:
        - name: NVIDIA_VISIBLE_DEVICES
          value: "all"
      resources:
        limits:
         aliyun.com/gpu-mem: 3
EOF
```

在检查 GPU 共享指标时，我们可以看到 Pod 已“虚拟”分配了 3 GB 的 VRAM。
```bash
kubectl inspect gpushare
❯ kubectl inspect gpushare
NAME       IPADDRESS      GPU0(Allocated/Total)  GPU Memory(GiB)
archlinux  192.168.8.100  3/16                   3/16
------------------------------------------------------
Allocated/Total GPU Memory In Cluster:
3/16 (18%)  
```
当我们验证 pod 本身的日志时，我们可以看到 TensorFlow 成功找到了 GPU 设备：

我们可以启动另一个工作负载，以确保不同的 pod 可以到达相同的底层 GPU：

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-share-pod2
spec:
  restartPolicy: OnFailure
  containers:
    - name: gpu-share-pod2
      image: "docker.io/cheyang/gpu-player:v2"
      env:
        - name: NVIDIA_VISIBLE_DEVICES
          value: "all"
      resources:
        limits:
         aliyun.com/gpu-mem: 5
EOF
```
应用清单后，我们可以看到可分配内存已成功更新：
```bash
❯ kubectl inspect gpushare
NAME       IPADDRESS      GPU0(Allocated/Total)  GPU Memory(GiB)
archlinux  192.168.8.100  8/16                   8/16
------------------------------------------------------
Allocated/Total GPU Memory In Cluster:
8/16 (50%)  
```

当我们再次查看 pod 的日志时，我们可以看到 TensorFlow 能够看到 GPU 设备，并注意到现在的 freeMemory 不是 11Gig 而是 8Gig：
作为最终测试，我们可以通过 SSH 连接到 GPU 工作节点并检查 GPU 进程：nvidia-msi Nvidia-smi 输出显示两个进程已连接到 GPU

```bash
❯ nvidia-smi
Thu Aug 24 09:46:49 2023       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.98                 Driver Version: 535.98       CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3080 ...    Off | 00000000:01:00.0 Off |                  N/A |
| N/A   51C    P0              31W / 105W |   5226MiB / 16384MiB |      4%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A    267687      G   /usr/lib/Xorg                                 4MiB |
|    0   N/A  N/A    274247      C   python                                     1798MiB |
|    0   N/A  N/A    274573      C   python                                     3410MiB |
+---------------------------------------------------------------------------------------+
```

## 总结
在机器学习的背景下，由于 GPU 设备成本高昂，因此充分利用它们极其重要。特别是在本地环境中，您的机器和 GPU 数量有限，因此能够在不同的工作负载之间共享 GPU 容量非常重要。例如，在训练期间，您可能会在一项训练作业中占用全部 GPU 容量，但在推理期间，您很可能会在可用 GPU 上分布多个实例。

目前，标准 Kubernetes 版本不支持跨 pod 共享 GPU。然而，通过扩展 kubernetes 调度程序模块，我们确认可以实际虚拟化 GPU 内存，就像 Kubernetes 虚拟化工作节点的计算和内存一样。值得注意的是，这种共享机制发生在软件层，并且在 GPU 上运行的工作负载（例如 [TensorFlow 限制_gpu_内存增长](https://www.tensorflow.org/guide/gpu#limiting_gpu_memory_growth)）中也应该正确处理 GPU 隔离。

<!-- ## 扩展阅读
- [Kubernetes-GPU-Guide](https://github.com/Langhalsdino/Kubernetes-GPU-Guide) 
- [第 4 章安装 NVIDIA 驱动程序](https://download.nvidia.com/XFree86/Linux-x86_64/525.85.05/README/installdriver.html)
- [nvidia环境配置](https://ivonblog.com/posts/archlinux-install-nvidia-drivers/#2-%E5%AE%89%E8%A3%9Dcuda)
- [GPU Operator 和k0s 部署](https://www.padok.fr/en/blog/k0s-kubernetes-gpu)
- [ Container Device Interface (CDI) Support 容器设备接口 （CDI） 支持 ](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/cdi.html)


## 容器镜像的使用  
https://earthly.dev/blog/buildingrunning-nvidiacontainer/

NVIDIA 在 Docker Hub 上的 [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda/tags) 标签下提供了一系列预配置的镜像。这些旨在用作可自定义的基础映像，并添加到应用程序中。变体可用于许多不同的架构、操作系统和 CUDA 版本。完整列表可以在 Docker Hub 上查看。
- base 变体是最精简的，包括唯一的 CUDA 运行时。
- runtime 还提供 CUDA 数学库以及对 NVIDIA 集体通信库 (NCCL) 多 GPU 通信的支持。
- devel 添加头文件和开发工具。它旨在供大量定制环境时的高级使用。

该映像需要添加正确的 CUDA 包存储库、安装库，然后设置一些环境变量来向 NVIDIA 容器运行时通告 GPU 支持：
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
如果缺少这些变量，容器运行时将不会附加硬件。


## 变量
###  使用特定 GPU
在主机上运行以下命令以查找要提供给 --gpus 或 NVIDIA_VISIBLE_DEVICES 的 GPU 硬件索引：
nvidia-smi -L
GPU 0: NVIDIA GeForce GTX 1080 Ti (UUID: GPU-5ba4538b-234f-2c18-6a7a-458d0a7fb348)
GPU 1: NVIDIA GeForce GTX 1060 (UUID: GPU-c6dc4e3b-7f0d-4e22-ac41-479ae1c6fbdc)

NVIDIA_VISIBLE_DEVICES=0,1 nvidia/cuda:11.4.0-base-ubuntu20.04 nvidia-smi
设置 --gpus '"device=1"' 或 NVIDIA_VISIBLE_DEVICES=1 将仅使 GTX 1060 可用于容器。

### 自定义驱动程序功能
并非每个应用程序都需要 NVIDIA 驱动程序的所有功能。 NVIDIA_DRIVER_CAPABILITIES [环境变量](https://earthly.dev/blog/bash-variables)仅允许将库的子集安装到容器上。大多数容器化应用程序不会使用 GPU 来渲染图形，因此可以仅过滤 compute (CUDA/OpenCL) 和 utility （nvidia-smi /NVML）功能：
NVIDIA_DRIVER_CAPABILITIES=compute,utility 

## 自动标记

多卡调度
https://aiops.com/news/post/14486.html
，如果用户集群在同一个节点上挂载了多种 GPU，我们该如何实现筛选？如果用户在同一个节点挂载了多个显存不同的 NVIDIA Tesla K80，而且想使用大于 10GiB 显存的 GPU，我们又该怎么办？
Kubernetes 的 Node Label 和 Node Selector 是没法解决这些问题的。

https://github.com/NVIDIA/gpu-feature-discovery/blob/main/README.md#node-feature-discovery-nfd
配置每个 kubelet 以使用 NVIDIA GPU
接下来，配置每个 kubelet 以使用 NVIDIA GPU，如下所示：

  $ KUBELET_OPTS="$KUBELET_OPTS --node-labels='alpha.kubernetes.io/nvidia-gpu-name=$NVIDIA_GPU_NAME'"
 /etc/default/kubelet
    sudo systemctl restart kubelet
       KUBELET_ARGS="--max-pods=50"

--kube-reserved：指定 Kubernetes 系统组件的 CPU 和内存资源的保留量，以确保它们不被其他容器使用。例如：--kube-reserved=cpu=500m,memory=512Mi。
--system-reserved：指定节点系统进程的 CPU 和内存资源的保留量，以确保它们不被其他容器使用。例如：--system-reserved=cpu=500m,memory=512Mi。

例如，要设置 kubelet 的 CPU 余量为 500m，内存余量为 512MiB，请按照以下步骤操作：
KUBELET_ARGS="--kube-reserved=cpu=500m,memory=512Mi --system-reserved=cpu=500m,memory=512Mi"


https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/#node-labeller -->