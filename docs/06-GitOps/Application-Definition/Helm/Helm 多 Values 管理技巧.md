---
title: Helm 多 Values 管理技巧
---
Helm 支持多个值文件，但当指定多个值文件时，它会自动对这些值文件进行浅层合并。某些情况下，可能根本不需要 Kustomize。下面是一个例子。

- 技巧的第一部分是使用子图表 sub-charts......
```yaml
# requirements.yaml
dependencies:
- name: volume-autoscaler
  version: 1.0.5
  repository: "https://devops-nirvana.s3.amazonaws.com/helm-charts/"
```
然后指定应用于所有环境的“全局”设置...

```yaml title="values.yaml"
volume-autoscaler:
  slack_webhook_url: "https://hooks.slack.com/services/1234/123/1234"
  slack_channel: "INTENTIONALLY-INVALID-WILL-OVERRIDE-IN-ENV-VALUES-FILES"
  resources:
    limits:
      cpu: 20m
      memory: 75Mi
    requests:
      cpu: 20m
      memory: 75Mi
```
然后你在 values-env 文件中进行覆盖...

```yaml title="values-stage.yaml"
volume-autoscaler:
  slack_channel: "devops-stage"
```
argocd之类的cd工具可能不支持这个，但可以将此逻辑放到 CI/CD 中，并在 Helm Chart 的文件夹中添加一个自述文件，以便人们知道如何使用包含两个值文件的特定命令。命令示例是如下

```yaml
# First download dependency (subchart)
helm dependencies update volume-autoscaler
# Then helm diff with multiple values to check what will change (YOU should ALWAYS diff before applying)
helm diff upgrade --namespace infrastructure --allow-unreleased volume-autoscaler ./volume-autoscaler -f volume-autoscaler/values.yaml -f volume-autoscaler/values-stage.yaml
# And finally helm upgrade
helm upgrade --install --namespace infrastructure volume-autoscaler ./volume-autoscaler -f volume-autoscaler/values.yaml -f volume-autoscaler/values-stage.yaml
```
