---
title: Terraform
sidebar_position: 2
tags: [Infrastructure as Code & Automation,HashiCorp,Terraform]
---

## 1. Terraform 命令使用流程

1. `terraform init -plugin-dir `
2. `terraform plan`: 生成执行计划
3. `terraform apply --auto-approve`: 应用计划
4. `terraform destroy`: 释放所有资源。（快速的创建与删除，非常适合进行测试）

此外，安装了 `graphviz` 后，还可以直接通过命令生成资源关系图：`terraform graph | dot -Tsvg > graph.svg`


## 2. Secrets 的安全传递

比较推荐通过环境变量来传递敏感信息。

大部分的 Provider，都支持直接使用环境变量传递 ACCESS_KEY/PASSWORD 等敏感信息。

terrafrom 也提供专用的环境变量 `TF_VAR_name` 来设置 terrafrom 变量(variable).

terraform 也可以通过 `.tfvars` 文件传变量。

## 3.  terraform 项目结构

terraform 运行时也读取当前文件夹下所有的 `.tf` 和 `.tfvars` 文件，因此可以将内容拆分为如下结构：

```shell
provider.tf             ### provider 配置
variable.tf              ### 通用变量
terraform.tfvars / terraform.tfvars.json   ### 为所有 variables 设定具体的值 
resource.tf             ### 资源定义
data.tf                 ### data 定义
output.tf               ### 输出（常用做 debug）
```

## 4. terraform 状态管理

terraform 默认将状态保存在本地的 `.tfstate` 文件中，但也支持设定不同的远端 Backend 存储状态。

推荐使用远端存储保存状态，默认使用的本地 `.tfstate` 容易导致管理混乱，安全性也很差。

比如

1. 使用阿里云 OSS 做状态存储: [alicoud oss backend - terraform docs](https://www.terraform.io/docs/backends/types/oss.html)
1. [gitlab 13 支持 Terraform HTTP State 协议](https://github.com/pulumi/pulumi/issues/4727)，可以直接将它用做 terraform 的 Backend.


## 推荐阅读
- https://www.oreilly.com/library/view/terraform-up-and/9781098116736/
- https://github.com/chechiachang/terraform-30-days
- https://lonegunmanb.github.io/introduction-terraform/