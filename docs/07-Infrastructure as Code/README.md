---
title: Infrastructure as Code
sidebar_position: 0
tags: [Infrastructure as Code]
---
在 DevOps 世界中，确保开发、测试和生产环境尽可能一致至关重要。如果环境之间出现了配置差异，那么在测试环境中运行良好的代码可能无法在生产环境中部署。在传统的基础设施管理中，管理员通常会通过手动操作和脚本来管理和维护服务器和环境。然而，这种方式会导致许多微小和临时的修改都没有被记录或跟踪，渐渐变得不再符合组织要求，形成了所谓的“配置漂移”（Configuration Drift）。这可能会导致系统出现意外行为、安全问题、不稳定或停机等问题。

基础设施即代码（Infrastructure as code, IaC）可以帮助开发者通过代码来管理IT基础架构，是消除配置漂移最有效的方法之一。通过使用像 Terraform、Pulumi 和 Ansible 这样的工具，可以更好地管理配置，识别漂移并发出信号，有时甚至还能自动纠错。这样，您就有可能在变更真正影响系统之前将其纠正过来。此外，IaC 方便借助代码版本控制实现 GitOps，以提供详细的记录，解决了修改没有记录无法审计的问题。

在您的 DevOps 实践中，始终注意维护一致性以及追踪变更并记录修改，这样可以更好地保证系统的可靠性和稳定性。

## 工具介绍：


- Ansible 可通过声明式的 yaml 文件来定义任务，它常用于远程服务器配置管理和应用程序的部署，但其无法很好的对基础设施做声明式的定义管理。 

- 2011年 AWS 推出 [CloudFormation](https://aws.amazon.com/cn/cloudformation/getting-started/) 提供了通过声明式配置文件来编排云端基础设施的能力。但它是 AWS 独家拥有的能力，不支持其他的云供应商 (provider) 。

- 为了支持更多云供应商 HashiCorp 公司推出了 Terraform 它不仅支持声明式定义基础设施的状态和资源而且支持多个云提供商。Terraform 使用类似于 CloudFormation 的模板语言，称为 HCL（HashiCorp Configuration Language）用于编写 Terraform 的配置文件。

- Pulumi 其支持使用多种编程语言来定义基础设施代码，包括 JavaScript、TypeScript、Python、Go、.NET 等，开发者不需要学习新的语言和语法，而且在开发方式和管理协作方面更加灵活。

- 但 Terraform 和 Pulumi 是特定于云供应商的工具，需要为不同的云提供商使用对应的 provider 及 API 来编写不同的代码，缺少可移植基础设施的能力。为了实现云平台基础设施的可移植性，诞生了 Crossplane 它可以使用相同的代码和配置在不同的云平台上交付，Crossplane 公开了一个 REST API，你可以使用任何语言,shell,Python,Erlang来与其集成，甚至可以使用 Terraform 对 Crossplane 进行配置。但目前云供应商对 Crossplane 的支持相对于 Terraform 来说还不够完善。由于 Crossplane 是比较新的开源项目，因此支持的云供应商和资源类型相对较少。

- 在开发环境和测试环境我们可能需要为不同团队分配虚拟机，这时候 Vagrant 则更加适合，虽然 Vagrant 和 Terraform 都是 HashiCorp 公司推出用于环境管理的项目。但 Vagrant 是一个专注于管理开发环境的工具，而 Terraform 是一个用于构建基础设施的工具。Vagrant 提供了许多 Terraform 没有的高级功能，如同步文件夹、自动网络、HTTP 隧道等，旨在简化开发环境的使用。

<!-- Crossplane 团队正在研究的一种解决方法是使用[Terrajet](https://github.com/crossplane/terrajet)提供程序。它是一个可以处理 Terraform providers 以生成 Crossplane providers 的工具。 

[kubevirt](https://github.com/kubevirt/kubevirt)

[couler](https://github.com/couler-proj/couler)  -->

## 参考
- [Infrastructure as Code: Chef, Ansible, Puppet, or Terraform?](https://www.ibm.com/cloud/blog/chef-ansible-puppet-terraform)
- [what-is-infrastructure-as-code-iac](https://www.redhat.com/zh/topics/automation/what-is-infrastructure-as-code-iac)
- [Configuration Drift: Why It’s Bad and How to Eliminate It](https://www.aquasec.com/cloud-native-academy/vulnerability-management/configuration-drift/)
- [OAM和Crossplane: 构建现代应用的下一个阶段](https://cloudnative.to/blog/oam-crossplane/)
- [如何在 Kubernetes 上使用 Crossplane 构建您的云基础设施](https://www.padok.fr/en/blog/kubernetes-infrastructure-crossplane)
- [crossplane vs terraform](https://blog.crossplane.io/crossplane-vs-terraform/)
- [Eating Your Vegetables: How to Manage 2.5 Million Lines of YAML - Daniel Thomson & Jesse Suen](https://www.youtube.com/watch?v=BGiCRyUDIPg)
- https://www.digitalocean.com/community/tutorial-series/getting-started-with-configuration-management