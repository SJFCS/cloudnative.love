# Pod 自动伸缩

Kubernetes 集群的水平伸缩 HPA 所使用的指标，主要有如下几个方案：

- [metrics-server](https://github.com/kubernetes-sigs/metrics-server): 仅提供了 cpu/memory 两个指标
- [prometheus-adapter](https://github.com/kubernetes-sigs/prometheus-adapter): 使用 prometheus 中的 metrics 定义自定义指标用于 HPA
  - 它实现了 custom metrics api，因此支持 Pod/Object 两种指标类型，这些指标是直接与 K8s Pod/Object 相关的，可以从 namespace/pod_name 等纬度查询这些指标
- [keda](https://github.com/kedacore/keda): 一个 Kubernetes 弹性伸缩控制器，支持从多种数据源（prometheus/mysql/postgresql/NATS/kafka...）获取指标进行弹性伸缩。
  - keda 实现了 external metrics api，这主要是与 K8s Object 无关的指标，不要求提供 Pod/Namespace 等参数

如果你只需要从 Prometheus 指标进行弹性伸缩，prometheus-adapter 或者 keda 都能满足你的需求。

KEDA 比 prometheus-adapter 强的地方在于，它支持从多种事件来源获取数据，而且支持缩容到零。
它的这些特性使 KEDA 被 kubevela 用做底层的自动伸缩组件，knative 对它的支持也正在路上。


## 参考

- [Pod 水平自动伸缩 - Kubernetes Docs](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Horizontal Pod Autoscaler演练 - Kubernetes Docs](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)