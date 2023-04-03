---
title: Vagrant
tags: [Infrastructure as Code & Automation,HashiCorp,Vagrant]
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import DocCardList from '@theme/DocCardList';


<DocCardList />


- 简介
- 官网
- 区别优势
- 基本概念

virtuabox: https://linuxhint.com/install-virtualbox-arch-linux/

自动完成
Vagrant 提供了自动完成命令的能力。目前 支持bash和shell。zsh这些可以通过运行启用 vagrant autocomplete install --bash --zsh。


destroy只删除虚拟机而不会删除box 如果想删除box 请运行 vagrant box remove xx
https://stackoverflow.com/questions/16647069/should-i-use-vagrant-or-docker-for-creating-an-isolated-environment



todo
- vagrant 模板 循环创建，常用脚本
- git gpg签名
- ssh密钥
- https://github.com/wizardbyron/provisioners/projects/1
- ansible
- https://github.com/lvthillo/vagrant-ansible-kubernetes
- https://www.itwonderlab.com/en/ansible-kubernetes-vagrant-tutorial/
- https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/
推荐参考 https://github.com/kodekloudhub/certified-kubernetes-administrator-course/blob/master/ubuntu/vagrant/setup-hosts.sh

End kernel panic - not syncing attempted to kill the idle task

Linux内核kernel panic

调整内存 cpu 开启嵌套分页 PAE/NX  ：Enable IO APIC和Enable PAE/NX

Vagrant常用命令：https://curder.gitbooks.io/blog/content/tools/vagrant/vagrant-common-commands.html?q=
vbox参数文档：https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/configuration
hVagrantfile参考文件：ttps://github.com/ddometita/mmumshad-kubernetes-the-hard-way/blob/master/vagrant/Vagrantfile


## quick start
下面是一个**最小 Vagrant 示例**：

