

## 快照

安装Vagrant快照插件：
```bash
vagrant plugin install vagrant-vbox-snapshot
```
```bash
$ vagrant snapshot
Usage: vagrant snapshot <command> [<args>]

Available subcommands:
     back
     delete
     go
     list
     take

For help on any individual command run `vagrant snapshot <command> -h
```

使用方法：

- 创建一个快照
    ```bash
    vagrant snapshot take "Name"
    ```
- 查看快照列表
    ```bash
    vagrant snapshot list
    ```
- 从指定快照中恢复
    ```bash
    vagrant snapshot go "Name"
    ```
- 删除一个快照
    ```bash
    vagrant snapshot delete "Name"
    ```

## 不想在 vagrant reload 的时候重复的运行一些任务

你可以使用 Vagrant 的 provision flag 来控制是否运行某些任务。在 Vagrantfile 中，你可以为每个 provisioner 指定一个唯一的标识符，并在运行 vagrant reload 时指定哪些标识符应该被运行。

例如，假设你有一个名为 "shell" 的 shell provisioner：

```ruby
config.vm.provision "shell", inline: "echo 'Hello, World!'"
```

你可以为该 provisioner 指定一个标识符：

```ruby
config.vm.provision "shell", id: "hello_world", inline: "echo 'Hello, World!'"
```

然后，在运行 vagrant reload 时，你可以使用 --provision-with 标志来指定要运行的 provisioner，如下所示：

```bash
vagrant reload --provision-with hello_world
```

这将只运行标识符为 "hello_world" 的 provisioner，而不运行其他 provisioner。


https://junmajinlong.com/virtual/vagrant/vagrant_snapshot/
