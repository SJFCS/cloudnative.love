---
title: Security
sidebar_position: 9
tags: [Security]
---
- https://zhuanlan.zhihu.com/p/639899593?utm_psn=1657168588703227904&utm_id=0
1. Trivy, 操作系统层面漏洞检测的扫描工具
2. Clair,容器漏洞静态扫描工具
3. Kube-bench, 这个工具可以判断Kubernetes是否得到了最优部署
4. kubeaudit, 一个针对常见安全控制，对Kubernetes Deplyment 进行安全审计的工具
5. Kubescape, 一个检查Kubernetes是否按照主要的合规框架部署的工具
6. kube-hunter, 发现并利用漏洞的渗透测试工具
7. Sysdig Falco, Kubernetes集群风险和威胁检测的运行时安全解决方案


[validkube](https://github.com/komodorio/validkube)

[为什么 RBAC 不足以保障 Kubernetes 的安全？](https://zhuanlan.zhihu.com/p/339078684)

[checkov](https://github.com/bridgecrewio/checkov)

[docker-bench-security](https://github.com/docker/docker-bench-security)

[kube-bench](https://github.com/aquasecurity/kube-bench/tree/main)

[Kubernetes Pod 安全策略(PSP)配置](https://www.qikqiak.com/post/setup-psp-in-k8s/)

[Kubesec](https://kubesec.io/)

[Martin White - 通过 CIS 基准实现一致的安全控制](https://www.youtube.com/watch?v=53-v3stlnCo)

[OpenSCA](https://github.com/XmirrorSecurity/OpenSCA-cli)


开发者也在容器领域进行着安全探索，在未来我们会看到更多的在运行时安全 (Runtime Security) 的研究。
Istio ([https://github.com/istio/istio](https://link.zhihu.com/?target=https%3A//github.com/istio/istio)) 和 Falco ([https://github.com/falcosecurity/falco](https://link.zhihu.com/?target=https%3A//github.com/falcosecurity/falco)) 都在这些方面做了努力。同时，在容器镜像安全（Container Image Security）方面，人们也在不断地取得成绩，例如Trivy ([https://github.com/aquasecurity/trivy](https://link.zhihu.com/?target=https%3A//github.com/aquasecurity/trivy)) 和 Notary ([https://github.com/notaryproject/notary](https://link.zhihu.com/?target=https%3A//github.com/notaryproject/notary)) 等项目。


https://github.com/neargle/my-re0-k8s-security

https://blog.fleeto.us/post/intro-trivy-operator/

- https://morioh.com/p/e487ada70ff7
- https://developer.aliyun.com/article/777094
- https://xujiwei.com/blog/2020/02/internal-authorize-based-on-dingtalk-virtual-ldap-keyclaok/?spm=a2c6h.12873639.article-detail.5.319e23a032NdXL
- [CNCF Landscape Security&Compliance](https://landscape.cncf.io/card-mode?category=security-compliance&grouping=category)
- [cis-benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [GCP-cis-benchmarks](https://cloud.google.com/kubernetes-engine/docs/concepts/cis-benchmarks)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [9 Kubernetes security best practices everyone must follow](https://www.cncf.io/blog/2019/01/14/9-kubernetes-security-best-practices-everyone-must-follow/)


## Key Management
kubernetes 原生 secrets 内容由 base64 编码 并不安全，即使可以通过[静态加密 Secret 数据](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/encrypt-data/)来避免ETCD侧数据泄漏，但在gitops场景下，想要保管好机密数据还需要用到如 `hashicorp vault` 这样的第三方密钥管理工具和 `cert-manager` 专门管理 tls 证书的工具。

## 容器权限策略

1. [Pod SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
2. seccomp: security compute mode

### 集群全局的 Pod 安全策略

Pod SecurityContext 只能为每个 Pod 单独配置安全策略。为了保证安全性，我们显然还希望定制集群粒度的最小安全策略，禁止所有不符合此策略的 Pod 被提交运行。

- [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) 控制集群中 Pod 安全相关的限制。
  - [ PSP 已在 kubernetes 1.21 被标记为废弃，并将在 1.25 中被彻底删除](https://github.com/kubernetes/kubernetes/pull/97171)。
- [open-policy-agent/gatekeeper](https://github.com/open-policy-agent/gatekeeper)
- [kyverno](https://github.com/kyverno/kyverno)

## 二、容器运行时安全检测

### 1. [falco](https://github.com/falcosecurity/falco)

利用 Sysdig 的 Linux 内核指令和系统调用分析，Falco 能够深入理解系统行为。它的运行时规则引擎能够检测应用、容器、主机以及 Kubernetes 的反常行为。

凭借 Falco，在每个 Kubernetes 节点部署一个代理，无需修改或者注入第三方代码或者加入 Sidecar 容器，就能够得到完整的运行时可见性以及威胁检测。

## 三、安全审计/扫描

- [kube-bench](https://github.com/aquasecurity/kube-bench): 使用 CIS Kubernetes 基准测试扫描集群组件，衡量 Kubernetes 集群的安全程度
- [kube-hunter](https://github.com/aquasecurity/kube-hunter): Kube-Hunter 在 Kubernetes 集群中查找安全弱点（例如远程代码执行或者信息泄露）。可以把 Kube-Hunter 作为一个远程扫描器，来从外部攻击者的视角来观察你的集群；也可以用 Pod 的方式来运行。
  - Kube-Hunter 有个特别之处就是“active hunting”，它不仅会报告问题，而且还会尝试利用在 Kubernetes 集群中发现的问题，这种操作可能对集群有害，应小心使用。
- [sonobuoy](https://github.com/vmware-tanzu/sonobuoy): 以无损害的方式运行一组插件（包括Kubernetes一致性测试）来评估 Kubernetes 集群的安全状态。

## 四、镜像安全

漏洞扫描：

- [trivy](https://github.com/aquasecurity/trivy): 容器镜像的漏洞扫描工具，harbor 可集成此工具为默认扫描器

安全分发（镜像签名与验证）：

- [theupdateframework/notray](https://github.com/theupdateframework/notary): harbor 仓库有集成此项目
- [theupdateframework/tuf](https://github.com/theupdateframework/tuf)