- 安装 [Vagrant](https://developer.hashicorp.com/vagrant/downloads) 和 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)。如果遇到兼容性问题可以下载 [VirtualBox 历史版本](https://www.virtualbox.org/wiki/Download_Old_Builds)。

:::tip
Vagrant 将虚拟机镜像成为 Box
- 在此网址寻找要使用的镜像 https://app.vagrantup.com/boxes/search

:::
- 创建一个目录并进入该目录。
- 初始化 Vagrant 环境：
  ```bash
  vagrant init ubuntu/trusty64
  ```
- 编辑 Vagrantfile 文件，添加网络配置：
  ```ruby
  Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.network "private_network", ip: "192.168.56.10"
  end
  ```
**基础命令**：

  ```bash
  vagrant up      # 启动虚拟机
  vagrant ssh     # 连接虚拟机
  vagrant halt    # 关闭虚拟机
  vagrant destroy # 删除虚拟机
  ```



##  vagrantfile 配置
### 定义虚拟机规格

<Tabs>
<TabItem value="方式1">

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
<TabItem value="方式2">

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
</Tabs>


:::tip 上面这两种定义方式有什么区别

这两种定义方式都是用来配置虚拟机的内存和 CPU 的。但是它们的具体实现方式略有不同：

- `v.customize` 是通过调用 VirtualBox 的命令行工具来修改虚拟机的配置参数。  
在这种方式下，`v.customize ["modifyvm", :id, "--memory", "4096"]` 会执行以下命令：`VBoxManage modifyvm <id> --memory 4096`，其中 `<id>` 是虚拟机的 ID。这种方式可以通过自定义命令行参数来**灵活配置虚拟机**。

- `v.memory` 和 `v.cpus` 更为方便，因为它是通过 Vagrant 提供的 API 直接配置虚拟机的内存和 CPU，**可以跨平台使用**。
:::

### 复用配置，循环创建主机

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



https://developer.hashicorp.com/vagrant/docs/vagrantfile/tips

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
3.创建一个名为"shared_provisioning.sh"的文件，其中包含要在所有虚拟机上运行的共享配置。
```bash
#!/bin/bash

# 共享配置
sudo timedatectl set-timezone Asia/Shanghai
# 更新apt包索引并安装包以允许apt通过 HTTPS 使用存储库：
sudo apt-get update
sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
# 添加 Docker 的官方 GPG 密钥：
sudo mkdir -m 0755 -p /etc/apt/keyrings
# 使用以下命令设置存储库：
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# 安装 Docker 引擎
sudo chmod a+r /etc/apt/keyrings/docker.gpg #避免默认umask可能配置不正确，导致无法检测存储库公钥文件
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker vagrant
```

这样，您就可以轻松地扩展Vagrant配置，而无需重复编写相同的代码。


```ruby
https://stackoverflow.com/questions/28471542/cant-ssh-to-vagrant-vms-using-the-insecure-private-key-vagrant-1-7-2

hosts = {
  "host0" => "192.168.33.10",
  "host1" => "192.168.33.11",
  "host2" => "192.168.33.12"
}

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.ssh.private_key_path = File.expand_path('~/.vagrant.d/insecure_private_key')

  hosts.each do |name, ip|
    config.vm.define name do |machine|
      machine.vm.hostname = "%s.example.org" % name
      machine.vm.network :private_network, ip: ip
      machine.vm.provider "virtualbox" do |v|
          v.name = name
      #    #v.customize ["modifyvm", :id, "--memory", 200]
      end
    end
  end
end
```

### 覆盖配置

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box = "centos/7"
  end
end

```
在上述情况下，Vagrant 将默认使用“ubuntu/trusty64”，但如果使用 VMware Fusion 提供程序，则会使用“centos/7”。

### 兼容多个 Provider 的示例：

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

### 挂载目录
```ruby
config.vm.synced_folder   
   "your_folder"(必须)   //物理机目录，可以是绝对地址或相对地址，相对地址是指相对与vagrant配置文件所在目录
  ,"vm_folder(必须)"    // 挂载到虚拟机上的目录地址
  ,create(boolean)--可选     //默认为false，若配置为true，挂载到虚拟机上的目录若不存在则自动创建
  ,disabled(boolean):--可选   //默认为false，若为true,则禁用该项挂载
  ,owner(string):'www'--可选   //虚拟机系统下文件所有者(确保系统下有该用户，否则会报错)，默认为vagrant
  ,group(string):'www'--可选   //虚拟机系统下文件所有组( (确保系统下有该用户组，否则会报错)，默认为vagrant
  ,mount_options(array):["dmode=775","fmode=664"]--可选  //dmode配置目录权限，fmode配置文件权限  默认权限777
  ,type(string):--可选     //指定文件共享方式，例如：'nfs'，vagrant默认根据系统环境选择最佳的文件共享方式
```

```ruby
config.vm.define "master" do |device|
  device.vm.network "private_network", ip: "192.168.3.100"
  device.vm.hostname = "master"
  device.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "master"
  end
  device.vm.synced_folder "./share_dir", "/vagrant", create: true, owner: "root", group: "root", mount_options: ["dmode=755","fmode=644"], type: "rsync"
end

```

vagrant-vbguest是一个Vagrant插件，它会自动在来宾系统上安装主机的 VirtualBox Guest Additions。
- https://github.com/dotless-de/vagrant-vbguest

```
vagrant plugin install vagrant-vbguest
```

```
vagrant reload --provision
```


在默认情况下，文件同步会有一些性能问题，因为它是通过 VirtualBox 的共享文件夹功能实现的。如果需要更好的性能和可靠性，可以考虑使用其他文件同步方式，比如 NFS 或 rsync。例如，下面的配置将使用 NFS 来进行文件同步：

需要注意的是，使用 NFS 或 rsync 进行文件同步可能需要安装额外的软件，并且在不同的操作系统上配置方式可能会有所差异。

然后ssh连接到服务器。因为系统调用fstab的时候，Virtualbox的共享目录的模块还没有加载，所以我之前安装总是失败。最终的解决方案如下：在文件 /etc/rc.local 中（用root用户）追加如下命令

```bash
mount -t vboxsf sharing /mnt/share
```




### ssh 配置
#### 用户名密码登录
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

### 指定账号密码登录
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

### 默认 vagrant ssh


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

### 配置添加到sshconfig文件中

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





## vagrant 管理
### 快照

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

### 不想在 vagrant reload 的时候重复的运行一些任务

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
