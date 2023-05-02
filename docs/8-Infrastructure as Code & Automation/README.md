---
title: Infrastructure as Code & Automation
sidebar_position: 8
tags: [Infrastructure as Code & Automation]
---
目前中国人参加 ACM(acm.org，计算机协会)年费有折扣，折下来160+一年，可以在 learning.acm.org 上进入 O'REILLY 在线学习中心畅读大量 O'REILLY 的电子书，非常划算，基本读两三本就回本了。

## 背景痛点


在最理想的情况下，变更会以良好的方式进行全面跟踪。但是，我们的生产环境并不完美，比如其中的许多修改都没有记录。如果是无关紧要的修改，那么对系统的影响会很小。如果这些修改导致系统变得不稳定，再符合组织的要求，那么就会出现所谓的“配置漂移”。

当对软件和硬件的更改是临时的，没有被记录或跟踪时，就会发生配置漂移。这可能会导致意外的系统行为、不稳定或停机。配置漂移对安全漏洞管理也有重大影响。



在 DevOps 世界中，确保开发、测试和生产环境尽可能相似至关重要。任何这些环境中的配置漂移都可以解释为什么代码在一个环境中有效而在另一个环境中无效。例如，在测试环境中完美运行的代码可能无法在生产环境中部署——这可能是由于软件本身或其周围环境的配置漂移造成的。




实现基础设施即代码（Infrastructure as code, IaC）是消除配置漂移最有效的方法之一。


借助代码版本控制（如Git），基础设施即代码平台还可以提供详细的记录，包括现在和以前的配置，解决了修改没记录的问题，这还有一个额外的好处就是留下审计线索。像 Terraform、Pulumi 和 Ansible 这样的工具就是设计用来管理配置的，可以用它们识别漂移并发出信号，有时甚至还能自动纠错——这样，你就有可能在变更真正影响系统之前将其纠正过来。




## IaC - 基础设施即代码   主流技术，区别


[CloudFormation](https://aws.amazon.com/cn/cloudformation/getting-started/)
通过编写声明式的配置文件就可以批量反复创建一批云端资源
不需要在界面上点点点。去修复因环境之间配置不一致而引发的种种错误而焦头烂额。

CloudFormation 是 AWS 独家拥有的能力

Terraform 需要为不同的云服务商编写不同的代码，因为它是一种特定于云供应商的工具。Terraform提供了一组适用于特定云供应商的资源类型和数据源，需要根据不同的云平台编写不同的代码。


Crossplane 实现了云平台的可移植性，它可以使用相同的代码和配置在不同的云平台上交付。Crossplane支持多个云供应商和本地基础设施，提供了一种单一的、声明式的API和资源定义方式，将云供应商的API集成到统一的控制平面中。

目前云厂商对Crossplane的支持相对于Terraform来说还不够完善。由于Crossplane是比较新的开源项目，因此支持的云供应商和资源类型相对较少。但是，随着Crossplane的不断发展和成熟，越来越多的云供应商开始支持它，未来也会有更多的云平台提供原生支持。


Pulumi 编程语言支持：与其他 IaC 工具相比，Pulumi 允许使用多种编程语言来定义基础设施代码，包括 JavaScript、TypeScript、Python、Go、.NET 等。

他们在思考 Terraform 配置文件该用 JSON 还是 YAML 时，对两者都不满意，所以他们宁可慢下来，花时间去设计了 [HashiCorp Configuration Language, HCL](https://github.com/hashicorp/hcl) 使得他们对于声明式代码的可读性有了完全的掌控力。再比如在他们设计 Terraform 以及 Vault、Packer 时，他们使用的 go 语言因为是把引用代码下载下来后静态链接编译成单一可执行文件，所以不像 jar 或者 dll 那样有运行时动态加载插件的能力。因此他们又花时间开发了 [go-plugin](https://github.com/hashicorp/go-plugin) 这个项目，把插件编译成一个独立进程，与主进程通过 rpc 进行互操作。该项目上的投资很好地支撑了 Terraform、Vault、Packer 项目的插件机制，进而演化出如今百花齐放的 HashiCorp 开源生态。



- IaC 利于 GitOps 方便 review ，而且能避免配置漂移

1. ansible 是一个用于供应、配置管理和应用程序部署的开源软件,通过它我们可以实施基础架构即代码实践。
2. terraform（热度最高）: 基础设施即**配置**，通过专用的 HCL 语言来声明式地配置基础设施。HCL 功能比较弱，而且还有额外的学习成本。
3. pulumi（热度其次）: 基础设施即**代码**，通过 Python/Go/TypeScript 等通用编程语言来声明基础设施，灵活性很高。
    - pulumi 的 provider 基本完全来自 terraform 社区，因此 API 结构也完全一致。
4. [Crossplane](https://github.com/crossplane/crossplane): 通过 Kubernetes 自定义资源(CR) 来声明基础设施。
    - 我目前比较看好 Crossplane ，公开了一个 REST API，你可以使用任何语言,shell,Python,Erlang来与其集成，甚至可以使用 Terraform 对 Crossplane 进行配置！
  
5. [kubevirt](https://github.com/kubevirt/kubevirt)

[couler](https://github.com/couler-proj/couler) 

Couler是一个流行的项目，它允许您以一种与平台无关的方式指定工作流，但它主要支持 Argo Workflows（并计划在未来支持 Kubeflow 和 AirFlow）
目标也是提供统一的 Python API 来编写 tekton(yaml)/argo(yaml)/airflow(python) 的 workflow，它的目标之一也是使用 Python 来替代 Kubernetes yaml。

目前 pulumi/terraform 都缺少定义可移植基础设施的能力，每个云平台都需要使用对应的 provider 及其 API。
而 Crossplane+OAM，就能将云平台与具体的基础设施定义解耦，实现配置在不同平台间的复用。

Crossplane 团队正在研究的一种解决方法是使用[Terrajet](https://github.com/crossplane/terrajet)提供程序。它是一个可以处理 Terraform providers 以生成 Crossplane providers的工具。 
## 参考

- [OAM和Crossplane: 构建现代应用的下一个阶段](https://cloudnative.to/blog/oam-crossplane/)
- [如何在 Kubernetes 上使用 Crossplane 构建您的云基础设施](https://www.padok.fr/en/blog/kubernetes-infrastructure-crossplane)
- [crossplane vs terraform](https://blog.crossplane.io/crossplane-vs-terraform/)
- [Eating Your Vegetables: How to Manage 2.5 Million Lines of YAML - Daniel Thomson & Jesse Suen](https://www.youtube.com/watch?v=BGiCRyUDIPg)

https://www.ibm.com/cloud/blog/chef-ansible-puppet-terraform

https://www.redhat.com/zh/topics/automation/what-is-infrastructure-as-code-iac

[配置漂移：为什么不好以及如何消除它](https://www.aquasec.com/cloud-native-academy/vulnerability-management/configuration-drift/)