---
title: Components
---
Kustomize 有两个关键概念：Base 和 Overlays。借助 Kustomize，我们可以在所有环境中重用base文件（通用 YAML），并为每个 overlay 环境添加补丁。

base目录保存所有环境通用的配置。通常不会经常改变，如果想同时对多个环境进行更改或在环境之间具有共同的特性，最好使用"components"。

对于复杂的多环境管理和最佳实践请阅读以下链接：
- [如何建模你的GitOps环境并在它们之间促进发布](https://codefresh.io/blog/how-to-model-your-gitops-environments-and-promote-releases-between-them/)
- [停止使用分支部署到不同的GitOps环境](https://codefresh.io/blog/stop-using-branches-deploying-different-gitops-environments/)
- https://github.com/argoproj/argo-cd/issues/7119
- https://github.com/argoproj/argocd-example-apps/issues/57
- https://github.com/kostis-codefresh/gitops-environment-promotion



