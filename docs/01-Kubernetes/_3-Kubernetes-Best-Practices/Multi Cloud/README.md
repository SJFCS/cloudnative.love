---
title: Multi Cloud
---

随着云计算的发展，为了避免被云服务商绑定（vendor lock-in）从而提高企业的议价能力，也为了提升服务的可用性（更多 Region/Zones），企业对多云的需求越来越强烈。

社区的一些解决方案：
- [karmada](https://github.com/karmada-io/karmada): 跨集群做实例调度(资源管理)、服务发现 + L4/L7 负载均衡。
  - 通过 ClusterPropagationPolicy 提供跨集群的 L4 负载均衡能力
  - 通过 MultiClusterIngress 提供 L7 负载均衡能力
- [kubevela](https://github.com/kubevela/kubevela): 基于 K8s 的应用平台，支持多集群/多云。
  - 支持基于各种标签、名称的资源跨集群调度，但是不负责解决服务发现、跨集群网络、跨集群负载均衡等问题。
- Istio 跨集群的服务网格，支持对不同的 Region/Zone 设定不同的流量权重，比如强制所有流量都仅转发同一可用区内的其他实例。
- [virtual-kubelet](https://virtual-kubelet.io/) 虚拟kubelet节点，可对接外部容器资源池
- [Cilium Cluster Mesh](https://docs.cilium.io/en/v1.11/gettingstarted/clustermesh/clustermesh/)：支持打通集群间的 Pod-to-Pod 网络
- [cluster-api](https://github.com/kubernetes-sigs/cluster-api): 以声明的方式在各云平台/裸机上部署或更新 Kubernetes 集群，确保多集群的配置一致性，也降低集群的维护难度。

<!-- ## 多云管理的挑战
- 集群间的资源不平衡
- 跨集群访问困难
- 运维与管理成本高
- 多集群如何实现集群间的 fail-over？假设其中一个集群挂了，能否快速恢复或者隔离问题集群？
  
- FinOps: 多云成本分析、管控与优化
- 多云网络与 API 网关搭建
  - 多云网络：使用第三方多云解决方案，最好是开源的
  - 基于 DNS + 开源 API Gateway + Istio 多集群服务网格实现多云流量分发
- 跨云应用的发布更新、实例调度、监控、告警、日志、链路追踪
  - 可能的方案：借助 Kubernetes 与其他云原生解决方案实现，比如多集群管理工具 karmada
- 多云的资源管理：从 SRE 角度看借助 terraform/pulumi 来管理多云资源是个不错的方案
- 多云的权限统一管理：基本都是 RBAC，也可以考虑直接使用 terraform/pulumi 来管理 -->

## 推荐阅读

- [Kubernetes 多集群项目介绍](https://xinzhao.me/posts/kubernetes-multi-cluster-projects/)
- [Kubernetes、集群联邦和资源分发](https://draveness.me/kuberentes-federation/)
- [Kubernetes Everywhere: Lessons Learned From Going Multi-Cloud - Niko Smeds, Grafana Labs](https://www.youtube.com/watch?v=ZY5h8Atc14A)

- https://github.com/topics/multicloud
- [基于Kubernetes的多云和混合云](https://mp.weixin.qq.com/s/uM4d3_fwLIdQ95fBWcmRjw)
- [大规模集群的注意事项](https://kubernetes.io/zh-cn/docs/setup/best-practices/cluster-large/)
- [多集群网络kube-ovn](https://github.com/kubeovn/kube-ovn/wiki/%E5%A4%9A%E9%9B%86%E7%BE%A4%E7%BD%91%E7%BB%9C)
- [认识一下 Kubernetes 多集群服务 API](https://atbug.com/kubernetes-multi-cluster-api/)
- [kubevela](https://kubevela.io/)
- [Admiralty](https://github.com/admiraltyio/admiralty) 
- [ k8s多集群的思考](https://www.huweihuang.com/kubernetes-notes/multi-cluster/k8s-multi-cluster-thinking.html)
- [liqo 启用动态和无缝的 KUBERNETES 多集群拓扑](https://liqo.io/)
- [自适应边缘和分布式系统的连接技术](https://nats.io/)