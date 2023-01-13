---
title: Kubernetes
sidebar_position: 1
tags: [Kubernetes]
---

- https://kubernetes.io/docs/reference/using-api/deprecation-guide/
- https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG

## 相关资料
- [A Walk Through the Kubernetes UI Landscape - Joaquim Rocha, Kinvolk & Henning Jacobs, Zalando SE](https://www.youtube.com/watch?v=lsrB21rjSok&list=PLj6h78yzYM2Pn8RxfLh2qrXBDftr6Qjut&index=136)
- [KubeCon + CloudNativeCon 2022](https://www.youtube.com/playlist?list=PLj6h78yzYM2MCEgkd8zH0vJWF7jdQ-GRR)
- [一文带你检查Kubernetes应用是否为最佳实践](https://juejin.im/post/6844904024911642637)
- [京东云原生之路](https://developer.jdcloud.com/article/1163)
- [京东如何打造K8s全球最大集群支撑万亿电商交易](https://developer.jdcloud.com/article/1160)

## 值得关注的云原生项目

- [openkruise](https://github.com/openkruise/kruise): 阿里开源的一套增强 Kubernetes 功能的系统，对 k8s 的 Deployment/StatefulSet/Job/DaemonSet 均提供了对应的增强版，而且增强的特性很吸引人。

## Kubernetes 控制面板

Kubernetes 有很多的 Web UI 或者本地 UI 组件可供选择：

1. [K9s](https://github.com/derailed/k9s): 本地命令行工具，最好用的命令行 UI 界面，没有之一！
2. [lens](https://github.com/lensapp/lens): 本地工具，UI 设计非常直观，信息也非常丰富，非常受欢迎。
3. [octant](https://github.com/vmware-tanzu/octant): 本地工具，UI 风格跟 Harbor 一脉相承。听说很好用，最大的特点是它的插件系统，可定制性很强。
   1. 它跟 lens 比较类似，而且从 2021 年底开始就不怎么活跃了。
4. [kuboard](https://github.com/eip-work/kuboard-press): 一个很现代化的 Web UI 界面，界面信息非常详细，很适合 Kubernetes 初学者。
5.  [官方 Dashboard](https://github.com/kubernetes/dashboard): 不是很好用，支持的认证方式也很有限，UI 设计也不太友好，直接暴露了一大堆信息。不推荐使用。
7. [scope](https://github.com/weaveworks/scope): 它感觉更多的是个集群拓扑可视化工具，听说拓扑图画得很不错，其他的功能或许有限？
    1.  但是 2020 年开始就不怎么活跃了。
8. [kubesphere](https://github.com/kubesphere/kubesphere): 青云推出的 k8s 集群全家桶，自带 Web UI。值得一试。
9.  其他 rancher/openshift 等 k8s 发行版自带的 UI

## Kubernetes 联调项目
- [zadig](https://github.com/koderover/zadig)
- [virtual-environment](https://alibaba.github.io/virtual-environment/)
- [kt-connect](https://alibaba.github.io/kt-connect/)
- [telepresence](https://github.com/telepresenceio/telepresence): 通过 proxy 将你的本机加入到 kubernetes 虚拟网络中，方便本地开发与调试微服务。但是本地环境跟容器环境仍然存在差异，这是它的问题所在。
- [nocalhost](https://github.com/nocalhost/nocalhost): 它比 telepresence 更进一步，只在本地 IDE (JetBrains/VSCode)里编写代码，然后直接同步到 Kubernetes 的容器中运行，容器由项目的 Dockerfile 构建（会自动修改 entrypoint）
- [eclipse/che](https://github.com/eclipse/che): 比 nocalhost 更进一步，直接把 IDE 也整进了 Kubernetes 容器，che 底层使用 theia 作为它的 Web IDE。它可以自动为每个用户按需创建 Workspace，通过 PV 为用户持久化数据。