---
title: Vagrant
tags: [Infrastructure as Code & Automation,HashiCorp,Vagrant]
---
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

```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end
    config.vm.define "node-1" do |node1|
        node1.vm.box = "ubuntu/trusty64"
        node1.vm.network "private_network", ip: "192.168.56.10"
        node1.vm.hostname = "node-1"
        node1.vm.provision "shell", inline: <<-SHELL
        echo "i'm node-1"
        sudo timedatectl set-timezone Asia/Shanghai
        SHELL
        end
    config.vm.define "node-2" do |node2|
        node2.vm.box = "ubuntu/trusty64"
        node2.vm.network "private_network", ip: "192.168.56.20"
        node2.vm.hostname = "node-2"
        node2.vm.provision "shell", inline: <<-SHELL
            sudo echo "192.168.10.21 puppet" | sudo tee -a /etc/hosts
            echo "i'm node-2"
            sudo timedatectl set-timezone Asia/Shanghai
        SHELL
    end
    config.vm.define "node-3" do |node3|
        node3.vm.box = "ubuntu/trusty64"
        node3.vm.network "private_network", ip: "192.168.56.30"
        node3.vm.hostname = "node-2"
        node3.vm.provision "shell", inline: <<-SHELL
            sudo echo "192.168.10.21 puppet" | sudo tee -a /etc/hosts
            echo "i'm node-3"
            sudo timedatectl set-timezone Asia/Shanghai
        SHELL
    end
end
```
## 定义虚拟机参数
```ruby
vb.customize ["modifyvm", :id, "--memory", "4096"]
vb.customize ["modifyvm", :id, "--cpus", "1"]
```

```ruby
vb.memory = "2048"
vb.cpus = 2
```
上面这两种定义方式有什么区别

这两种定义方式都是用来配置虚拟机的内存和 CPU 的。但是它们的具体实现方式略有不同：

`vb.customize` 是通过调用 VirtualBox 的命令行工具来修改虚拟机的配置参数。  
在这种方式下，`vb.customize ["modifyvm", :id, "--memory", "4096"]` 会执行以下命令：`VBoxManage modifyvm <id> --memory 4096`，其中 `<id>` 是虚拟机的 ID。这种方式可以通过自定义命令行参数来**灵活配置虚拟机**。

`vb.memory` 和 `vb.cpus` 更为方便，因为它是通过 Vagrant 提供的 API 直接配置虚拟机的内存和 CPU，可以跨平台使用。
而前者（使用 `vb.customize`）则需要使用 VirtualBox 的命令行工具，可能存在一些跨平台兼容性问题。因此，如果想要写跨平台的 Vagrantfile，建议使用此方式。

总的来说，这两种方式都可以用来配置虚拟机的内存和 CPU，选择哪种方式主要取决于具体的需求和使用习惯。如果需要自定义更多的 VirtualBox 参数，可能更适合使用 `vb.customize`；如果只需要简单地配置内存和 CPU，使用 `vb.memory` 和 `vb.cpus` 更为方便。

## 挂载目录
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


# device.vm.synced_folder  
#   "./share_dir", # 配置本地共享目录
#   "/vagrant",    # 配置虚拟机对应的挂载目录
#   create: true,  # 如果虚拟机上对应的文件夹不存在, 则创建
#   owner: "root", # 指定目录的所有者
#   group: "root", # 指定目录的所属组
#   mount_options: ["dmode=755", "fmode=644"], # 指定文件夹权限和文件权限
#   type: "rsync"  # 指定文件同步方式, 一般让系统选择, 不指定

