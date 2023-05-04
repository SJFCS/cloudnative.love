---
title: Networking
sidebar_position: 3
---
https://developer.hashicorp.com/vagrant/docs/networking

https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/networking

Vagrant 支持三种网络模型：
- 端口转发（Forwarded Ports）
- 私有网络（Private Network） 即 Host-Only/NAT 模式
- 公有网络（Public Network）  即 Bridge 桥接模式

在 Vagrantfile 配置文件中，使用 `config.vm.network` 配置虚拟机的网络，当然你可以指定多个网络。
然后通过`vagrant up` 启动或 `vagrant reload` 重载后，网络将自动配置和启用。

## 端口转发 forwarded_port

可以将宿主机上的端口映射到虚拟机中的端口，从而实现主机与虚拟机之间的端口转发

```ruby
Vagrant.configure("2") do |config|
  config.vm.usable_port_range = 8000..8999 # 检测到端口冲突时，您可以定义 Vagrant 可分配的允许端口范围。
  config.vm.network "forwarded_port",
    id: "web_server"          # 用于设置 VirtualBox 端口转发规则中的名称
    guest: 80,                # 虚拟机端口 （必选）
    host: 8080,               # 宿主机端口 （必选） 必须大于 1024
    protocol: "tcp",          # protocol参数指定协议类型：TCP(默认) 或 UDP
    guest_ip: "0.0.0.0",      # 绑定指定网卡，设置为 0.0.0.0，表示绑定到虚拟机的所有网卡上
    host_ip: "192.168.0.10",  # 绑定指定网卡，设置为 192.168.0.10，表示将端口转发到主机的该网卡上
    auto_correct: true        # 冲突自动更正
end
```

## 私有网络 private_network

私有网络（Private network），只有主机可以访问虚拟机，如果多个虚拟机设定在同一个网段也可以互相访问，当然虚拟机是可以访问外部网络的。设定语法为：

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "private_network", 
  type: "dhcp"
end
```

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "private_network", 
    ip: "192.168.33.10",
    auto_config: false # 默认值为 false，这意味着在创建新的网络适配器时，Vagrant 不会自动分配 IP 地址和子网掩码，而是需要手动配置网络设置。如果你想要自动配置网络，则需要将 auto_config 参数设置为 true。

end
```
 `virtualbox__intnet: false` c参考 https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/networking
```ruby
node.vm.network network_mode, ip: ip, virtualbox__intnet: false, auto_config: true
```

## 公有网络 public_network

Vagrant 公有网络对应 VirtualBox 的 Bridge 网络，虚拟机在宿主机所在的 LAN 中等价于一台物理机器。

dhcp:

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network",
  type: "dhcp"
  use_dhcp_assigned_default_route: true #可以使用让 Vagrant 给虚拟机配置原始的默认路由：
end
```

2）静态 IP

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network", ip: "192.168.0.17"
  config.vm.network "public_network", bridge: "en1: Wi-Fi (AirPort)"
end 
```
有些虚拟机管理器可以支持 Vagrant 配置多块网卡，然后使用第一块存在的网卡：

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network", bridge: [
    "en1: Wi-Fi (AirPort)",
    "en6: Broadcom NetXtreme Gigabit Ethernet Controller",
  ]
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

