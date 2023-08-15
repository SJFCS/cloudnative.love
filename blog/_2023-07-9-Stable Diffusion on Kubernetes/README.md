https://wiki.archlinux.org/title/Kubernetes

https://www.kubernetes.org.cn/6574.html
https://docs.nvidia.com/datacenter/cloud-native/kubernetes/latest/index.html
https://github.com/Langhalsdino/Kubernetes-GPU-Guide
https://docs.bitnami.com/tutorials/using-gpus-with-kubernetes

https://dnaeon.github.io/install-and-configure-k8s-on-arch-linux/

## ai
http://github.com/amithkk/stable-diffusion-k8s
https://cloud-atlas.readthedocs.io/zh_CN/latest/machine_learning/stable_diffusion/stable_diffusion_on_k8s.html

https://github.com/NVIDIA/nvidia-container-runtime/
https://github.com/NVIDIA/k8s-device-plugin
# 前言
本文能带来什么？
containerd 为什么
archlinux 但也是用于其他系统
用到gpu on k8s。为什么不用本地 要使用k8s呢，好处
显卡虚拟化 有哪些方案呢，vgpu
最终选型原因和结果呢

# gpu on k8s
## 搭建本地k8s集群
## 配置k8s集群ingress和storage和lb等
## 配置nvidia和CUDA驱动
## 配置nvidia-container-runtime
# sd with helm
## 制作Stable Diffusion镜像，编写helm
## 部署验证
Kubernetes 管理 GPU 能带来什么好处呢？

本质上是成本和效率的考虑。

加速部署：通过容器构想避免重复部署机器学习复杂环境；将整个部署过程进行固化和复用
提升集群资源使用率：统一调度和分配集群资源；
保障资源独享：利用容器隔离异构设备，避免互相影响。

通过分时复用，来提升 GPU 的使用效率。当 GPU 的卡数达到一定数量后，就需要用到 Kubernetes 的统一调度能力，使得资源使用方能够做到用即申请、完即释放，从而盘活整个 GPU 的资源池。

而此时还需要通过 Docker 自带的设备隔离能力，避免不同应用的进程运行同一个设备上，造成互相影响。在高效低成本的同时，也保障了系统的稳定性。