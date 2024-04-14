---
title: Terragrunt
---
- https://terragrunt.gruntwork.io/
- https://juejin.cn/post/7170199589121687582

<!-- 纯粹使用 HCL 编写 terraform 配置存在一个问题，就是配置无法复用，HCL 配置重复度太高。

为了降低配置重复度，terraform 提供了一个功能：module，它能在一定程度上实现 hcl 配置的复用。

但是 module 不仅引入了新的知识点需要学习，得到的效果也不怎么理想。

直接使用通用编程语言编写配置，才能带来最大的灵活性，也降低开发人员的学习成本。
因此 terraform 最近推出了 [terraform-cdk](https://github.com/hashicorp/terraform-cdk)，它基于 aws 的 CDK 组件，提供了类似 pulumi 的功能：用 Python/TypeScript 等高级语言管理基础设施。

不过这个项目还处在非常早期的阶段，不如 pulumi 成熟。 -->

