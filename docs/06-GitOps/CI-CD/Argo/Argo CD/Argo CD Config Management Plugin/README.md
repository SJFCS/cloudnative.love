ArgoArgo CD 允许使用配置管理插件集成更多配置管理工具。配置新插件需要进行以下更改：
- 历史版本：https://argo-cd.readthedocs.io/en/release-2.3/user-guide/config-management-plugins/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/
- https://codefresh.io/blog/using-argo-cds-new-config-management-plugins-to-build-kustomize-helm-and-more/

-   在 ConfigMap 中注册一个新插件`argocd-cm`：
-   确保`argocd-repo-server`pod 中提供所需的二进制文件。可以通过卷挂载或使用自定义映像添加二进制文件（请参阅[custom_tools](https://argo-cd.readthedocs.io/en/release-2.0/operator-manual/custom_tools/)）。


该`generate`命令必须将有效的 YAML 流打印到标准输出。`init`和命令都`generate`在应用程序源目录内执行。

-   创建应用程序并指定所需的配置管理插件名称。



命令可以访问:

1.  系统环境变量
2.  [标准构建环境](https://argo-cd.readthedocs.io/en/release-2.0/user-guide/build-environment/)
    - ARGOCD_APP_NAME- 应用程序名称
    - ARGOCD_APP_NAMESPACE- 目标应用程序命名空间。
    - ARGOCD_APP_REVISION- 已解决的修订版，例如f913b6cbf58aa5ae5ca1f8a2b149477aebcbd9d8
    - ARGOCD_APP_SOURCE_PATH- 应用程序在存储库中的路径
    - ARGOCD_APP_SOURCE_REPO_URL存储库的 URL
    - ARGOCD_APP_SOURCE_TARGET_REVISION- 规范的目标修订版，例如master。
    - KUBE_VERSION- Kubernetes 的版本
    - KUBE_API_VERSIONS= kubernetes API 的版本
3.  应用程序规范中的变量：
```text
spec:
  source:
    plugin:
      env:
        - name: FOO
          value: bar
```
## 确保`argocd-repo-server`pod 中提供所需的二进制文件
### 通过卷挂载添加工具¶

第一种技术是使用init容器和将volumeMount工具的不同版本复制到存储库服务器容器中。在以下示例中，init 容器使用与 Argo CD 中捆绑的版本不同的版本覆盖 helm 二进制文件：


```
    spec:
      # 1. Define an emptyDir volume which will hold the custom binaries
      volumes:
      - name: custom-tools
        emptyDir: {}
      # 2. Use an init container to download/copy custom binaries into the emptyDir
      initContainers:
      - name: download-tools
        image: alpine:3.8
        command: [sh, -c]
        args:
        - wget -qO- https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz | tar -xvzf - &&
          mv linux-amd64/helm /custom-tools/
        volumeMounts:
        - mountPath: /custom-tools
          name: custom-tools
      # 3. Volume mount the custom binary to the bin directory (overriding the existing version)
      containers:
      - name: argocd-repo-server
        volumeMounts:
        - mountPath: /usr/local/bin/helm
          name: custom-tools
          subPath: helm
```
### BYOI（建立您自己的镜像）¶

有时替换二进制文件还不够，您需要安装其他依赖项。以下示例从 Dockerfile 构建完全自定义的存储库服务器，安装生成清单可能需要的额外依赖项。

```yaml
FROM argoproj/argocd:latest

# Switch to root for the ability to perform install
USER root

# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests 
# (e.g. curl, awscli, gpg, sops)
RUN apt-get update && \
    apt-get install -y \
        curl \
        awscli \
        gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux && \
    chmod +x /usr/local/bin/sops

# Switch back to non-root user
USER argocd
```


然后执行以下命令更新 argocd-repo-server 部署：

```text
argocd app create <appName> --config-management-plugin <pluginName>
```

更多配置管理插件示例可在[argocd-example-apps](https://github.com/argoproj/argocd-example-apps/tree/master/plugins)中找到。




从 Argo CD 2.4 开始，通过 configmap 创建配置管理插件或 CMP 已被弃用，[在 Argo CD 2.8 中完全移除了支持](https://github.com/argoproj/argo-cd/issues/15152)。虽然许多人一直在使用自己的配置管理插件来执行诸如`kustomize –enable-helm`或指定特定版本的 Helm 等操作，但大多数人似乎直到现在才注意到旧的方法已被移除！

## Argo CD 中的 CMPs 如何工作
CMP 系统通过向`argocd-repo-server`添加一个任意的容器边车，并传入配置并挂载 CMP 服务器服务来工作。使用 repo-server 检出仓库，然后将其挂载到 CMP 边车中以进行渲染。您创建的任何 CMP 最终都将有一个任务，即渲染出 Argo CD 可以应用的清单。这非常容易设置！

