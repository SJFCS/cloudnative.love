---
title: Ansible
tags: [Infrastructure as Code & Automation,Ansible]
---

import DocCardList from '@theme/DocCardList';

[Ansible](https://github.com/ansible/ansible) 是一款基于 Python 的自动化运维工具，可以通过并发的 SSH 连接多个客户端，不需要在客户端安装 agent。方便利用“infrastructure as code”的方法，自动化执行多步骤部署和管理操作。

![1682902674876](image/README/1682902674876.png)

## 基本概念

- **Inventory** 主机清单可通过主机标签和组等，对主机清单进行分类管理，可对不同类别的主机配置不同的参数，例如 SSH 登录用户名，密码信息和变量等。
- **Playbooks** 是 Ansible 中描述一组要执行的命令的文件。Playbooks 基于模块化的任务，具有可读性强、易于维护的特点。
- **Modules** 用于执行任务并返回结果，可以完成各种管理任务。Ansible 拥有数百个内置模块，可以覆盖日常的各种任务，例如文件操作，软件包管理，数据库操作等。
- **Plugins** 是 Ansible 提供的一种扩展框架，Ansible 插件分为以下几个类型：模块插件、callback 插件、inventory 插件、策略插件等。在节点上执行模块之前，运行插件，以扩展 Ansible 的功能。
- **Ansible API** 可以将 Ansible 与其他自动化工具，例如 Jenkins、Puppet、Terraform 等集成，以便于创建连续集成和部署管道。通过 Ansible API，可以更加便利地进行自动化集成和持续交付。
- **Configuration Management Database (CMDB)** 是一个管理系统，用于跟踪IT基础架构的配置。**Ansible-CMDB** 是一个开源工具，它利用 ansible 的数据收集技术，将结果存储在数据文件中，并将其转换为静态 HTML 页面，以便管理员更好的管理和维护IT基础架构。
- **Ansible 可视化平台：** Ansible Tower,Rundeck,AWX,Ansible-CMDB。

:::infoAnsible 执行返回颜色
- 黄色：对远程节点进行相应修改
- 绿色：对远程节点不进行相应修改，或者只是对远程节点信息进行查看
- 红色：操作执行命令有异常
- 紫色：表示对命令执行发出警告信息（可能存在的问题，给你一下建议）

可以在 ansible.cfg 中进行自定义颜色。
:::

## 工具集合
- **Ansible-console：**  
  交互式命令行工具，用于快速测试 Ansible 模块和任务。
- **Ansible-operator：**  
  用于 Kubernetes 集群中运行的一个 Ansible 控制器，可以自动管理和配置 Kubernetes 工作负载。
- **Ansible-vault：**  
  用于加密敏感信息的命令行工具，如密码、证书等。
- **Ansible-community：**  
  Ansible 社区维护的一组 Ansible 模块、插件和其他工具。
- **Ansible-doc：**  
  用于生成和查看 Ansible 模块和插件文档的命令行工具。
- **Ansible-playbook：**  
  用于编写和运行 Ansible 的任务剧本，可以在多个主机上执行一系列任务，从而实现自动化部署和配置。
- **Ansible-config：**  
  用于配置和管理 Ansible 工具的命令行工具。
- **Ansible-galaxy：**  
  一个 Ansible 角色和插件管理器，允许用户共享和发现 Ansible 角色、插件和集合。
- **Ansible-pull：**  
  一种反向操作方式，允许在远程主机上自动拉取 Ansible 配置并应用它们。
- **Ansible-connection：**  
  用于管理 Ansible 集群中远程主机之间的连接和通信的插件。
- **Ansible-inventory：**  
  用于生成和管理 Ansible 主机清单的工具。
- **Ansible-test：**  
  用于编写和运行 Ansible 角色和插件测试的命令行工具。
- **Ansible-cmdb：**  
  一个 Ansible 插件，用于生成主机和应用程序的 inventory 来生成和显示概述信息。

:::tip文档和社区
- [Ansible 官方文档](https://docs.ansible.com/ansible/latest/)
- [Jinja2 模板引擎官方 API 文档](https://jinja.palletsprojects.com/en/3.1.x/api/#basics)
- [Ansible Galaxy](https://galaxy.ansible.com/) 用于查找和分享 Ansible 资源如 Ansible 角色、集合、插件和复杂的 Playbook。
:::

<DocCardList />
