---
title: GitOps Security Tools
---
## External Secrets
- https://colinwilson.uk/articles/
- [Secrets Management with External Secrets, Argo CD and GitOps](https://colinwilson.uk/2022/08/22/secrets-management-with-external-secrets-argo-cd-and-gitops/)
## SOPS
- https://medium.com/picus-security-engineering/manage-your-secrets-with-mozilla-sops-and-gitops-toolkit-flux-cd-v2-7aa98f626001
- https://majinghe.github.io/cloud-native/argocd-kustomize-sops/
- https://community.ops.io/jilgue/secrets-in-argocd-with-sops-pa6



argocd-vault-plugin使用资源注释来查找和更新清单，而不需要CRD或oprater

GitOps 中我很少听说的一个大话题是正确的 GitOps 秘密管理。我通常会看到 Bitnami Sealed Secrets 的标准化使用，但意识到我还没有看到太多使用 HashiCorp Vault 的情况。本演讲将探讨结合使用 HashiCorp Vault 和 ArgoCD、任何优点和缺点，以及最终对我有用的方法。

- 各种加密工具的对比讨论 https://github.com/argoproj-labs/argocd-vault-plugin/issues/289
- [通过Sidecar将Vault Secret注入Kubernetes Pod](https://www.hashicorp.com/blog/injecting-vault-secrets-into-kubernetes-pods-via-a-sidecar)


- [Secret Management](https://argo-cd.readthedocs.io/en/stable/operator-manual/secret-management/)

- [how-to-manage-kubernetes-secrets-gitops](https://akuity.io/blog/how-to-manage-kubernetes-secrets-gitops/)


## 与 helm-secrets 和 sops 的比较
Sealed Secrets 的一个流行替代品是 [helm-secrets](https://github.com/zendesk/helm-secrets)，它使用 [sops](https://github.com/mozilla/sops) 作为后端。
- Sealed Secrets 在  server-side 解密secret资源
- Helm-secrets 在 client-side 解密secret资源

使用 helm-secret 进行客户端解密可能会带来安全风险，因为客户端（如 CI/CD 系统）需要有权访问加密密钥才能执行部署。请注意，如果您使用 GitOps 工具（如 Argo CD 或 Flux），这不是问题。



通过 Sealed Secrets 和服务器端解密(server-side decryption)，我们可以避免这种安全风险。加密密钥仅存在于 Kubernetes 集群中，永远不会公开。

> Sealed Secrets 无法使用 AWS KMS 等云 KMS 解决方案。如果这是必需的，那么请使用 sops/helm-secrets。


Sealed-secrets：Sealed-secrets 的工作方式是将加密后的 Kubernetes Secrets 存储在 Git 存储库中。这些密文 Secrets 被称为 SealedSecrets，它们可以安全地存储在版本控制系统中。在部署到 Kubernetes 集群时，Sealed-secrets 控制器会将 SealedSecrets 解密为普通的 Kubernetes Secrets，以供应用程序使用。

External-secrets：External-secrets 是用于从外部的安全存储中提取敏感信息的 Kubernetes 控制器。它允许您将敏感数据存储在外部的安全存储中（如 AWS Secrets Manager），然后在 Kubernetes 中引用这些数据，以便在部署时将其注入到应用程序中。

ArgoCD Vault Plugin：ArgoCD Vault Plugin 允许您在 ArgoCD 部署过程中使用 HashiCorp Vault 中的机密信息。通过在 Kubernetes 资源中使用注解和占位符，ArgoCD Vault Plugin 可以在部署时将密文数据动态注入到应用程序中。

Sops 是什么
