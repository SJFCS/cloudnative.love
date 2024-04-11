
ApplicationSet https://www.redhat.com/en/blog/getting-started-with-applicationsets
## 顺序
通常是在 Argo CD 中通过定义应用程序依赖性来实现，而不是 ApplicationSet。这可以通过在 Argo CD 的 Application 资源中使用 sync-wave 注解来做。
例如，如果你有两个应用程序，一个数据库db和一个依赖该数据库的web应用程序webapp，你可以在它们的Application定义中这样设置：

```bash
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: db
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  # ...
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: webapp
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  # ...
```


