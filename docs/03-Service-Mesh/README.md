---
title: Service Mesh
sidebar_position: 0
---

## 服务网格

对比详见：[Service Mesh Comparison](https://servicemesh.es/)

1. [istio](https://github.com/istio/istio)
2. [linkerd2](https://github.com/linkerd/linkerd2)
3. [consul](https://github.com/hashicorp/consul)

- 如果选择 envoy 阵营，目前不二选择就是 istio.  
- 追求轻量化和性能，目前最佳的选择应该也只有 linkerd2.  
- 未来更有潜力的方向是基于 ebpf 的内核级Service Mesh，如 Cilium Service Mesh 


## 性能对比

### 1. [Istio 1.8.3 - 1.11.4](https://istio.io/v1.11/docs/ops/deployment/performance-and-scalability/)

The Istio load tests mesh consists of **1000 services and 2000 sidecars with 70,000 mesh-wide requests per second**. After running the tests using Istio 1.11.4, we get the following results:

- The Envoy proxy uses **0.35 vCPU** and **40 MB** memory per **1000 requests per second** going through the proxy.
- Istiod uses **1 vCPU** and **1.5 GB** of memory.
- The Envoy proxy adds **2.65 ms** to the **90th percentile latency**.

### 2. [Linkerd2](https://linkerd.io/2021/05/27/linkerd-vs-istio-benchmarks/)


linkerd2-proxy 相比 envoy，只用了 1/9 的内存与 1/8 的 CPU，同时 P99 延迟只有 envoy 的 1/3 不到.

## 现状分析

envoy虽然轻量且性能好，但过于简陋：
  - slow_start 还没支持，对缓存有依赖的服务扩容不太平滑
  - 不支持限流限并发，这个感觉在网格内还是有需要的，如果有微服务发疯，能起到隔离的作用...
  - 不处理南北向的网关流量，认证授权、rewrite，这些都建议在 Gateway 上搞

关于sidercar：
  - Sidecar 模式的性能损耗和资源占用叫道，所以现在也有一些 **Node 模式**部署的尝试，traefik mesh 就是 Node 模式，dapr 也支持 node 模式。
  - linkerd2 走的路则是做**轻量的 sidecar**，并且使用 rust 这类高效语言来实现。
  - Cilium 则将目标聚焦在「eBPF」上，实现**内核级别**的服务网格，并通过 Envoy 支持 Node 模式的 Proxy 以支持 mTLS 等更高级的能力。
不过我们现在也看到了 dapr 这样更通用的 multi-runtime 产品，以及 Proxyless Service Mesh.

对于java：  
- Netflix已经宣布对Hystrix停止更新。  
- [sentinel](https://github.com/alibaba/Sentinel)在18年开源了，在不断的发展，并且进入serviceMesh和云原生方向挺近。整体上sentinel功能更强。  
- 参考：https://sentinelguard.io/zh-cn/blog/sentinel-vs-hystrix.html

:::info sentinel和istio中的服务限流是什么关系？
都可以实现限流和熔断，区别是：  
sentinel和hytrix 代码有侵入性可以控制到具体的方法。  
istio则是为服务创建sidecar,主动劫持服务的入和出口流量；不侵入代码，但是粒度比较粗：只能针对整个java服务配置连接池和实例驱逐策略。
:::



## 其他资料
- [使用 Istio 进行 JWT 身份验证（充当 API 网关）](https://thiscute.world/posts/use-istio-for-jwt-auth/)
- [API Gateway vs Service Mesh](https://www.cnblogs.com/kirito-c/p/12394038.html)
- [告别 Sidecar—— 使用 EBPF 解锁内核级服务网格](https://mp.weixin.qq.com/s/nUCiC8_Yr9EplFk8uTgQpA)
- [Proxyless Service Mesh在百度的实践与思考](https://mp.weixin.qq.com/s/8T7XI6jQfZunwVYDaDHvLw)
- [Slime：让Istio服务网格变得更加高效与智能](https://cloudnative.to/blog/netease-slime/)
- [基于 Apache APISIX 的下一代微服务架构](https://www.upyun.com/tech/article/512/%E5%9F%BA%E4%BA%8E%20Apache%20APISIX%20%E7%9A%84%E4%B8%8B%E4%B8%80%E4%BB%A3%E5%BE%AE%E6%9C%8D%E5%8A%A1%E6%9E%B6%E6%9E%84.html)
- [Service Mesh Comparison](https://servicemesh.es/)
