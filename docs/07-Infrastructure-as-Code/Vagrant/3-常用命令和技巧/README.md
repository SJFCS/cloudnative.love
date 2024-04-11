---
title: 常用命令和技巧
sidebar_position: 3
---

import DocCardList from '@theme/DocCardList';

## 常用命令

| 命令                                                     | 简单说明                 |
| -------------------------------------------------------- | ------------------------ |
| `vagrant init [options] [name [url]]`                    | 初始化 box               |
| `vagrant up [options] [name or id]`                      | 启动虚拟机               |
| `vagrant destroy [options] [name or id]`                 | 停止并销毁资源           |
| `vagrant halt [options] [name or id]`                    | 关闭虚拟机               |
| `vagrant reload [vm-name]`                               | 重启虚拟机，重载配置文件 |
| `vagrant suspend [name or id]`                           | 挂起                     |
| `vagrant resume [vm-name]`                               | 恢复挂起                 |
| `vagrant status [name or id]`                            | 虚拟机的状态             |
| `vagrant ssh-config [options] [name or id]`              | 输出 ssh 配置            |
| `vagrant ssh [options] [name or id] [-- extra ssh args]` | ssh 连接虚拟机           |
| `vagrant box add [options] <name, url, or path>`         | 添加 box                 |
| `vagrant box remove <name>`                              | 删除 box                 |
| `vagrant box list`                                       | 查看 box                 |
| `vagrant package [options] [name or id]`                 | 虚拟机打包成 box         |

## 快照管理

vagrant snapshot 中 “push”和“pop”用于管理当前虚拟机的本地快照，而“save”和“restore”用于管理当前虚拟机的全局快照，无论是本地还是远程。

- vagrant snapshot push # 将当前虚拟机的状态保存为一个新的本地快照，并将该快照推送到快照栈顶部。
- vagrant snapshot pop # 将当前虚拟机恢复到上一个本地快照的状态，并将该快照从快照栈中弹出
  --[no-]provision- 强制供应商运行（或阻止他们这样做）。
  --no-delete- 防止在恢复后删除快照（以便您以后可以再次恢复到同一点）。
  --no-start- 防止来宾在恢复后启动
- vagrant snapshot save [vm-name] NAME # 将当前虚拟机的状态保存为一个全局快照，并将该快照上传到远程快照存储库（如果配置了的话）。可以使用
- vagrant snapshot restore [vm-name] NAME # 将当前虚拟机恢复到指定的全局快照的状态。
  --[no-]provision- 强制供应商运行（或阻止他们这样做）。
  --no-start- 防止来宾在恢复后启动
- vagrant snapshot list
- vagrant snapshot delete [vm-name] NAME

## 全局状态

`vagrant global-status` 会列出当前系统上所有 Vagrant 管理的虚拟机的状态，包括虚拟机的 ID、名称、状态、所在目录等信息。而 `vagrant global-status --prune` 会在列出虚拟机状态的同时，删除所有已经不存在的虚拟机记录，以避免记录残留，节省系统资源。


## 调试技巧

`vagrant up` 创建虚拟机太慢了，不利于调试。可以使用 `vagrant validate` 命令验证 Vagrantfile 文件的语法和结构是否正
确。这将帮助您快速发现任何潜在的错误或问题，并使您能够快速进行调试，而无需等待虚拟机启动的时间。

如果您想检查配置设置是否正确，也可以使用 `vagrant provision --dry-run` 命令来模拟部署过程并检查输出结果。这些命令都不会创建虚拟机实例，因此它们非常适合在调试期间使用。

## 自动补全

Vagrant 提供了自动完成命令的能力。目前 支持 bash 和 shell。zsh 这些可以通过运行启用 `vagrant autocomplete install --bash --zsh`

**扩展阅读：**https://fastzhong.com/posts/vagrant/

更多用法请继续阅读本文档。

<DocCardList />
