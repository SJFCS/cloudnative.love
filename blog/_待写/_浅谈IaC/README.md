传统的方式是运行 Terraform 来提供机器，手动编写这些机器的 Ansible 清单，然后运行 ​​Ansible 来配置那些机器，但在端到端的自动化中，独立工具的边缘以自动化的方式连接. 可以说，端到端自动化是一种完全以自动化方式开发 DevOps 生命周期的方法，无需任何人工交互或手动过程。所有的工作都应该自动完成。

为了集成 Terraform 和 Ansible 等工具以实现端到端自动化，现在开发了几种工具，但所有这些工具都用于集成 Terraform 和 Ansible，用于 Terraform 在公共云（如 AWS、GCP）上提供的实例等。要在此类环境中进行集成，请在 Google 上搜索“ Terraform Ansible Integration ”。  






MAASTA是一种为 Terraform 提供的 MAAS 实例生成 Ansible 清单的工具。借助 MAASTA，您可以将 MAAS、Terraform 和 Ansible 集成在一起，以在您的本地环境中实现端到端的自动化。在 MAASTA 和这些工具的帮助下，DevOps 生命周期的创建变得更加甜蜜。




假设您想为本地基础设施创建 DevOps 生命周期。在这种情况下，您需要 MAAS 与您的真实基础设施交互，并将您的裸机或虚拟机带入类似云的基础设施。之后，为了实现自动化，您需要 Terraform 工具与 MAAS 交互，以在没有直接人工交互的情况下配置实例和管理它们。当实例、机器由 Terraform 提供后，配置它们的时间就到了。要配置实例，您需要 Ansible 工具，但 Ansible 如何发现 Terraform 提供的目标。答案是MAASTA！MAASTA 用于发现 Terraform 配置的 MAAS 实例并为它们创建 Ansible 清单文件。在 MAASTA 的帮助下，