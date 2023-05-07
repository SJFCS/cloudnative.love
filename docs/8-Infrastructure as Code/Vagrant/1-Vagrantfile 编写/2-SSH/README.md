---
title: SSH
sidebar_position: 2
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

SSH 配置如：指定+用户名密码和添加公钥等

:::tip
参考文档：https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings
:::

### 用户名密码登录
官方提供的镜像的账号都是不允许远程登录的，所以使用官方镜像不应该添加`config.ssh.username`参数，否则创建虚拟机时多次尝试ssh登录，都会失败，浪费大量时间。

当你的镜像设置了远程登录用户，可以使用 `config.ssh.username` 和 `config.ssh.password` 参数来指定。
```ruby
Vagrant.configure("2") do |config|
  #...
  config.ssh.username = "user"
  config.ssh.password = "password"
end
```
:::caution
注意，您需要确保这些用户存在于来宾操作系统上
:::


## vagrant 使用自定义密钥  而不是其非安全密钥

如果在配置文件中没有指定密钥路径，则 Vagrant 会默认使用 ~/.vagrant.d/insecure_private_key 作为私钥，没有默认的公钥路径。需要手动复制私钥内容到虚拟机的 authorized_keys 文件中。

开启 config.ssh.insert_key = false 后.ssh/authorized_keys 会使用非安全公钥 vagrant insecure public key。如下我们将本地公钥`~/.ssh/id_rsa.pub` 添加到虚拟机中:
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  #  highlight-start
  config.ssh.insert_key = false
  node1.ssh.username = 'vagrant'
  config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
  #  highlight-start
end
```

或者

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "node1" do |node1|
    node1.vm.box = "ubuntu/focal64"
    #  highlight-start
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    node1.vm.provision "shell", inline: <<-SHELL
        mkdir -p /home/vagrant/.ssh
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        # curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> output.txt
        chown -R vagrant:vagrant /home/vagrant/.ssh
        chmod 700 /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
    #  highlight-start
end
```

## ssh-config

当使用 Vagrant 启动多个虚拟机时，每个虚拟机都会在本地分配一个不同的 SSH 端口。默认情况下，Vagrant 将使用端口范围为 2200 到 2250 的随机端口，以避免端口冲突。这些端口会被映射到虚拟机的 22 端口，以便在本地使用 SSH 连接到虚拟机。

例如，如果您在 Vagrantfile 中定义了两个虚拟机，如下所示：

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/focal64"
  end

  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/focal64"
  end
end
```
在这个例子中，我们定义了两个名为 "web" 和 "db" 的虚拟机，它们都使用 Ubuntu Focal64 镜像。当我们启动这些虚拟机时，Vagrant 会为每个虚拟机分配一个随机的本地 SSH 端口。您可以使用 `vagrant ssh-config` 命令来查看这些端口的映射：

```bash
$ vagrant ssh-config
Host web
  HostName 127.0.0.1
  User vagrant
  Port 2200
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /path/to/vagrant/private/key
  IdentitiesOnly yes

Host db
  HostName 127.0.0.1
  User vagrant
  Port 2201
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /path/to/vagrant/private/key
  IdentitiesOnly yes
```

Vagrant默认情况下不会将SSH配置添加到sshconfig文件中，因为这可能会干扰其他SSH设置。但是，您可以使用以下命令将Vagrant SSH配置添加到sshconfig文件中：

```bash
vagrant ssh-config --host <host-name> >> ~/.ssh/config
```