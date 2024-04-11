---
title: patches
---
kustomization.yaml 有两种方法可以定义修补程序：

- JSON 6902 
- [Stragetic Merge Patching](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md). 策略合并修补。


###  JSON 6902 Patching

通过这种方式，我们必须提供 target和patch details。

下面是内联策略合并修补的示例。
```yaml
patches:
  - target:
      kind: Deployment
      name: web-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```

### Stragetic Merge Patching 策略合并修补
通过这种方式，可使用原生的清单文件格式进行patch，我们只是添加需要修改的字段。

注意patch的 yaml 文件中的资源名，要跟模版清单一致。

下面是内联策略合并修补的示例。

```yaml
patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: web-deployment
      spec:
        replicas: 5
```

## 建议使用 patch file 而不是 inline
对于这两种类型的修补程序，我们可以使用单独的文件方法，而不是内联文件。在一个YAML文件中指定所有补丁细节，并将其引用到patches指令下的 kustomization.yaml 文件。

例如，在 kustomization.yaml 中，您需要如下所述提及补丁文件。您需要指定YAML文件的相对路径。

```yaml
patches:
- path: replicas.yaml
```
我们可以将这些变化放在下面的 replicas.yaml 中。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 5
```

## target

我们可以使用 target 灵活的去匹配需要patch的资源
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
patches:
- path: patch.yaml
  target:
    group: apps
    version: v1
    kind: Deployment
    name: deploy.*
    labelSelector: "env=dev"
    annotationSelector: "zone=west"
- patch: |-
    - op: replace
      path: /some/existing/path
      value: new value
  target:
    name: name*
    kind: Deployment
    labelSelector: "env=dev"
    annotationSelector: app=hello
    labelSelector: app=hello
```


## 推荐阅读
- https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md



