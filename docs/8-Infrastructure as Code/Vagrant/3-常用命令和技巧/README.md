---
title: 常用命令和技巧
sidebar_position: 3
---

import DocCardList from '@theme/DocCardList';

<DocCardList />

https://fastzhong.com/posts/vagrant/

vagrant global-status --prune
自动完成
Vagrant 提供了自动完成命令的能力。目前 支持 bash 和 shell。zsh 这些可以通过运行启用 vagrant autocomplete install --bash --zsh。

destroy 只删除虚拟机而不会删除 box 如果想删除 box 请运行 vagrant box remove xx
https://stackoverflow.com/questions/16647069/should-i-use-vagrant-or-docker-for-creating-an-isolated-environment

| 命令                                                     | 简单说明                                       |
| -------------------------------------------------------- | ---------------------------------------------- |
| `vagrant init [options] [name [url]]`                    | 初始化 box 的操作                              |
| `vagrant up [options] [name or id]`                      | 启动虚拟机的操作                               |
| `vagrant ssh [options] [name or id] [-- extra ssh args]` | 登录虚拟机的操作                               |
| `vagrant box add [options] <name, url, or path>`         | 添加 box 的操作                                |
| `vagrant box remove <name>`                              | 删除某个 box                                   |
| `vagrant box list`                                       | 查看 box 列表                                  |
| `vagrant box remove`                                     | 删除相应的 box                                 |
| `vagrant destroy [options] [name or id]`                 | 停止当前正在运行的虚拟机并销毁所有创建的资源   |
| `vagrant halt [options] [name or id]`                    | 关闭虚拟机                                     |
| `vagrant package [options] [name or id]`                 | 打包命令，可以把当前的运行的虚拟机环境进行打包 |
| `vagrant reload [vm-name]`                               | 重新启动虚拟机，主要用于重新载入配置文件       |
| `vagrant suspend [name or id]`                           | 挂起当前虚拟机                                 |
| `vagrant resume [vm-name]`                               | 恢复被挂起的状态                               |
| `vagrant ssh-config [options] [name or id]`              | 输出用于 ssh 连接的一些信息                    |
| `vagrant status [name or id]`                            | 获取当前虚拟机的状态                           |

我不想执行vagrant up 创建虚拟机，因为那样做太慢了，不利于调试。

您可以使用 vagrant validate 命令验证Vagrantfile文件的语法和结构是否正确。这将帮助您快速发现任何潜在的错误或问题，并使您能够快速进行调试，而无需等待虚拟机启动的时间。如果您想检查配置设置是否正确，也可以使用 vagrant provision --dry-run 命令来模拟部署过程并检查输出结果。这些命令都不会创建虚拟机实例，因此它们非常适合在调试期间使用。