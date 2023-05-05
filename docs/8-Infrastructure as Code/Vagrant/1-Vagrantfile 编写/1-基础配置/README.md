---
title: 基础配置
sidebar_position: 1
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

- https://github.com/wizardbyron/provisioners
- https://www.itwonderlab.com/en/ansible-kubernetes-vagrant-tutorial/
- https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/
- https://github.com/kodekloudhub/certified-kubernetes-administrator-course/tree/master
- https://github.com/mmumshad/kubernetes-the-hard-way
- https://github.com/ddometita/mmumshad-kubernetes-the-hard-way/tree/master/vagrant
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster
- https://github.com/contiv/netplugin/blob/master/Vagrantfile


## 定义虚拟机规格

<Tabs>
<TabItem value="通用方式">

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    #  highlight-start
    v.memory = "1024"
    v.cpus = "1"
    #  highlight-end
  end
end
```

</TabItem>
<TabItem value="VirtualBox customize 方式">

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
    config.vm.provider "virtualbox" do |v|
    #  highlight-start
    v.customize ["modifyvm", :id, "--memory", "4096"]
    v.customize ["modifyvm", :id, "--cpus", "1"]
    #  highlight-end
  end
end
```

</TabItem>
</Tabs>


:::tip 上面这两种定义方式有什么区别

这两种定义方式都是用来配置虚拟机的内存和 CPU 的。但是它们的具体实现方式略有不同：

- `v.customize` 是通过调用 VirtualBox 的命令行工具来修改虚拟机的配置参数。  
在这种方式下，`v.customize ["modifyvm", :id, "--memory", "4096"]` 会执行以下命令：`VBoxManage modifyvm <id> --memory 4096`，其中 `<id>` 是虚拟机的 ID。这种方式可以通过自定义命令行参数来**灵活配置虚拟机**。

- `v.memory` 和 `v.cpus` 更为方便，因为它是通过 Vagrant 提供的 API 直接配置虚拟机的内存和 CPU，**可以跨平台使用**。
:::


## 常用设置
```ruby
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
```


## 多机示例

### 循环
一个简单的示例：
```ruby
  Vagrant.configure("2") do |config|
      for i in 1..3 do
        config.vm.define "node-#{i}" do |node|
        node#{i}.vm.box = "ubuntu/focal64"
          node.vm.provision "shell",
            inline: "echo hello from node #{i}"
        end
      end
  end
```

### 多机
`config.vm.define`是Vagrantfile配置文件中用于定义虚拟机的名称和设置的命令。它允许用户定义多个虚拟机并为每个虚拟机定义不同的配置。

例如，以下是一个Vagrantfile配置文件的示例，其中定义了两个虚拟机：web和db。

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/xenial64"
    web.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/xenial64"
    db.vm.network "private_network", ip: "192.168.33.11"
  end
end

```
在上面的配置文件中，config.vm.define命令定义了两个虚拟机：web和db。每个虚拟机都有自己的配置，例如操作系统镜像和网络设置。这使得用户能够在同一个Vagrantfile中定义多个虚拟机，从而简化了配置和管理。


### 声明配置

您可以使用循环来定义多个虚拟机，同时使用另一个文件来存储共享的配置。例如：

1.在Vagrantfile中创建一个数组，其中包含要定义的虚拟机名称。

```ruby
servers = [
  {name: "server1", ip: "192.168.33.10"},
  {name: "server2", ip: "192.168.33.11"},
  {name: "server3", ip: "192.168.33.12"}
]

```
2.使用循环来定义每个虚拟机，并从另一个文件中读取共享的配置。

```ruby
servers.each do |server|
  config.vm.define server[:name] do |node|
    node.vm.box = "ubuntu/trusty64"
    node.vm.hostname = server[:name]
    node.vm.network "private_network", ip: server[:ip]
    node.vm.provision "shell", path: "provision.sh"
    node.vm.provision "shell", inline: File.read("shared_provisioning.sh")
    # 其他节点特定配置
    if name == "node1"
      # ...
    elsif name == "node2"
      # ...
    else
      # ...
    end
  end
end
```


## 覆盖配置

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box = "centos/7"
  end
end

```
在上述情况下，Vagrant 将默认使用“ubuntu/trusty64”，但如果使用 VMware Fusion 提供程序，则会使用“centos/7”。

## 兼容多个 Provider 的示例：

<Tabs>
<TabItem value="全局配置">

一般情况下我们可以将 `vm.provider` 定义为全局配置。示例如下：
```ruby
Vagrant.configure("2") do |config|
  # Provider 列表
  providers = ["virtualbox", "vmware_fusion"]
  # 循环每个 Provider
  providers.each do |provider|
    # 配置 Provider
    config.vm.provider provider do |v|
      v.memory = "1024"
      v.cpus = 2
    end
  end

  # 添加共同的配置到每个 Provider
  config.vm.define "web" do |web|
    # 共同的配置
    config.vm.box = "ubuntu/xenial64"
    config.vm.network "private_network", ip: "192.168.33.10"
    web.vm.provision "shell", path: "bootstrap.sh"
    web.vm.hostname = "web"
  end
end
```

</TabItem>
<TabItem value="利用循环简化配置">

