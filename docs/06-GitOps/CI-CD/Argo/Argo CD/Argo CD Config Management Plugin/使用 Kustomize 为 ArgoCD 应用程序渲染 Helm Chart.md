使用Kustomize渲染Helm图表时需要将 --enable-helm 标志传递给 kustomize build 。此标志不是Argo CD中的Kustomize选项的一部分。如果你想在Argo CD应用程序中通过Kustomize渲染Helm cHART，你有两个选择：你可以创建一个[自定义插件](https://argo-cd.readthedocs.io/en/stable/user-guide/config-management-plugins/)，或者修改 [argocd-cm ConfigMap](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/#kustomize-build-optionsparameters)以在所有Kustomize应用程序中全局包含 --enable-helm 标志。

### 方法1：添加全局选项
我们可以告诉Kustomize使用--enable-helm标志来渲染舵图。为了使用ArgoCD以同样的方式呈现它，我们必须创建一个具有此标志的插件。

```yaml 
apiVersion: v1
kind: ConfigMap
metadata:
    name: argocd-cm
    namespace: argocd
data:
    kustomize.buildOptions: --load-restrictor LoadRestrictionsNone --enable-helm
```

### 方法2：创建一个插件
更为标准的做法是，要创建一个插件，ArgoCD的argocd-cm ConfigMap 添加configManagementPlugins。

在本例中，我们将使用kustomize build --enable-helm：

```yamlm
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
data:
  configManagementPlugins: |
    - name: kustomize-enable-helm
      generate:
        command: [ "sh", "-c" ]
        args: [ "kustomize build --enable-helm" ]
```

然后，我们必须更新Application中的密钥spec.source.plugin.name，提供我们刚刚在argocd-cm定义中定义的插件名称：
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-with-kustomize-enable-helm
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
(...)
  source:
    plugin:
      name: kustomize-enable-helm
(...)
```


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kustomize-build-with-helm
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: kustomize-build-with-helm
    spec:
      generate:
        command: [ "sh", "-c" ]
        args: [ "kustomize build --enable-helm" ]
```

```yaml
containers:
- name: kustomize-build-with-helm
  command: [/var/run/argocd/argocd-cmp-server] # Entrypoint should be Argo CD lightweight CMP server i.e. argocd-cmp-server
  # image: busybox # This can be off-the-shelf or custom-built image
  image: alpine/k8s:1.26.8
  securityContext:
    runAsNonRoot: true
    runAsUser: 999
  volumeMounts:
    - mountPath: /var/run/argocd
      name: var-files
    - mountPath: /home/argocd/cmp-server/plugins
      name: plugins
    # Remove this volumeMount if you've chosen to bake the config file into the sidecar image.
    - mountPath: /home/argocd/cmp-server/config/plugin.yaml
      subPath: plugin.yaml
      name: kustomize-build-with-helm
    # Starting with v2.4, do NOT mount the same tmp volume as the repo-server container. The filesystem separation helps 
    # mitigate path traversal attacks.
    - mountPath: /tmp
      name: cmp-tmp
volumes:
- configMap:
    name: kustomize-build-with-helm
  name: kustomize-build-with-helm
- emptyDir: {}
  name: cmp-tmp
```

## ref：
- https://pet2cattle.com/2023/01/argocd-kustomize-enable-helm
- https://github.com/argoproj/argo-cd/issues/7835
- https://github.com/argoproj/argocd-example-apps/tree/master/plugins/kustomized-helm
- https://codefresh.io/blog/using-argo-cds-new-config-management-plugins-to-build-kustomize-helm-and-more/
- https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/
https://argo-cd.readthedocs.io/en/stable/user-guide/compare-options/
- https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/
https://argo-cd.readthedocs.io/en/stable/user-guide/compare-options/


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kustomize-build-with-helm
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: kustomize-build-with-helm
    spec:
      generate:
        command: [ "sh", "-c" ]
        args: [ "kustomize build --enable-helm" ]
```


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-repo-server
spec:
  template:
    spec:
      containers:
      - name: kustomize-build-with-helm
        command: [/var/run/argocd/argocd-cmp-server] # Entrypoint should be Argo CD lightweight CMP server i.e. argocd-cmp-server
        # image: busybox # This can be off-the-shelf or custom-built image
        image: alpine/k8s:1.26.8
        securityContext:
          runAsNonRoot: true
          runAsUser: 999
        volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          # Remove this volumeMount if you've chosen to bake the config file into the sidecar image.
          - mountPath: /home/argocd/cmp-server/config/plugin.yaml
            subPath: plugin.yaml
            name: kustomize-build-with-helm
          # Starting with v2.4, do NOT mount the same tmp volume as the repo-server container. The filesystem separation helps 
          # mitigate path traversal attacks.
          - mountPath: /tmp
            name: cmp-tmp
      volumes:
      - configMap:
          name: kustomize-build-with-helm
        name: kustomize-build-with-helm
      - emptyDir: {}
        name: cmp-tmp
```


```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
- github.com/argoproj-labs/argocd-autopilot/manifests/base?ref=v0.4.15
- kustomize-with-helm.yaml # Adds our configmap
patches:
- path: kustomize-with-helm.sidecar.yaml # Adds the sidecar to argocd-repo-server
```

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    name: ''
    namespace: example
    server: 'https://kubernetes.default.svc'
  source:
    path: user/manifests/app-name/env-name/
    repoURL: 'https://github.com/todaywasawesome/your-repo-here'
    targetRevision: HEAD
    plugin: 
      name: kustomize-build-with-helm
  project: elite-cluster
  syncPolicy:
    automated: null
```







## 使用 Helm 支持启用 Kustomize，无需 CMP 插件

从文档中了解有关 [在 Argo CD 中自定义 Kustomize](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize) 的更多信息。


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
或者通过更新单个的 Argo CD 应用程序。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
spec:
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: kustomize-guestbook

    kustomize:
      buildOptions: --enable-helm
```