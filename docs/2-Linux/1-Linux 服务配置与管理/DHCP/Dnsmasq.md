---
title: Dnsmasq
sidebar_position: 2
---
dnsmasq 是一种轻量级 DNS 和 DHCP 服务器，它可以用于简单的网络环境中。下面是一个 dnsmasq 的配置案例，其中包含了 DNS 和 DHCP 的配置。

1.安装 dnsmasq

如果你的系统没有安装 dnsmasq，请先安装它。以 Ubuntu 为例，可以使用以下命令安装：

```
sudo apt-get install dnsmasq
```

**配置 DNS**

首先，你需要配置 dnsmasq 作为 DNS 服务器。你可以编辑 /etc/dnsmasq.conf 文件来进行配置。以下是一个示例配置：

```conf
# Listen on the loopback interface
listen-address=127.0.0.1

# Set the domain name
domain=example.com

# Configure the DNS server
server=8.8.8.8
server=8.8.4.4

# Configure DNS caching
cache-size=10000
```


这个配置文件中，我们设置 dnsmasq 监听在本地回环接口上，设置了一个域名 example.com，指定了两个 DNS 服务器（8.8.8.8 和 8.8.4.4），并启用了 DNS 缓存。


**配置 DHCP**

接下来，你需要为你的网络配置 DHCP 服务器。你也可以编辑 /etc/dnsmasq.conf 文件来进行配置。以下是一个示例配置：

```conf
# Set the DHCP range
dhcp-range=192.168.1.50,192.168.1.150,12h

# Set the gateway and DNS server
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1

# Set the lease time
dhcp-lease-max=50
dhcp-lease-time=1h

# Set the hostname
dhcp-host=00:11:22:33:44:55,john-pc,192.168.1.100
```


这个配置文件中，我们设置了 DHCP 范围为 192.168.1.50 到 192.168.1.150，租约时间为 12 小时。我们还设置了默认网关和 DNS 服务器为 192.168.1.1，租约最大数量为 50 个，租约时间为 1 小时。最后，我们还设置了一个主机名为 john-pc，MAC 地址为 00:11:22:33:44:55，IP 地址为 192.168.1.100。

启动 dnsmasq
完成配置后，你需要启动 dnsmasq 服务。以 Ubuntu 为例，可以使用以下命令启动：
```bash
sudo service dnsmasq start
```

现在，你的 dnsmasq 服务器已经配置完成了，可以使用它来提供 DNS 和 DHCP 服务了。



## 问题

客户端需要进行以下配置才能实现DHCP动态DNS更新 （通过安全认证的方式）