我们可以使用循环来简化配置。以下是一个使用循环兼容多个 Provider 的示例：
```ruby
Vagrant.configure("2") do |config|
  #  highlight-start
  # Provider 列表
  providers = ["virtualbox", "vmware_fusion"]
  # 循环每个 Provider
  providers.each do |provider|
    # 配置 Provider
    config.vm.provider provider do |v|
      v.memory = "1024"
      v.cpus = 2
    end
  #  highlight-end
    # 共同的配置
    config.vm.box = "ubuntu/xenial64"
    config.vm.network "private_network", ip: "192.168.33.10"
    # 添加共同的配置到每个 Provider
    config.vm.define "web" do |web|
      web.vm.provision "shell", path: "bootstrap.sh"
      web.vm.hostname = "web"
    end
  # highlight-next-line
  end
end
```

在上述示例中，我们首先定义了一个 Provider 列表，其中包括 VirtualBox 和 VMware Fusion。然后，我们使用循环迭代每个 Provider，并为每个 Provider 配置相应的选项。共同的配置被添加到每个 Provider 中，以确保在任何 Provider 上都有相同的配置。最后，我们使用共同的配置为名为 "web" 的虚拟机定义了一些新的配置，例如执行一个 shell 脚本，设置主机名等。

</TabItem>
</Tabs>

使用循环可以使配置更加简洁和易于维护，特别是当需要兼容多个 Provider 时。



## ssh 配置
### 用户名密码登录
```
#  官方提供的镜像的账号都是不允许远程登录的，所有配官方镜像的congfig不应该添加config.ssh.username参数，否则创建虚拟机时多次尝试ssh登录，都会失败，浪费大量时间
#  个人镜像设置远程登录了，可以使用username和password参数
Vagrant.configure("2") do |config|
  config.ssh.username = "user"
  config.ssh.password = "password"
end

请注意，您需要确保这些用户存在于来宾操作系统上
```

```
mkdir -p /home/hgp/vagrant/centos
cd /home/hgp/vagrant/centos
vagrant init
# 此时目录下面生成Vagrantfile文件，修改里面的几个参数，例如 config.vm.box 改成本地镜像仓库的镜像名，否则在当前目录查找镜像
# config.vm.network :private_network, ip: "192.168.57.101"
# config.vm.box = "centos-7.3"
# config.vm.boot_timeout = 360
# config.ssh.username = "root"
# config.ssh.password = "root"
# vb.gui = true
```

```
# 修改PubkeyAuthentication 和 PasswordAuthentication 参数
PubkeyAuthentication yes #这两项为打开公钥模式
PasswordAuthentication yes #打开密码验证模式
# 重启sshd服务
systemctl restart sshd
```


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


https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings

## 指定账号密码登录
```ruby
    manager1.ssh.username = "vagrant"
    manager1.ssh.password = "vagrant"
    manager1.ssh.insert_key = false
然后修改指定位置的配置文件
vi /etc/ssh/sshd_config
找到passwordAuthentication 把no修改为yes
修改成功之后重启服务
service sshd restart
```

## 默认 vagrant ssh


```bash
$ vagrant ssh-config
Host vagrant
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /path/to/vagrant/private/key
  IdentitiesOnly yes
```


如果在配置文件中没有指定密钥路径，则 Vagrant 会默认使用 ~/.vagrant.d/insecure_private_key 作为私钥，使用 ~/.vagrant.d/insecure_public_key 作为公钥 https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub。


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


复制所需的公钥将直接进入[provisioning](https://developer.hashicorp.com/vagrant/docs/provisioning)阶段。

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  #  highlight-start
  config.ssh.insert_key = false
  config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
  #  highlight-start
end
```
上面代码中

## 配置添加到sshconfig文件中

Vagrant默认情况下不会将SSH配置添加到sshconfig文件中，因为这可能会干扰其他SSH设置。但是，您可以使用以下命令将Vagrant SSH配置添加到sshconfig文件中：

```bash
vagrant ssh-config --host <host-name> >> ~/.ssh/config
```
其中，`<host-name>`是您在Vagrantfile中定义的主机名称。该命令将Vagrant SSH配置附加到sshconfig文件中的末尾，而不会覆盖现有配置。这使您可以轻松地管理多个SSH配置，并避免冲突。



在这个例子中，Vagrant 会使用 ~/.ssh/id_rsa 作为私钥，使用 ~/.ssh/id_rsa.pub 作为公钥。当使用 vagrant ssh 命令连接虚拟机时，Vagrant 会自动使用这些密钥文件进行身份验证。



## vagrant 使用自定义密钥  而不是其非安全密钥
Vagrant 默认使用非安全密钥（insecure key）作为默认的 SSH 密钥来连接虚拟机。这个密钥是公开的，因此任何人都可以使用它连接到你的虚拟机。为了提高安全性，你可以使用自己的密钥来代替 Vagrant 的非安全密钥。



```ruby
node1.ssh.insert_key = false
node1.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
node1.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"

```
将config.ssh.insert_key设置为false将禁用Vagrant默认的非安全私钥，并使用指定的自定义私钥替换它。同时，将config.ssh.public_key_path设置为相应的公钥路径以确保SSH连接可以正常工作。



