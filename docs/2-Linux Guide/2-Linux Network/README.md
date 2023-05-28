---
title: Linux Network
---
如果使用 ifupdown 来管理网络接口，需要手动编写 /etc/network/interfaces 文件，并使用 ifup 和 ifdown 命令来启用或禁用网络接口。而如果使用 NetworkManager 或 systemd-networkd 等工具，

- [Guide to the Linux Tutorials-TCP/IP networking reference guide (Linux 教程指南-TCP/IP 网络参考指南章节)](http://www.penguintutor.com/linux/basic-network-reference)  
  这篇关于网络的文章写的很简洁易懂。
- http://www.tcpipguide.com/
  
二层mac 三层路由 内核转发

https://lartc.org/


- ipvs,iptables  基本了解 
- https://icloudnative.io/posts/ipvs-how-kubernetes-services-direct-traffic-to-pods/
- https://dudashuang.com/load-blance/
- https://www.youtube.com/watch?v=lkXLsD6-4jA
- https://jishuin.proginn.com/p/763bfbd5f406
- https://blog.51cto.com/search/user?uid=11441275&q=lvs
- https://www.zsythink.net/archives/2134
- https://www.qikqiak.com/post/how-to-use-ipvs-in-kubernetes/
- https://space.bilibili.com/500659532
- https://www.cnblogs.com/luozhiyun/p/13782077.html
  linux 内核调优，熟悉内核堆栈报报告,能分析coredump
  存储各种方案和linux集成,以及i稳定性和debug
  网络,云网融合解决方案,sdn,cni,neutron等,个种网络协议原理和排错，ISP网络+overlay，SDN，网络基础,tcp/ip协议栈,vlan,vxlan,熟悉tcpdump,wireshark,分析网络问题,reg
  熟悉进程,文件系统,网络常见系统调用,strace/gdb等工具分析程序行为
  熟悉网络栈，内核网络参数工作原理,虚拟网络设备工作原理
  属虚linux存储和文件系统，能分析定位影响应用IO性能的因素
  熟悉namespace,cgroup,upstart,systemd等概念
  熟悉rpm,deb等发行包的制作
  openstack,kvm,SDN，linuxbridge,OVS,libvirt 镜像制作 cloud-init,
  EBPF
  基于linux实现vxlan和bgp
  网卡绑定

# 配置网络

## 选择网络配置工具

配置「Linux 操作系统」的网络有以下几款主流的配置工具可供选择：

| 配置工具 | 简介 |
| --- | --- |
| systemd-networkd | systemd 是许多发行版默认的 init 程序，其中 systemd-networkd 组件可用于网络配置管理，配置文件在 `/etc/systemd/network/`。 |
| ifupdown | Debian 标准的网络配置工具，配置文件在 `/etc/network/interfaces`。 |
| NetworkManager | 一款容易上手的网络配置工具，使用 `nmcli` 和 `nmtui` 进行配置，并支持图形界面，很多桌面版 Linux 使用此工具。 |
| netplan | 通过 YAML 文件管理网络配置，支持 systemd-networkd 和 NetworkManager 作为后端程序，配置文件在 `/etc/netplan/*.yaml`。(Ubuntu Server 18.04 默认使用此工具) |

桌面环境建议使用 NetworkManager；在服务器上建议使用默认的配置工具，或者切换到 systemd-networkd。

### iproute2

iproute2 是「Linux 操作系统」上强大的网络工具，例如 `ip address`、`ip route` 命令可用于查看主机网络信息。但是这种底层网络工具配置起来有些麻烦，我们会在下一节介绍它。

## 准备工作

首先敲 `ip address` 查看一下网卡信息。

进行网络配置之前先看看操作系统有哪些程序已经在工作了，避免造成冲突。比如查看一下相关的配置文件：

```
wc -l /etc/systemd/network/*.network /etc/network/interfaces /etc/netplan/*.yaml
grep -v '^#' /etc/systemd/network/*.network /etc/network/interfaces /etc/netplan/*.yaml
```

选用一款配置工具即可，将不需要的配置文件处理掉。

!!! warning
    通过网络连接到计算机时，进行网络配置要非常小心，操作不当将会很尴尬。

## 配置网络

### systemd-networkd

在 `/etc/systemd/network` 目录下创建 `.network` 文件，例如 `/etc/systemd/network/50-eth0.network`。下面是 eth0 网卡使用 DHCP 的配置：

```
[Match]
Name=eth0

[Network]
DHCP=ipv4
```

使用「静态 IP 地址」的配置：

```
[Match]
Name=eth0

[Network]
Address=192.168.0.15/24
Gateway=192.168.0.1
DNS=119.29.29.29
DNS=223.5.5.5
```

然后启动 systemd-networkd 服务使配置生效，并设置为开机启动：

``` shell
sudo systemctl restart systemd-networkd
sudo systemctl enable systemd-networkd
```

### ifupdown

编辑 `/etc/network/interfaces`，下面是 eth0 网卡使用 DHCP 的配置：

```
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
```

使用「静态 IP 地址」的配置：

```
auto eth0
iface eth0 inet static
  address 192.168.0.15/24
  gateway 192.168.0.1
  dns-nameservers 119.29.29.29 223.5.5.5
```

配置文件变更以后，输入下面的命令使配置生效：

``` shell
sudo ifdown eth0; sudo ifup eth0
```

### netplan

编辑 `/etc/netplan/config.yaml`，下面是 eth0 网卡使用 DHCP 的配置：

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
```

使用「静态 IP 地址」的配置：

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.0.15/24
      gateway4: 192.168.0.1
      nameservers:
          addresses: [119.29.29.29, 223.5.5.5]
```

配置文件变更以后，输入下面的命令使配置生效：

``` shell
sudo netplan apply
```

## 配置 DNS

按照上面的网络配置，通过 DHCP 获取或者静态配置的方式设定了 DNS，相应的后端程序读取配置后，将「DNS服务器」写入 `/etc/resolv.conf`，此时操作系统可进行域名解析了。

DHCP 是动态的，或者用户需要在不同的网络之间切换，这些因素导致 `/etc/resolv.conf` 需要动态调整。如果看到该文件像下面这样，以软链接的形式存在，则说明 DNS 可能由某款程序管理，用户不应该直接修改该文件。

```
$  ls -l /etc/resolv.conf 
lrwxrwxrwx 1 root root 37 Feb 29 12:20 /etc/resolv.conf -> /run/systemd/resolve/stub-resolv.conf
```

上面 `/run/systemd/resolve/` 这个目录由 systemd-resolved 管理。

### systemd-resolved

systemd-resolved 是 systemd 的一个组件，不需要单独安装，直接将服务启用即可，然后将 `/etc/resolv.conf` 作为软链接指向 `/run/systemd/resolve/stub-resolv.conf`，操作如下：

``` shell
sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

`/run/systemd/resolve/stub-resolv.conf` 内容如下：

```
# This file is managed by man:systemd-resolved(8). Do not edit.
# …

nameserver 127.0.0.53
options edns0
```

上面可以看到 `nameserver` 是 `127.0.0.53`，因为 systemd-resolved 包含一个「DNS服务」，它监听 `127.0.0.53`。此时操作系统的域名解析请求全部发到这个服务，再由它进行后续的解析。`resolvctl status` (老版本使用 `systemd-resolve --status`) 可以查看服务状态，输出信息如下：

``` shell-session
$ resolvectl status || systemd-resolve --status
Global
       LLMNR setting: yes
MulticastDNS setting: yes
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes
  Current DNS Server: 119.29.29.29
         DNS Servers: 119.29.29.29
                      223.5.5.5
…
```

上面可以看到，systemd-resolved 后端使用 `119.29.29.29` 作为「DNS服务器」，通过 `/etc/systemd/resolved.conf` 这个文件进行管理，配置如下：

```
[Resolve]
DNS=119.29.29.29 223.5.5.5
DNSSEC=false
```

默认情况下 `DNS=` 为空，这时会使用网卡的 DNS，即动态管理，也可以像上面那样配置为静态的。修改了配置后需要重启服务才能生效 `sudo systemctl restart systemd-resolved`。

### 锁定 /etc/resolv.conf

如果长期使用固定的 DNS，也可以直接配置 `/etc/resolv.conf`，然后将其锁定，以确保它不被其他程序修改掉。像下面这样操作:

``` shell
sudo rm -f /etc/resolv.conf
echo "nameserver 119.29.29.29" | sudo tee /etc/resolv.conf
echo "nameserver 223.5.5.5" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
```

`chattr +i` 可锁定文件，此时文件不可修改，`lsattr /etc/resolv.conf` 可以看到文件有个 `i` 属性，`chattr -i /etc/resolv.conf` 可解除锁定。





















sudo apt update && sudo apt upgrade

sudo apt install traceroute

# 添加子接口
sudo ip link add link enp0s9 name enp0s9.1 type vlan id 1
sudo ip link add enp0s9.1 type macvlan mode bridge 
sudo ip link add enp0s9.2 type dummy
sudo ip addr add 192.168.10.254/24 dev enp0s9 label enp0s9.1


假设您要将网段10.0.0.0/24的流量通过网关192.168.1.1转发到接口eth0上，可以使用以下命令：
sudo ip route add 10.0.0.0/24 via 192.168.1.1 dev eth0


    # sudo ip route del default
    # sudo ip route add default via 192.168.10.254


systemd-network

ifupdown

netplan

https://developer.aliyun.com/article/744737

https://ubuntu.com/server/docs/network-configuration


Netplan：Ubuntu 18.04 版本以后的默认网络配置工具，通过 YAML 文件进行配置，支持网络接口、IP 地址、网关、DNS 等设置。

NetworkManager：广泛应用于各种桌面环境和发行版中的网络管理工具，支持 WIFI、以太网、VPN 等多种网络连接，通过 GUI 界面或命令行进行配置。

systemd-networkd：由 systemd 项目提供的网络配置工具，可以设置网络接口、IP 地址、网关、DNS 等，支持 DHCP、固定 IP 和静态路由等多种网络连接方式。

ifupdown：Ubuntu 18.04 版本以前的默认网络配置工具，支持通过 /etc/network/interfaces 文件进行配置，适用于简单的网络设置。

以上是常见的网络管理工具，不同的操作系统和发行版可能有所不同。


ping -I xx  IP