```

  5.安装vbguest插件，（防止挂载失败，提示because the filesystem "vboxsf" is not available的问题，提前执行该命令安装插件）
vagrant plugin install vagrant-vbguest

**重新加载共享目录：**
如果在修改了共享目录中的文件后，需要重新加载共享目录，可以使用以下命令：
vagrant reload --provision



在默认情况下，文件同步会有一些性能问题，因为它是通过 VirtualBox 的共享文件夹功能实现的。如果需要更好的性能和可靠性，可以考虑使用其他文件同步方式，比如 NFS 或 rsync。例如，下面的配置将使用 NFS 来进行文件同步：

```ruby
# nfs
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/vagrant_data", type: "nfs"
end
```

```ruby
# rsync
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/vagrant_data", type: "rsync"
end
```
需要注意的是，使用 NFS 或 rsync 进行文件同步可能需要安装额外的软件，并且在不同的操作系统上配置方式可能会有所差异。



## 设置开机自动挂载和防止重新更新


由于我们上面安装好了Guest Additions,需要修改vagrantfile配置文件，以免下次启动时重复安装Guest Additions,在配置文件最后一个end前添加两行命令（新添加的配置需要使用vagrant reload重新加载配置）

```ruby
Vagrant.configure("2") do |config|

...
 
config.vbguest.auto_update = false #防止重新安装更新
 
config.vbguest.no_remote = true #不从远程web端下载

...
 
end
```

然后ssh连接到服务器。因为系统调用fstab的时候，Virtualbox的共享目录的模块还没有加载，所以我之前安装总是失败。最终的解决方案如下：在文件 /etc/rc.local 中（用root用户）追加如下命令

```bash
mount -t vboxsf sharing /mnt/share
```

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


## 免密
https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings

### 默认 vagrant ssh

在使用 vagrant ssh 命令连接虚拟机时，Vagrant 会检查本地的 SSH 配置文件，通常是 ~/.ssh/config 文件，以确定要使用的密钥文件路径。  
默认情况下，Vagrant 会在 SSH 配置文件中自动添加一个名为 "vagrant" 的主机条目，并将其配置为使用默认的 Vagrant 密钥文件路径。例如，在 Linux 和 macOS 上，Vagrant 会在 ~/.ssh/config 文件中添加以下条目：

```bash
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
在这个示例中，Vagrant 将使用 /path/to/vagrant/private/key 文件作为私钥文件，并将其用于身份验证。  
如果您使用的是不同的密钥文件，可以通过在 ~/.ssh/config 文件中添加自定义主机条目来指定它们的路径。例如：

当您使用 vagrant ssh 命令时，可以将 -c 选项与主机名一起使用来连接到正确的主机。例如：
```bash
vagrant ssh -c my-vagrant

```

如果在配置文件中没有指定密钥路径，则 Vagrant 会默认使用 ~/.vagrant.d/insecure_private_key 作为私钥，使用 ~/.vagrant.d/insecure_public_key 作为公钥。


### 指定密钥
```bash
$ cat ~/.ssh/id_rsa.pub | ssh -i ~/.ssh/id_rsa.pub -p 2222 vagrant@localhost 'cat >> .ssh/authorized_keys && echo "SSH key copied."'

$ ssh -i ~/.ssh/id_rsa.pub -p 2222 vagrant@localhost


```

这些默认的密钥文件是 Vagrant 在创建虚拟机时自动生成的，用于方便地进行 SSH 连接和管理。但是，在生产环境中，建议使用自己的密钥文件，以提高安全性。可以在 Vagrantfile 中设置 config.ssh.private_key_path 和 config.ssh.public_key_path 来指定自己的密钥文件路径，例如：

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.ssh.private_key_path = "~/.ssh/id_rsa"
  config.ssh.public_key_path = "~/.ssh/id_rsa.pub"
