---
title: Observability
sidebar_position: 0
tags: [Observability]
---

https://grafana.com/solutions/

云原生下 Telemetry（遥测）有如下三种手段去观察一个云服务：
1. Metrics（指标）：即监控指标，主要使用 Prometheus 采集，通过 Grafana 进行可视化。
   - 集群本身也会使用一些指标进行自动伸缩、判断服务、节点是否处于异常状态等。
2. Logging（日志）：这是传统应用最重要的问题排查方式，但是在云原生场景下，日志需要被收集，统一处理。
   - 通过 EFK 等系统，可以对数据进行各种高级的分析：搜索、聚类、特征提取等
3. Tracing（链路追踪）：微服务架构下问题排查的必要功能，目前最流行的是 Jaeger.
## 参考
- [可观察性 - Observability](https://en.wikipedia.org/wiki/Observability)
- [OpenTelemetry Agent and Collector: Telemetry Built-in Into All Service - Steve Flanders & Trask Stalnaker](https://www.youtube.com/watch?v=cHiFSprUqa0&list=PLj6h78yzYM2O1wlsM-Ma-RYhfT5LKq0XC&index=88)

