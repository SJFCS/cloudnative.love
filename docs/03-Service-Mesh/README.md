---
title: Service Mesh
sidebar_position: 0
---

## 服务网格

对比详见：[Service Mesh Comparison](https://servicemesh.es/)

1. [istio](https://github.com/istio/istio)
2. [linkerd2](https://github.com/linkerd/linkerd2)
3. [consul](https://github.com/hashicorp/consul)
4. [cilium](https://github.com/cilium/cilium)
5. [dapr](https://github.com/dapr/dapr)

对于 java：

- Netflix 已经宣布对 Hystrix 停止更新。
- [sentinel](https://github.com/alibaba/Sentinel)在 18 年开源了，在不断的发展，并且进入 serviceMesh 和云原生方向挺近。整体上 sentinel 功能更强。
- 参考：https://sentinelguard.io/zh-cn/blog/sentinel-vs-hystrix.html

:::info sentinel 和 istio 中的服务限流是什么关系？
都可以实现限流和熔断，区别是：  
sentinel 和 hytrix 代码有侵入性可以控制到具体的方法。  
istio 则是为服务创建 sidecar,主动劫持服务的入和出口流量；不侵入代码，但是粒度比较粗：只能针对整个 java 服务配置连接池和实例驱逐策略。
:::

## 其他资料

- [使用 Istio 进行 JWT 身份验证（充当 API 网关）](https://thiscute.world/posts/use-istio-for-jwt-auth/)
- [API Gateway vs Service Mesh](https://www.cnblogs.com/kirito-c/p/12394038.html)
- [告别 Sidecar—— 使用 EBPF 解锁内核级服务网格](https://mp.weixin.qq.com/s/nUCiC8_Yr9EplFk8uTgQpA)
- [Proxyless Service Mesh 在百度的实践与思考](https://mp.weixin.qq.com/s/8T7XI6jQfZunwVYDaDHvLw)
- [Slime：让 Istio 服务网格变得更加高效与智能](https://cloudnative.to/blog/netease-slime/)
- [基于 Apache APISIX 的下一代微服务架构](https://www.upyun.com/tech/article/512/%E5%9F%BA%E4%BA%8E%20Apache%20APISIX%20%E7%9A%84%E4%B8%8B%E4%B8%80%E4%BB%A3%E5%BE%AE%E6%9C%8D%E5%8A%A1%E6%9E%B6%E6%9E%84.html)
- [Service Mesh Comparison](https://servicemesh.es/)
