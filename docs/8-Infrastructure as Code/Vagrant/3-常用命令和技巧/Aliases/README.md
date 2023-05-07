---
title: Aliases
---
:::tip
参考文档: https://developer.hashicorp.com/vagrant/docs/cli/aliases
:::

Aliases 别名可以在 `VAGRANT_HOME/aliases` 文件中定义，也可以在使用环境变量定义的自定义文件中定义 `VAGRANT_ALIAS_FILE`。

## 内部别名
内部命令别名直接调用 CLI 类，允许您将一个 Vagrant 命令作为另一个 Vagrant 命令的别名，例如：
```bash
start = up 
stop =  halt
clean =  ! vagrant destroy &&  rm -rf .vagrant
```

## 外部别名

虽然内部别名可用于定义更直观的 Vagrant 命令，但外部命令别名用于定义具有全新功能的 Vagrant 命令。这些别名以 字符为前缀!，向解释器指示别名应作为 shell 命令执行。例如，假设您希望能够查看活动项目的虚拟机的处理器和内存利用率。为此，您可以定义一个vagrant metrics命令，以易于阅读的格式返回所需信息，如下所示：

```bash
metrics = !ps aux | grep "[V]BoxHeadless" | grep $(cat .vagrant/machines/default/virtualbox/id) | awk '{ printf("CPU: %.02f%%, Memory: %.02f%%", $3, $4) }'
```

上面的别名，来自一个活动的 Vagrant 项目的上下文，将 CPU 和内存利用率直接打印到控制台：

```bash
CPU: 4.20%, Memory: 11.00%
```