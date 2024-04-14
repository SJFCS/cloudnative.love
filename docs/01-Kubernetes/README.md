---
title: Kubernetes
sidebar_position: 0
tags: [Kubernetes]
---

## 推荐阅读
- [KubeCon + CloudNativeCon North America 2020 - Virtua](https://www.youtube.com/playlist?list=PLj6h78yzYM2Pn8RxfLh2qrXBDftr6Qjut)
- [KubeCon + CloudNativeCon Europe 2022](https://www.youtube.com/playlist?list=PLj6h78yzYM2MCEgkd8zH0vJWF7jdQ-GRR)

## 值得关注的云原生项目
- openkruise  
  阿里开源的一套增强 Kubernetes 功能的系统，对 k8s 的 Deployment/StatefulSet/Job/DaemonSet 均提供了对应的增强版，而且增强的特性很吸引人。
- karmada  
  多云管理平台，支持跨多个 Kubernetes 集群和云运行云原生应用程序
- virtual kubelet  
  可借助 Fargate 等资源池轻松扩展您的应用程序，而无须担心配置足够的计算资源，在流量突发的业务场景下削峰填谷效果明显。
- kubevela  
  现代化应用交付与管理平台，定义了 [Open Application Model [OAM]](https://oam.dev/) 模型，支持跨混合环境。
<!-- - https://admiralty.io/ -->

## Kubernetes 联调项目

- [zadig](https://github.com/koderover/zadig)
- [virtual-environment](https://alibaba.github.io/virtual-environment/)
- [kt-connect](https://alibaba.github.io/kt-connect/)
- [telepresence](https://github.com/telepresenceio/telepresence)  
  通过 proxy 将你的本机加入到 kubernetes 虚拟网络中，方便本地开发与调试微服务。但是本地环境跟容器环境仍然存在差异。
- [nocalhost](https://github.com/nocalhost/nocalhost)  
  它比 telepresence 更进一步，只在本地 IDE (JetBrains/VSCode)里编写代码，然后直接同步到 Kubernetes 的容器中运行，容器由项目的 Dockerfile 构建（会自动修改 entrypoint）
- [eclipse/che](https://github.com/eclipse/che)  
  它比 nocalhost 更进一步，直接把 IDE 也整进了 Kubernetes 容器，che 底层使用 theia 作为它的 Web IDE。它可以自动为每个用户按需创建 Workspace，通过 PV 为用户持久化数据。

## Kubernetes 控制面板

Kubernetes 有很多的 Web UI 或者本地 UI 组件可供选择：

1. [K9s](https://github.com/derailed/k9s): 本地命令行工具，最好用的命令行 UI 界面，没有之一！
2. [lens](https://github.com/lensapp/lens): 本地工具，UI 设计非常直观，信息也非常丰富，非常受欢迎。
3. [kubesphere](https://github.com/kubesphere/kubesphere): 青云推出的 k8s 集群全家桶，自带 Web UI。值得一试。
4. 其他 rancher/openshift 等 k8s 发行版自带的 UI


