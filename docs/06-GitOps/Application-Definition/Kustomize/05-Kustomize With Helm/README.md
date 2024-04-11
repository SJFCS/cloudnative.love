---
title: Kustomize With Helm
---
Helm Chart 模板变量的值通过 Values 文件来控制，我们无法修改未公开的值，若需要进行自定义通常要 fork 上游的 Helm Chart 仓库，然后进行改动，这样做会带来额外的负担。这时候我们可以使用 Kustomize 在 patches 阶段使用标准 Kustomize 补丁覆盖 Helm Chart 中 hardcoded 部分的值。

kustomize 提供了两种方法：
- helmCharts 内置字段
- HelmChartInflationGenerator 插件

## helmCharts
这是 Kustomize 的内置功能，允许用户在 kustomization.yaml 文件中直接定义 Helm chart 的配置。这种方式简单直接，易于理解，适合于需要对 Helm chart 进行简单配置，且不需要复杂自定义行为的场景。

```yaml title: "base/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1bata1
kind: Kustomization
helmCharts:
- name: example
  releaseName: my-example
  version: "1.2.3" # 可选，指定 chart 版本
  repo: https://charts.example.com/ # 可选，指定 chart 仓库
  valuesMerge: override
  valuesFile: base-values.yaml # 基础 values 文件
  # Inline
  valuesInline:
    key1: value1
    key2: value2
  # Values files:
  valuesFile: values.yaml
  additionalValuesFiles:
  - values-file-1.yml
  - values-file-2.yml
```


## 实践案例1

```yaml

这是我用于 grafana-agent 的一个示例
假设您的基础文件夹values.yaml位于基础文件夹中，其中包含所有所需的默认值。
base/values.yaml

agent:
  resources: 
    requests:
      cpu: "150m"
      memory: "256Mi"
    limits: 
      cpu: "200m"
      memory: "1Gi"
overlays/dev/kustomization.yaml

helmCharts:
  - name: grafana-agent
    version: 0.27.2
    repo: https://grafana.github.io/helm-charts
    releaseName: grafana-agent
    namespace: grafana
    includeCRDs: false
    valuesFile: ../../base/values.yaml
    valuesMerge: override # how to treat valuesInline with respect to Values. Legal values: ‘merge’, ‘override’, ‘replace’. Defaults to ‘override’.
    valuesInline:
      agent:
        resources: 
          requests:
            # cpu: "150m" # Will inherit from base
            memory: "2Gi" # Will override
          limits: 
            # cpu: "200m"  # Will inherit from base
            memory: "3Gi" # Will override


现在您可以构建，但请确保禁用负载限制器

kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone > manifests.yaml

additionalValuesFiles??
```



## HelmChartInflationGenerator

- https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#_helmchartinflationgenerator_
- https://medium.com/@brent.gruber77/the-power-of-kustomize-and-helm-5773d0f4d95e

HelmChartInflationGenerator是一个Kustomize的生成器插件，用于从Helm chart生成Kubernetes资源。这个插件通过解析helmCharts字段中的配置来工作。

步骤 1: 创建base配置
```yaml
---
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
generators:
  - helmchart.yaml
---
# base/helmchart.yaml
apiVersion: kustomize.config.k8s.io/v1
kind: HelmChartInflationGenerator
metadata:
  name: mychart
helmCharts:
  - name: mychart
    releaseName: my-release
    repo: https://example.com/charts
    version: 1.0.0
    namespace: default
    valuesFile: values.yaml
---
# base/values.yaml
replicaCount: 2
service:
  type: ClusterIP
```
步骤 2: 创建 overlay 配置
```yaml
---
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
generators:
  - helmchart.yaml
resources:
  - ../../base
---
# overlays/prod/prod-values.yaml
replicaCount: 5
service:
  type: LoadBalancer
---
# overlays/prod/helmchart.yaml
apiVersion: kustomize.config.k8s.io/v1
kind: HelmChartInflationGenerator
metadata:
  name: mychart
helmCharts:
  - name: mychart
    releaseName: my-production-release
    repo: https://example.com/charts
    version: 1.0.0
    namespace: prod
    valuesFile: prod-values.yaml
```
步骤 3: 应用配置
在你的命令行中，切换到 overlays/prod 目录并运行：kustomize build .




## 参考

- https://github.com/kubernetes-sigs/kustomize/blob/master/api/types/helmchartargs.go
- https://github.com/kubernetes-sigs/kustomize/blob/master/examples/chart.md
- https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#_helmchartinflationgenerator_
- https://www.qikqiak.com/post/use-kustomize-custom-helm-charts/
- 您可以在 Kustomize 中内联或通过文件定义 Helm valuse。这些值将覆盖 Helm 图表的默认值，就像您在 Kustomize 之外使用 Helm 所做的那样。[文档](https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#_helmchartinflationgenerator_)
- kustomize v5 添加了字段 [additionalValuesFiles](https://stackoverflow.com/questions/76640403/kustomize-override-values-in-dependency-charts) ，可以覆盖 helm 值。
- “浅合并shallow merge”的工作方式是，如果您有一个map（dict），它将合并来自values.yaml 和任何后续值的值。但是，如果您有一个list，它将覆盖该列表，无法合并列表。

## 讨论
- 如何使用叠加层正确覆盖 helmChart 值？ https://github.com/kubernetes-sigs/kustomize/issues/4658
## 例子
- https://github.com/HariSekhon/Kubernetes-configs/blob/master/cluster-autoscaler/base/kustomization.yaml
- [通过 Kustomize 呈现 Helm 图表](https://cloud.google.com/anthos-config-management/docs/concepts/kustomize?hl=zh-cn)