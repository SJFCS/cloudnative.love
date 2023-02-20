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
