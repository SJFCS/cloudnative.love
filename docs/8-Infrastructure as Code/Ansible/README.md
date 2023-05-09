---
title: Ansible
tags: [Infrastructure as Code & Automation,Ansible]
---

import DocCardList from '@theme/DocCardList';

[Ansible](https://github.com/ansible/ansible) 是一款基于 Python 的自动化运维工具，可以通过并发的 SSH 连接多个客户端，不需要在客户端安装 agent。方便利用“infrastructure as code”的方法，自动化执行多步骤部署和管理操作。

![1682902674876](image/README/1682902674876.png)

- **Inventory** 主机清单可通过主机标签和组等，对主机清单进行分类管理，可对不同类别的主机配置不同的参数，例如 SSH 登录用户名，密码信息和变量等。
- **Playbooks** 是 Ansible 中描述一组要执行的命令的文件。Playbooks 基于模块化的任务，具有可读性强、易于维护的特点。
- **Modules** 用于执行任务并返回结果，可以完成各种管理任务。Ansible 拥有数百个内置模块，可以覆盖日常的各种任务，例如文件操作，软件包管理，数据库操作等。
- **Plugins** 是 Ansible 提供的一种扩展框架，Ansible 插件分为以下几个类型：模块插件、callback 插件、inventory 插件、策略插件等。在节点上执行模块之前，运行插件，以扩展 Ansible 的功能。
- **Ansible API** 可以将 Ansible 与其他自动化工具，例如 Jenkins、Puppet、Terraform 等集成，以便于创建连续集成和部署管道。通过 Ansible API，可以更加便利地进行自动化集成和持续交付。
- **Configuration Management Database (CMDB)** 是一个管理系统，用于跟踪IT基础架构的配置。**Ansible-CMDB** 是一个开源工具，它利用 ansible 的数据收集技术，将结果存储在数据文件中，并将其转换为静态 HTML 页面，以便管理员更好的管理和维护IT基础架构。
- **Ansible 可视化平台：** Ansible Tower,Rundeck,AWX,Ansible-CMDB。

:::tip文档和社区
- [Ansible 官方文档](https://docs.ansible.com/ansible/latest/)
- [Jinja2 模板引擎官方 API 文档](https://jinja.palletsprojects.com/en/3.1.x/api/#basics)
- [Ansible Galaxy](https://galaxy.ansible.com/) 用于查找和分享 Ansible 资源如 Ansible 角色、集合、插件和复杂的 Playbook。
:::

<DocCardList />

参考文章：
- https://www.cnblogs.com/easonscx/p/10622781.html
- https://www.cnblogs.com/woaiyunwei/p/13140429.html
- https://www.jianshu.com/p/171578692c94
- https://www.cnblogs.com/keme/p/11351611.html#56-fetch-%E6%A8%A1%E5%9D%97