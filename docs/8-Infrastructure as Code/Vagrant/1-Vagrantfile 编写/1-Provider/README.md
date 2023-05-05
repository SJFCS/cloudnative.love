---
title: Provider
sidebar_position: 1
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Vagrant 支持多种 Provider  如 VirtualBox,VMware,Hyper-V,阿里云,AWS,Shell,Ansible,File 等等。

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

<!-- ## 兼容多个 Provider 的示例：

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

使用循环可以使配置更加简洁和易于维护，特别是当需要兼容多个 Provider 时。 -->

