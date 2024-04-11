可以通过更新 Argo CD Configmap 在全局范围内完成
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  kustomize.buildOptions: --enable-helm
```

从[文档](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize)中了解有关在 Argo CD 中自定义 Kustomize 的更多信息。

