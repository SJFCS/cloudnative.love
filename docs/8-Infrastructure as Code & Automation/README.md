---
title: Infrastructure as Code & Automation
sidebar_position: 7
tags: [Infrastructure as Code & Automation]
---
## IaaC - 基础设施即代码

- 基础架构即代码意味着我们可以使用机器可读的自动化语言来定义和描述 IT基础架构的状态，并在其中进行所需的更改。
- IaaC 利于 GitOps 方便 review ，而且能避免配置漂移
- 理想情况下，自动化语言应该非常易于阅读和理解，因为这样我们就可以轻松了解当前状态并根据需要进行更改。

这个领域，我目前了解到的有三个代表性的项目，它们都是通过声明式语法来配置基础设施，但是也有些区别：
1. ansible 是一个用于供应、配置管理和应用程序部署的开源软件,通过它我们可以实施基础架构即代码实践。
2. terraform（热度最高）: 基础设施即**配置**，通过专用的 HCL 语言来声明式地配置基础设施。HCL 功能比较弱，而且还有额外的学习成本。
3. pulumi（热度其次）: 基础设施即**代码**，通过 Python/Go/TypeScript 等通用编程语言来声明基础设施，灵活性很高。
    - pulumi 的 provider 基本完全来自 terraform 社区，因此 API 结构也完全一致。
4. [Crossplane](https://github.com/crossplane/crossplane): 通过 Kubernetes 自定义资源(CR) 来声明基础设施。
    - 我目前比较看好 Crossplane ，因为它不像Terraform 必须使用域特定语言 (DSL) - HCL 配置，Crossplane 公开了一个 REST API，你可以使用任何语言,shell,Python,Erlang来与其集成，甚至可以使用 Terraform 对 Crossplane 进行配置！
    - crossplane 提倡通过 Kubernetes API 资源模型来声明基础设施，表现形式上目前主要是 Yaml.
    - crossplane 集成了 OAM 模型，带来的一个特性是：它可以在平台无关的层面去定义基础设施，在各云平台都能通用！！！
5. [kubevirt](https://github.com/kubevirt/kubevirt): 它和 crossplane 理念一致，只是目标不同——使用 Kubernetes CR 来声明虚拟机。
    - 我们以前是使用 vsphere 的 python sdk 创建虚拟机，非常难用。现在正在向 ProxmoxVE 的 terraform provider 迁移，计划使用 pulumi/terraform 来声明虚拟机。
    - 这个项目目前保持观望。

[couler](https://github.com/couler-proj/couler) 目标也是提供统一的 Python API 来编写 tekton(yaml)/argo(yaml)/airflow(python) 的 workflow，它的目标之一也是使用 Python 来替代 Kubernetes yaml。

目前 pulumi/terraform 都缺少定义可移植基础设施的能力，每个云平台都需要使用对应的 provider 及其 API。
而 Crossplane+OAM，就能将云平台与具体的基础设施定义解耦，实现配置在不同平台间的复用。
因此 Crossplane 的未来也值得期待。

Crossplane 团队正在研究的一种解决方法是使用[Terrajet](https://github.com/crossplane/terrajet)提供程序。它是一个可以处理 Terraform providers 以生成 Crossplane providers的工具。 
## 参考

- [OAM和Crossplane: 构建现代应用的下一个阶段](https://zhuanlan.zhihu.com/p/145443259)
- [如何在 Kubernetes 上使用 Crossplane 构建您的云基础设施](https://www.padok.fr/en/blog/kubernetes-infrastructure-crossplane)
- [crossplane vs terraform](https://blog.crossplane.io/crossplane-vs-terraform/)
- [Eating Your Vegetables: How to Manage 2.5 Million Lines of YAML - Daniel Thomson & Jesse Suen](https://www.youtube.com/watch?v=BGiCRyUDIPg)

<!-- ## 画外：不断增长的配置复杂性

为了应付配置 config 不断增长的复杂性和维护难题，kubernetes 社区出现了 helm/kustomize，此外还死了一票 ksonnet 之类的前浪。

ansible 则选用了 jinja2 作为自己的 yaml 模板引擎，很多熟悉 ansible 的运维人员也因此青睐 jinja2.

hashicorp 在自家的全家桶(terraform/vault/consul)中选用自研的 hcl 语言编写配置，而 pulumi 直接选用通用编程语言 python/typescript/c#/go 编写配置。

对于「基础设施即代码」，我使用过 terraform 和 pulumi，个人的感觉是，复杂场景下必须要使用 pulumi+python 才能 hold 住配置的复杂性。
terraform 的 hcl 灵活度太差了，即使算上 module，体验和 pulumi+python 也要差一个档次。

## 画外：文本渲染的几种思路 - 通用模板 vs DSL 专有模板

在文本渲染领域，有三类不同思路的渲染工具，都很受欢迎：

1. 通用模板：如 jinja2/mustache/go-templates，这类模板语言很「通用」，可用于各类文本渲染场景，因此应用非常广泛。
   - 「通用模板」和 DSL 语法通常都难以兼容，未渲染的模板不能直接被解析使用。
2. DSL 专有模板：如 thymeleaf(xml)，特点是模板本身就是一份完备的 DSL 文本，可以被正确解析，甚至可以直接使用。
3. DSL 语法增强：如 jsonnet/yaml，这两个 DSL 都是 json 的超集，针对 json 冗长、不支持注释等缺点做了优化。

两类模板各有千秋，不过总的来说，「通用模板」是最流行的，毕竟它可以「learn once, use anywhere.」而「DSL 专有模板」也有自己的应用场景。

目前我个人更喜欢使用「通用模板」- helm/jinja2。
DSL 专有模板需要慎重考虑，毕竟会引入额外的复杂度，会增加维护成本。 -->
