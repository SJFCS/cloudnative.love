---
title: Transformers
---

使用Transformers。我们可以转换基本 Kubernetes YAML 配置。Kustomize 常见内置 transformers 如下。

## 常用字段解释
这是一个示例 kustomization.yaml 文件。不用担心所有配置。我们将在以下部分中了解所有字段。
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

commonLabels:
  env: dev

namespace: dev
namePrefix: dev-

commonAnnotations:
  armsPilotAutoEnable: "on"
  armsPilotCreateAppName: matrix-dev

resources:
- ../../base

components:
  - ../../components/non-prod

patchesStrategicMerge:
- deployment.yml
- settings.yml

images:
  - name: postgres
    newName: my-registry/my-postgres
    newTag: v1
  - name: nginx
    newTag: 1.8.0
  - name: my-demo-app
    newName: my-app
  - name: alpine
    digest: sha256:25a0d4
```

- commonLabel 为所有Kubernetes资源添加标签
- namePrefix 它为所有资源添加一个公共前缀
- nameSuffix 它为所有资源添加一个公共后缀
- Namespace 为所有资源添加一个公共命名空间
- commonAnnotations 为所有资源添加注释
- Image 它允许我们修改特定部署将要使用的映像。
- Resources 段引入原始的Kubernetes资源文件。
- patches 指定一个或多个补丁文件，这些补丁文件会修改通过 resources 或 components 引入的原始资源。
- PatchesStrategicMerge patchesStrategicMerge 是 patches 的一种特殊类型，专门用于Strategic Merge Patch。Strategic Merge Patch是一种合并策略，它能够智能地合并特定的Kubernetes资源定义字段。
- ConfigMapGenerator和SecretGenerator: 用于生成 Secret和ConfigMap
- Components 允许你重用和组合其他Kustomization。通过使用components，你可以重用通用的配置片段，并将它们组合成更复杂的部署。-
- Variables 和 replacements 允许用户在Kustomize配置中重用信息

## 推荐阅读
- https://github.com/kubernetes-sigs/kustomize/blob/master/examples/transformerconfigs/README.md
