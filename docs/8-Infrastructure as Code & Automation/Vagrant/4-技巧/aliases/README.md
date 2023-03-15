别名

https://developer.hashicorp.com/vagrant/docs/cli/aliases

别名可以在VAGRANT_HOME/aliases文件中定义，也可以在使用环境变量定义的自定义文件中定义VAGRANT_ALIAS_FILE，格式如下：


```bash
# 基本命令级别名
start = up 
stop =  halt 

# 高级命令行别名
eradicate =  ! vagrant destroy &&  rm -rf .vagrant

```


内部别名
内部命令别名直接调用 CLI 类，允许您将一个 Vagrant 命令作为另一个 Vagrant 命令的别名。此技术对于创建您认为应该存在的命令非常有用。例如，如果vagrant stop感觉比 更直观vagrant halt，则以下别名定义将使该更改成为可能：

```
stop = halt

    
```
这使得以下命令等效：

```
vagrant stop
vagrant halt
```

外部别名
虽然内部别名可用于定义更直观的 Vagrant 命令，但外部命令别名用于定义具有全新功能的 Vagrant 命令。这些别名以 字符为前缀!，向解释器指示别名应作为 shell 命令执行。例如，假设您希望能够查看活动项目的虚拟机的处理器和内存利用率。为此，您可以定义一个vagrant metrics命令，以易于阅读的格式返回所需信息，如下所示：

```
metrics = !ps aux | grep "[V]BoxHeadless" | grep $(cat .vagrant/machines/default/virtualbox/id) | awk '{ printf("CPU: %.02f%%, Memory: %.02f%%", $3, $4) }'


```

上面的别名，来自一个活动的 Vagrant 项目的上下文，将 CPU 和内存利用率直接打印到控制台：

```
CPU: 4.20%, Memory: 11.00%

```