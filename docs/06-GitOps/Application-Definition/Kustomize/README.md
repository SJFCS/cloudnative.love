# Kustomize Tutorial

Kustomize 通过 path 的方式对 k8s yaml 文件进行修补，相比 helm 更灵活学习成本低，适合频繁变动的服务清单。

## 应用场景

在深入了解 Kustomize 之前，我们先了解一下使用 Kubernetes 清单部署应用程序的问题。

假设您想要将应用程序部署到 Kubernetes，并且您有多个环境，在每个环境中，您可能有不同的部署配置。

例如，在 dev 和 uat 中您可能不需要滚动更新，但在 prod 中您可能需要它。此外，您可能需要在每个环境中使用不同的副本、不同的 CPU 和内存资源、注释等。不仅如此，应用程序可以通过 Configmap 和 Secrets 使用针对每个环境而变化的属性。

因此，您需要自定义部署以满足相应环境的要求。

解决此问题的简单方法是创建三个单独的目录，每个环境一个目录，并将所有 Kubernetes 清单添加到各自的文件夹中。

但这不是一个可扩展的解决方案。因为当新应用程序上线或添加新配置文件时，手动管理文件夹中的所有 YAML 文件将变得很困难。这也可能导致配置漂移问题。

您可以创建脚本来替换 YAML 中的配置，但当您有许多服务时，这不是一个好方法。

所有这些问题都可以使用 Kustomize 解决。

## 扩展阅读

- [Kustomize Tutorial](https://www.densify.com/kubernetes-tools/kustomize/)
- https://kubectl.docs.kubernetes.io/references/
- https://kubectl.docs.kubernetes.io/guides/
- https://www.innoq.com/en/blog/2022/07/advanced-kustomize-features/
- [安全问题](https://stackoverflow.com/questions/71758834/kustomize-how-to-cause-a-generator-to-actually-merge-an-object-instead-of-dupli)

