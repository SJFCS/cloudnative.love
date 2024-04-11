---
title: Networking
sidebar_position: 3
---
:::tip 参考文档
- https://developer.hashicorp.com/vagrant/docs/networking
- https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/networking
:::

Vagrant 支持三种网络模型：
- 端口转发（Forwarded Ports） 即 网络地址转 (NAT) 模式
- 私有网络（Private Network） 即 Host-Only 模式
- 公有网络（Public Network）  即 Bridge 桥接模式

在 Vagrantfile 配置文件中，使用 `config.vm.network` 配置虚拟机的网络，当然你可以指定多个网络，但一台机器不能配置超过一个DHCP网卡。

然后通过`vagrant up` 启动或 `vagrant reload` 重载后，网络将自动配置和启用。注意 `vagrant destroy` 时不会删除 VirtualBox 主机网络管理器中的网络，需要手动清理。


## 端口转发 forwarded_port

可以将宿主机上的端口映射到虚拟机中的端口，从而实现主机与虚拟机之间的端口转发

providers 为 VirtualBox 时默认添加一块网络地址转换（NAT）模式的网卡用于将虚拟机 22 端口映射到主机，并且可以通过此网卡访问外网。

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.usable_port_range = 8000..8999 #（可选）检测到端口冲突时，您可以定义 Vagrant 可分配的允许端口范围。
  config.vm.network "forwarded_port",
    id: "web_server"          # （可选）用于设置 VirtualBox 端口转发规则中的名称
    guest: 80,                # （必选）虚拟机端口 
    host: 8080,               # （必选）宿主机端口  必须大于 1024
    protocol: "tcp",          # （可选）protocol参数指定协议类型：TCP(默认) 或 UDP
    guest_ip: "0.0.0.0",      # （可选）绑定指定网卡，设置为 0.0.0.0，表示绑定到虚拟机的所有网卡上
    host_ip: "192.168.0.10",  # （可选）绑定指定网卡，设置为 192.168.0.10，表示将端口转发到主机的该网卡上
    auto_correct: true        # （可选）端口冲突自动更正
end
```

## 私有网络 private_network

providers 为 VirtualBox 时，通过 `管理->主机网络管理器` 或者 `Ctrl+H` 打开 `主机网络管理器` 可查看创建的网络。选中虚拟机后 `右键 设置` 或者 `Ctrl+S` 查看虚拟机的网络选项卡。


```ruby
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.network "private_network", 
    ip: "192.168.97.10",
    netmask: "255.255.0.0",
    auto_config: false # 默认值为 false，这意味着在创建新的网络适配器时，Vagrant 不会自动分配 IP 地址和子网掩码，而是需要手动配置网络设置。如果你想要自动配置网络，则需要将 auto_config 参数设置为 true。


    config.vm.network "private_network", 
    type: "dhcp", 
    name: "my_network",  # 可以手动创建网络 然后在此指定
    ip: "192.168.50.10", # 如果设置了 dhcp 则此项会识别为网段，IP由dhcp随机分配
    netmask: "255.255.255.0"
end
```

## 公有网络 public_network

用于桥接宿主机网卡

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network",
  type: "dhcp"
  use_dhcp_assigned_default_route: true #可以使用让 Vagrant 给虚拟机配置原始的默认路由： 否应用DHCP分配的默认路由
  
  config.vm.network "public_network", ip: "192.168.0.17" # 指定IP
  config.vm.network "public_network", bridge: "en1: Wi-Fi (AirPort)"   # 指定桥接网卡名
end
```


## 设置主机名
可以使用该设置为 Vagrant VM 定义主机名config.vm.hostname 。默认情况下，这将修改/etc/hosts，在未使用的环回接口上添加主机名。例如：

```ruby
Vagrant.configure("2") do |config|
  # ...
  config.vm.hostname = "myhost.local"
end
```

将条目添加127.0.X.1 myhost myhost.local到/etc/hosts.

具有分配 IP 的公共或专用网络可能会被标记为主机名。在这种情况下，主机名将被添加到标记的网络中。请注意，如果有多个网络，则只有一个可以标记为主机名。例如：
```ruby
Vagrant.configure("2") do |config|
  # ...
  config.vm.hostname = "myhost.local"
  config.vm.network "public_network", ip: "192.168.0.1", hostname: true
  config.vm.network "public_network", ip: "192.168.0.2"
end
```
将条目添加192.168.0.1 myhost myhost.local到/etc/hosts.
