---
title: Promethuse Recording Rules 优化实践
tags: [Kubernetes,Promethuse]
---

<!-- https://deploy.live/blog/today-i-learned-prometheus-recording-rules/
https://www.cnblogs.com/east4ming/p/16902293.html
https://preliminary.istio.io/latest/zh/docs/ops/best-practices/observability/
https://help.aliyun.com/document_detail/356529.html
https://segmentfault.com/a/1190000023533570
https://zhuanlan.zhihu.com/p/89092641
https://gurumee92.tistory.com/256
https://faun.pub/how-to-drop-and-delete-metrics-in-prometheus-7f5e6911fb33

https://awesome-prometheus-alerts.grep.to/ -->
![1673346836560](image/README/1673346836560.png)

随着时间的推移，Prometheus 中存储的指标数量越来越多，查询的频率也越来越高。随着越来越多的仪表板被添加到 Grafana，我开始遇到 Grafana 无法按时呈现图形和 Prometheus 查询超时的情况。这非常烦人。我需要一种更好的方法来修复 Prometheus 查询超时，尤其是在长时间聚合大量指标时。

本文用到了 Prometheus Recording Rule 实现对高维度指标查询的 PromQL 语句的性能优化，提高查询效率。
<!-- truncate -->
## 规则的语法检查
要在不启动 Prometheus 服务器的情况下快速检查规则文件的语法是否正确，请安装并运行 promtool 。

```bash
go get github.com/prometheus/prometheus/cmd/promtool
promtool check rules /path/to/example.rules.yml
# 如果文件语法正确，检查器将解析的规则作为文本打印到标准输出，并以返回码 0 退出。
# 如果存在任何语法错误或输入参数无效，则将错误消息打印到标准错误并以返回码 1 退出。
```

## Recording rules

Recording rules 允许您预先计算经常需要或计算量大的表达式，并将结果保存为新的时间序列。对预先计算的结果进行查询通常比每次需要时都执行原始表达式要快得多。这对于每次刷新时需要重复查询相同表达式的仪表板特别有用。

一个简单的示例规则文件可能如下所示：

```yaml title="alerting_rules.yml"
groups:
  - name: example
    rules:
    - record: job:http_inprogress_requests:sum
      expr: sum(http_inprogress_requests) by (job)
```
例如我们把下面 Grafana 中的规则改为 Recording rules
```yaml
sum (rate (container_network_receive_bytes_total[5m]))by (node)
sum (rate (container_network_transmit_bytes_total[5m])) by (node)
sum (rate (wmi_container_network_receive_bytes_total[5m]))by (node)
sum (rate (wmi_container_network_transmit_bytes_total[5m]))by (node)
```
编写对应的 prometheus rule 配置文件
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  generation: 1
  labels:
    app: exporter-kubernetes
    chart: exporter-kubernetes-0.0.1
    heritage: Tiller
    io.cattle.field/appId: cluster-monitoring
    release: cluster-monitoring
    source: rancher-monitoring
  name: custom
  namespace: cattle-prometheus
spec:
  groups:
  - name: network_IO
    rules:
    - record: custom_container_network_receive_bytes_total
      expr: sum (rate (container_network_receive_bytes_total[5m]))by (node)
    - record: custom_container_network_transmit_bytes_total
      expr: sum (rate (container_network_transmit_bytes_total[5m])) by (node)
    - record: custom_wmi_container_network_receive_bytes_total
      expr: sum (rate (wmi_container_network_receive_bytes_total[5m]))by (node)
    - record: custom_wmi_container_network_transmit_bytes_total
      expr: sum (rate (wmi_container_network_transmit_bytes_total[5m]))by (node)
```

## 案例问题

比如我们想要了解 Kubernetes 节点之间 CPU 和内存的实际利用率，我们可以通过使用 `container_cpu_usage_seconds_total` 和 `container_memory_usage_bytes` 这两个指标来查询 CPU 和内存的利用率。因为每个运行中的容器都会收集这两个指标进行，但是需要知道，对于稍微大点的线上环境，可能我们同时运行着成千上万的容器，比如现在我们以每5分钟的频率去查询下一周内数千个容器的数据的时候，Prometheus 就比较难以快速进行数据查询了。

比如我们用 `container_cpu_usage_seconds_total` 总数除以 `kube_node_status_allocatable_cpu_cores` 总数得出 CPU 利用率：
```go
sum(rate(container_cpu_usage_seconds_total[5m])) / avg_over_time(sum(kube_node_status_allocatable_cpu_cores)[5m:5m])
Load time: 15723ms
```
使用 `avg_over_time` 将 `container_memory_usage_bytes` 总数除以 `kube_node_status_allocatable_memory_bytes` 总数来计算内存利用率：
```go
avg_over_time(sum(container_memory_usage_bytes)[15m:15m]) / avg_over_time(sum(kube_node_status_allocatable_memory_bytes)[5m:5m])
Load time: 18656ms
```

## 优化方案

[Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)允 许您基于其他时间序列创建自定义的元时间序列。如果您是 Prometheus Operator 用户——您可能已经在 Prometheus 中运行了大量此类规则。

```yaml
groups:
  - name: k8s.rules
    rules:
    - expr: |
        sum(rate(container_cpu_usage_seconds_total{job="kubelet", image!="", container_name!=""}[5m])) by (namespace)
      record: namespace:container_cpu_usage_seconds_total:sum_rate
    - expr: |
        sum(container_memory_usage_bytes{job="kubelet", image!="", container_name!=""}) by (namespace)
      record: namespace:container_memory_usage_bytes:sum
```

上面的两个规则完全符合我在查询中所做的，但它们会连续执行并将结果存储在非常小的时间序列中。`sum(rate(container_cpu_usage_seconds_total{job="kubelet", image!="", container_name!=""}[5m])) by (namespace)` 将以预定义的时间间隔进行评估，并存储为新的度量标准 `namespace:container_cpu_usage_seconds_total:sum_rate` ，与内存查询相同。

现在我可以将我的查询更改为如下所示：将 `container_cpu_usage_seconds_total` 总数除以 `kube_node_status_allocatable_cpu_cores` 总数计算得出 CPU 利用率：

```go
sum(namespace:container_cpu_usage_seconds_total:sum_rate) / avg_over_time(sum(kube_node_status_allocatable_cpu_cores)[5m:5m])
Load time: 1077ms
```
现在运行速度提高了14倍！

将查询更改为如下 `container_memory_usage_bytes` 总数除以 `kube_node_status_allocatable_memory_bytes` 总数来计算内存利用率：

```go
sum(namespace:container_memory_usage_bytes:sum) / avg_over_time(sum(kube_node_status_allocatable_memory_bytes)[5m:5m])
Load time: 677ms
```
现在运行速度提高了27倍！

## 参考文档

[Today I Learned: Prometheus Recording Rules](https://deploy.live/blog/today-i-learned-prometheus-recording-rules/)
