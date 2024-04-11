---
title: Vagrant Share
---
:::tip
参考文档：

- https://developer.hashicorp.com/vagrant/docs/share
- https://github.com/hashicorp/vagrant-share
:::

Vagrant Share 允许您与世界上的任何人共享您的 Vagrant 环境，只需一个命令即可在几乎任何网络环境中直接在您的 Vagrant 环境中进行协作： vagrant share.

Vagrant 共享具有三种主要模式或功能。这些功能并不相互排斥，这意味着它们的任意组合都可以在任何给定时间激活：

- http 模式：将 Vagrant 环境通过 HTTP 公开共享。
    示例命令：vagrant share --http 80
- ssh 模式：将 Vagrant 环境通过 SSH 公开共享。
    示例命令：vagrant share --ssh
- https 模式：将 Vagrant 环境通过 HTTPS 公开共享。
    示例命令：vagrant share --https 443

