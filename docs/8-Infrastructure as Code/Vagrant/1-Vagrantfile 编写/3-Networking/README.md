---
title: Networking
sidebar_position: 3
---
https://www.vagrantup.com/docs/networking/

在 Vagrantfile 配置文件中，使用config.vm.network配置虚拟机的网络。Vagrant 支持三种网络模型：端口转发（Forwarded Ports）、私有网络（Private Network）和公有网络（Public Network），他们和多数虚拟机提供的网络模型是对应的。下面我们来详细分析 Vagrant 的网络配置。

## 端口转发 forwarded_port

端口映射(Forwarded port)，顾名思义是指把宿主计算机的端口映射到虚拟机的某一个端口上，访问宿主计算机端口时，请求实际是被转发到虚拟机上指定端口的。Vagrantfile中设定语法为：
```ruby
Vagrant.configure("2") do |config|
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 80, host: 8080
end
```
host的端口号必须大于 1024，除非使用 root 用户运行 Vagrant（不建议这么做）；
端口转发默认绑定所有网卡，可以通过指定 guest_ip 和 host_ip 绑定指定网卡：
端口转发支持 TCP 和 UDP，默认是 TCP 协议，可以protocol参数指定协议类型：
端口转发在 VirtualBox 中的创建一条名称是“protocol
guest”的记录，这里是“tcp80”，可以使用id参数修改记录名称。

## 私有网络 private_network


私有网络（Private network），只有主机可以访问虚拟机，如果多个虚拟机设定在同一个网段也可以互相访问，当然虚拟机是可以访问外部网络的。设定语法为：

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "private_network", type: "dhcp"
end
```

```ruby
Vagrant.configure("2") do |config|
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
      auto_config: false

end
```
Vagrant 默认在虚拟机启动时自动配置私有网络，可以设置auto_config: false禁止这一行为：


## 公有网络 public_network


Vagrant 公有网络对应 VirtualBox 的 Bridge 网络，虚拟机在宿主机所在的 LAN 中等价于一台物理机器。



dhcp:

```ruby
Vagrant.configure("2") do |config|
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"
end
```
可以使用use_dhcp_assigned_default_route: true让 Vagrant 给虚拟机配置原始的默认路由：

2）静态 IP

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network", ip: "192.168.0.17"
end 
```
指定默认网卡 
config.vm.network "public_network", :bridge => 'en1: Wi-Fi (AirPort)'
有些虚拟机管理器可以支持 Vagrant 配置多块网卡，然后使用第一块存在的网卡：

```ruby
Vagrant.configure("2") do |config|
  config.vm.network "public_network", bridge: [
    "en1: Wi-Fi (AirPort)",
    "en6: Broadcom NetXtreme Gigabit Ethernet Controller",
  ]
end
```