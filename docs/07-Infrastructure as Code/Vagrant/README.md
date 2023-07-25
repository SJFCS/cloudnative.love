---
title: Vagrant📝
tags: [Infrastructure as Code & Automation,HashiCorp,Vagrant]
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import DocCardList from '@theme/DocCardList';

如果您想要管理本地或远程虚拟机，想要快速关闭和重建虚拟机以进行开发和测试，同步本地文件和与成员分享虚拟环境，那么快来试试 Vagrant 。


有很多人认为 Vagrant 和 Terraform、Docker-Compose 都是环境管理工具但分不清其最佳的适用场景，这里简单说明一下：
1. Terraform: 更适合用于云环境和基础设施管理。
2. Vagrant 提供了许多 Terraform 没有的高级功能，如同步文件夹、自动网络、HTTP 隧道等，旨在简化开发环境的使用。
3. Docker-Compose 确实足够灵活，但不能满足部分需要内核级别隔离必须使用虚拟化的场景， vagrant 可以跨平台轻松地创建和分发环境，非常适合管理开发测试的机器资源。
4. 
在这里 [我应该使用 Vagrant 还是 Docker-Compose 来创建隔离环境？](https://stackoverflow.com/questions/16647069/should-i-use-vagrant-or-docker-for-creating-an-isolated-environment) Docker 和 Vagrant 的开发人员进行了辩论，有兴趣可以看一下。

## 快速开始

下面带你快速入门 vagrant 的使用。
- 安装 [Vagrant](https://developer.hashicorp.com/vagrant/downloads) 和 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)。如果遇到兼容性问题可以下载 [VirtualBox 历史版本](https://www.virtualbox.org/wiki/Download_Old_Builds)。

:::tip
Vagrant 将虚拟机镜称为为 Box
- 在此网址寻找要使用的镜像 https://app.vagrantup.com/boxes/search
:::
- 创建一个目录并进入该目录。执行如下命令初始化 Vagrant 环境：
  ```bash
  vagrant init ubuntu/trusty64
  ```
- 编辑 Vagrantfile 文件，比如添加网络配置：
  ```ruby
  Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    <!-- highlight-next-line -->
    config.vm.network "private_network", ip: "192.168.56.10"
  end
  ```
- 启动,连接,关闭和销毁虚拟机
  ```bash
  vagrant up      # 启动虚拟机
  vagrant ssh     # 连接虚拟机
  vagrant halt    # 关闭虚拟机
  vagrant destroy # 删除虚拟机 
  ```

# vb网段配置
```
/etc/vbox/networks.conf

* 10.0.0.0/8 192.168.0.0/8 172.0.0.0/8
* 2001::/64
```


更多用法请继续阅读本文档。

<DocCardList />


## FQA
- https://serverfault.com/questions/453185/vagrant-virtualbox-dns-10-0-2-3-not-working