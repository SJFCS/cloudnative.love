---
title: Replacement
---
Kustomize中的variables（变量）和replacements（替换）功能都允许用户在Kustomize配置中重用信息。

自Kustomize 3.2.0起，vars 特性已经被标记为已弃用，并且在未来的版本中将被移除。推荐的方法是使用新的 replacements 特性，它提供了更为强大和灵活的替换机制，对于长期维护的项目，迁移到replacements是个明智的选择。

## 替换特定字符串

replacements 字段，用于在处理资源时替换特定字符串。下面是一个简单的示例：
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

replacements:
- path: deployment.yaml
  target:
    kind: Deployment
  replacements:
  - target: name
    replacement: myapp
```
在这个示例中，replacements 字段指定了要替换的内容。该示例指定了一个名为 deployment.yaml 的文件，并在其中找到 kind 为 Deployment 的资源。然后，它指定要替换的目标是该资源中的 name 字段，并将其替换为 myapp。

## 变量的重用和替换
使用 replacements 来实现重用变量的方法很简单。您可以定义一个包含要重用的值的文件，然后在需要的地方通过 replacements 来引用这些值。这样一来，您可以在整个 Kustomization 文件中重复使用这些值，实现类似于 vars 的效果。

下面是一个示例，演示如何使用 replacements 来实现重用变量：

假设您有一个名为 common-vars.yaml 的文件，其中包含一些常见变量的定义：
```yaml
commonVars:
  namespace: my-namespace
  app: my-app
```
然后，在您的 Kustomization 文件中，您可以通过 replacements 来引用这些变量：

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

replacements:
- path: deployment.yaml
  target:
    kind: Deployment
  replacements:
  - target: spec.template.spec.containers.[name=my-container].image
    replacement: myregistry/{{.commonVars.app}}:latest
  - target: metadata.namespace
    replacement: {{.commonVars.namespace}}
```
在这个示例中，我们在 deployment.yaml 文件中使用了 commonVars 文件中定义的变量。通过这种方式，您可以在 Kustomize 中实现变量的重用，而无需依赖于即将被废弃的 vars 机制。


Kustomize团队推荐使用replacements，因为它提供了更大的灵活性和强大的功能。特别是对于新项目，建议直接使用replacements。


## 推荐阅读
- [vars](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/vars/)
- [Replacement](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/replacements/)
- https://github.com/kubernetes-sigs/kustomize/issues/4701
- https://github.com/jlandowner/kustomize-ingress/blob/main/replacements/kustomization.yaml
- https://stackoverflow.com/questions/76712848/use-kustomize-replacements-to-replace-values-in-one-base-with-values-from-anothe
- https://stackoverflow.com/questions/68322864/kustomize-how-to-target-replacement-in-every-array