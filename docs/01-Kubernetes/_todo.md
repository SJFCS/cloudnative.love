---
title: Kubernetes
sidebar_position: 0
tags: [Kubernetes]
---

 Kubernetes OPS Guide
  - https://github.com/yangpeng14/DevOps/tree/master
  - https://github.com/chaseSpace/k8s-tutorial-cn?tab=readme-ov-file
  - udemy-CKS   https://www.udemy.com/course/certified-kubernetes-security-specialist/
  - udemy-CKA   https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/
  - udemy-CKAD  https://www.udemy.com/course/certified-kubernetes-application-developer/
  - 慕课-Kubernetes https://coding.imooc.com/learn/list/335.html
  - 腾讯课堂-Kubernetes         https://ke.qq.com/user/index/index.html#/plan/cid=2738602&term_id=103659045
  - 极客时间-深入剖析 Kubernetes-张磊 https://time.geekbang.org/column/article/71606?cid=100015201

## Kubernetes进阶
- k8s进阶主题分享：多租户 多云 安全策略等
- k8s-DEV & SouceCodeAnalysis文档撰写 
- 自己写容器调度器和CNI 准入控制器
- 多云混部管理系统，跨云跨区核心链路跨云高可用，包括差异化调度， 资源隔离， 资源驱逐流程等功能
- 基于业务平台与 VirtualKubelet,以及调度控制器，实现**面向多云和混合云和多云资源交付平台和能力；**
  - https://kubevela.io/
  - https://openkruise.io/zh/
- 本地联调，网络拉平

优点知识-Kubernetes 开发课 https://youdianzhishi.com/web/course/1018/2014


实现**Kubernetes集群的灰度版本升级**，极端故障场景的快速恢复等等。
### 多云集群管理
多租户，网络拉平
- kubefed, karmada, virtual kubelet，kubevela,admiralty，kubeedge等
- https://github.com/istio/istio/issues/24488
- https://istio.io/latest/docs/ops/deployment/deployment-models/
- https://draveness.me/kuberentes-federation/
- [自定义k8s调度器](https://www.qikqiak.com/post/custom-kube-scheduler/)
- [编写自定义的 Kubernetes scheduler调度器](https://zhuanlan.zhihu.com/p/428124949)
- [配置多个调度器](https://kubernetes.io/zh-cn/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

### Kubernetes 开发
- [ ] CSI, CNI, CRD和Operator开发
  -   https://github.com/dnsjia/luban
  -  https://github.com/kubernetes/sample-controller
  -  https://www.bilibili.com/video/BV1FW4y1m7qH
  -  https://www.bilibili.com/video/BV1Gb4y177WE
  -  https://juejin.cn/post/7028453607850655758
  -  https://juejin.cn/post/7029132894291361829
  -  其他课程
  -  https://bilibili.com/video/BV1zu41197br
  -  [云原生CTO](https://space.bilibili.com/436169885/video)
  -  https://www.bilibili.com/video/BV18U4y1S78Q
  -  https://www.bilibili.com/video/BV1oL411F7hN

- [ ] K8S API SERVER原理
  - https://www.bilibili.com/video/BV13A4y1R7RH/
  - https://github.com/duyanghao/kubernetes-reading-notes/tree/master/core/api-server
  - https://www.huweihuang.com/kubernetes-notes/principle/kubernetes-core-principle-api-server.html#1-api-server%E7%AE%80%E4%BB%8B

- [ ] kube-scheduler 调度分析
  - https://jeffdingzone.com/2020/11/k8s%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%902kube-scheduler/
  - https://www.cnblogs.com/lianngkyle/p/15914981.html
  - https://www.cnblogs.com/lianngkyle/p/16000742.html

- [ ] golang 实现docker
- https://juejin.cn/post/6844903493916950536
- https://bingbig.github.io/topics/container/content.html
- https://github.com/Akshit8/my-docker
- https://github.com/pibigstar/go-docker   https://learnku.com/blog/pibigstar
- https://github.com/lizrice/containers-from-scratch
- https://segmentfault.com/a/1190000008125359
- https://github.com/songjiayang/climits








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