end
```
* The following settings shouldn't exist: public_key_path  
这个错误提示通常是由于在 Vagrantfile 中使用了 public_key_path 选项，但该选项在最新版的 Vagrant 中已经被废弃了。如果你使用的是较老的 Vagrant 版本，该选项可能仍然有效。  
public_key_path 选项用于指定 SSH 公钥文件的路径。在旧版的 Vagrant 中，该选项可以用来指定多个公钥文件路径，以便在虚拟机中进行 SSH 认证时使用。但在最新版的 Vagrant 中，该选项已被废弃，取而代之的是 authorized_keys 选项。

* The following settings shouldn't exist: authorized_keys  
这个错误提示通常是由于在 Vagrantfile 中使用了 authorized_keys 选项，但该选项在当前的 Vagrant 版本中已经被废弃了。如果你使用的是较老的 Vagrant 版本，该选项可能仍然有效。  
authorized_keys 选项用于指定需要添加到虚拟机中的 SSH 授权密钥。该选项支持多个密钥，可以将它们放到一个数组中进行指定。但在当前的 Vagrant 版本中，该选项已被废弃，取而代之的是 insert_key 选项。  
insert_key 选项用于指定是否将本地的 SSH 密钥添加到虚拟机中。该选项有三个取值：
  true：将本地的 SSH 密钥添加到虚拟机中；
- false：不将本地的 SSH 密钥添加到虚拟机中；
- "if-authorized"：只有在本地的 SSH 密钥已被添加到虚拟机中时才添加。


#### 貌似新版本不支持了。。用下面的方法
```ruby
  config.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
    SHELL
  end
```
这个工作示例附加~/.ssh/id_rsa.pub到~/.ssh/authorized_keysvagrant 和 root 用户，这将允许您使用现有的 SSH 密钥。

或者：

复制所需的公钥将直接进入[供应](https://developer.hashicorp.com/vagrant/docs/provisioning)阶段。确切的答案取决于您喜欢使用什么配置（shell、Chef、Puppet 等）。最微不足道的是file密钥的配置器，如下所示：
```ruby
config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"


Vagrant.configure(2) do |config|
  # ... other config
  config.vm.provision "shell", inline: <<-SHELL
    cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
  SHELL
  # ... other config
end
```
### 添加免密
在 Vagrantfile 中使用以下代码可以将本机的 ~/.ssh/id_rsa.pub 添加到虚拟机内：
```ruby
config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /home/vagrant/.ssh
    cat /vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
    # wget --no-check-certificate \
    # 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    # -O /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/authorized_keys
  SHELL
```
这段代码会在虚拟机启动时执行，首先创建 /home/vagrant/.ssh 目录，然后将本机的 ~/.ssh/id_rsa.pub 内容追加到 /home/vagrant/.ssh/authorized_keys 中，最后设置权限和所有权。这样就可以使用本机的私钥登录虚拟机了。

### 配置添加到sshconfig文件中

Vagrant默认情况下不会将SSH配置添加到sshconfig文件中，因为这可能会干扰其他SSH设置。但是，您可以使用以下命令将Vagrant SSH配置添加到sshconfig文件中：

```bash
vagrant ssh-config --host <host-name> >> ~/.ssh/config
```
其中，`<host-name>`是您在Vagrantfile中定义的主机名称。该命令将Vagrant SSH配置附加到sshconfig文件中的末尾，而不会覆盖现有配置。这使您可以轻松地管理多个SSH配置，并避免冲突。



在这个例子中，Vagrant 会使用 ~/.ssh/id_rsa 作为私钥，使用 ~/.ssh/id_rsa.pub 作为公钥。当使用 vagrant ssh 命令连接虚拟机时，Vagrant 会自动使用这些密钥文件进行身份验证。



### ssh 配置

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

## vscode server


```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64" # 使用 Ubuntu 20.04 镜像
  config.vm.network "forwarded_port", guest: 8080, host: 8080 # 映射端口

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048" # 内存大小
    vb.cpus = "2" # CPU 数量
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y curl
    curl -fsSL https://code-server.dev/install.sh | sh # 安装 VSCode Server
    sudo systemctl enable --now code-server # 启动 VSCode Server
  SHELL
end
```
该Vagrantfile将创建一个Ubuntu 20.04虚拟机，并在其中安装VSCode Server。它会下载VSCode Server二进制文件，安装它，配置它，并在远程主机上启动它。它还会将端口8080映射到远程主机的8080端口，以便可以通过浏览器访问VSCode Server。


## 复用配置，循环创建主机

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
