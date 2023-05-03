---
title: 常用命令和技巧
sidebar_position: 3
---

import DocCardList from '@theme/DocCardList';

<DocCardList />

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

## results matching ""

## No results matching ""
