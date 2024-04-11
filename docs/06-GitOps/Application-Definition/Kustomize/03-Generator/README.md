---
title: Generators
---
Kustomize 提供了一些资源生成器 Generators ：

- configMapGenerator and MapGenerator
- secretGenerator

## ConfigMapsGenerator
从存储在 .properties 文件中的预设值生成 ConfigMap。可以使用下面的 kustomization.yaml 文件来执行此操作。

```yaml title="kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
configMapGenerator:
- name: my-application-properties
  files:
  - application.properties
```

```yaml title="application.properties"
FOO=Bar
```

我们得到一个生成的 ConfigMap YAML作为输出：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-application-properties-f7mm6mhf59
data:
  application.properties: |-
        FOO=Bar
```

也可以使用 literals 的方式生成 ConfigMap
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
configMapGenerator:
- name: my-configmap
  literals: 
  - foo=bar
  - baz=qux
```

## secretGenerator

参数列表中的每个条目都会创建一个Secret资源。

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
secretGenerator:
- name: app-tls
  files:
  - secret/tls.crt
  - secret/tls.key
  type: "kubernetes.io/tls"
- name: app-tls-namespaced
  namespace: apps
  files:
  - tls.crt=catsecret/tls.crt
  - tls.key=secret/tls.key
  type: "kubernetes.io/tls"
- name: env_file_secret
  envs:
  - env.txt
  type: Opaque
- name: secret-with-annotation
  files:
  - app-config.yaml
  type: Opaque
  options:
    annotations:
      app_config: "true"
    labels:
      app.kubernetes.io/name: "app2"
```

## generatorOptions

在 Kustomize 中，一些资源生成器（如 SecretGenerator 和 ConfigMapGenerator）默认会在生成的资源名称后添加一个随机后缀。这个随机后缀的目的是为了确保每次生成的资源是唯一的，以避免在多次应用配置时由于资源内容的更改而未能更新现有资源的问题。然而，在某些情况下，我们可能不希望有这样的随机后缀，希望保持资源名称的稳定性。

```yaml
generatorOptions:
 disableNameSuffixHash: true  #关闭哈希后缀
 labels:
   kustomize.generated.resource: somevalue
 annotations:
   annotations.only.for.generated: othervalue 
```

## 推荐阅读
- https://github.com/kubernetes-sigs/kustomize/blob/master/examples/generatorOptions.md
- https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/secretgenerator/
- https://devopscube.com/kuztomize-configmap-generators/
- [configMapGenerator 配置映射生成器](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/configmapgenerator/)
- [disable hash suffix for generated](https://github.com/kubernetes-sigs/kustomize/issues/50)
- https://stackoverflow.com/questions/67100693/kustomize-suffix-hashes-on-only-certain-items
- https://github.com/kubernetes-sigs/kustomize/issues/1301
- [behavior](https://juejin.cn/post/7212143399037829157)