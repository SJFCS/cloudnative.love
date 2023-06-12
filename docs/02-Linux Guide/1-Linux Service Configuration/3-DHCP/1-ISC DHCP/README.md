---
title: ISC DHCP
sidebar_position: 2
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Linux 上使用最广泛的 DHCP 服务器是 ISC DHCP（Internet Systems Consortium DHCP）。大多数 Linux 发行版中预装了ISC DHCP。而且 ISC DHCP 是一种经过验证的解决方案，已经被广泛应用于生产环境中。

## 域的类型

- 单域  
  单域是指在DHCP服务器上设置的一个范围，用于向一个特定的网络子网分配IP地址和相关配置信息。单域适用于只有一个网络子网需要在DHCP服务器上进行配置的情况。

- 多域  
  多域是指在DHCP服务器上设置的多个范围，用于向不同的网络子网分配IP地址和相关配置信息。多域适用于同一个DHCP服务器需要向多个网络子网分配IP地址和其他网络配置信息的情况。

- 超级作用域  
  超级作用域是指在DHCP服务器上设置的一个范围，用于同时向多个不同的网络子网分配IP地址和相关配置信息。超级作用域适用于多个不同的网络子网需要使用同一个IP地址和配置信息的情况，例如公司内部的多个子网都需要访问同一个外部网站时。

总的来说，单域、多域和超级作用域都是为了更有效地管理分配给网络设备的IP地址和其他配置信息而设置的范围。不同的范围设置可以根据网络规模和需求进行选择和调整，以实现更优化的网络管理和分配。

```
以下是DHCP单域、多域和超级作用域的配置示例：

单域配置示例（网络子网：192.168.1.0/24）
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option subnet-mask 255.255.255.0;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
多域配置示例（网络子网1：192.168.1.0/24；网络子网2：192.168.2.0/24）
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option subnet-mask 255.255.255.0;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}

subnet 192.168.2.0 netmask 255.255.255.0 {
    range 192.168.2.100 192.168.2.200;
    option subnet-mask 255.255.255.0;
    option routers 192.168.2.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
超级作用域配置示例（配置使用同一个IP地址和配置信息的多个网络子网）
shared-network sharedsubnet {
    subnet 192.168.1.0 netmask 255.255.255.0 {
        range 192.168.1.100 192.168.1.200;
        option subnet-mask 255.255.255.0;
        option routers 192.168.1.1;
        option domain-name-servers 8.8.8.8, 8.8.4.4;
    }
    
    subnet 192.168.2.0 netmask 255.255.255.0 {
        range 192.168.2.100 192.168.2.200;
        option subnet-mask 255.255.255.0;
        option routers 192.168.1.1;
        option domain-name-servers 8.8.8.8, 8.8.4.4;
    }
}
以上仅为简单示例，具体的配置内容和参数设置需根据实际网络需求进行调整。



是的，您可以直接使用多个subnet来定义多个子网，这样也是可以实现的。但是，使用shared-network可以让多个子网共享相同的配置信息，例如DNS服务器、网关、租约期限等。同时，也可以方便地控制并确保每个子网中的IP地址不会重叠。

使用shared-network的好处在于可以将多个子网组合在一起，让它们表现得像是一个网络。例如，如果使用一个DHCP服务器为多个物理子网提供地址，则定义一个共享网络可以更清晰得表达这些子网的共同处。

使用多个子网的方式则更适用于那些不需要共享相同配置信息的场合。总之，使用哪种形式完全取决于您的特定需求，并没有绝对的对与错。
```

## ISC DHCP 安装

可以使用以下命令安装并启动 isc-dhcp-server 和 isc-dhcp-relay。

<Tabs>
<TabItem value="Ubuntu/Debian">

```bash
## dhcp-server
sudo apt-get update && sudo apt-get install isc-dhcp-server
dpkg -L isc-dhcp-server
sudo systemctl enable --now isc-dhcp-server
## dhcp-relay
sudo apt-get update && sudo apt-get install isc-dhcp-relay
dpkg -L isc-dhcp-relay
sudo systemctl enable --now isc-dhcp-relay
```
</TabItem>
<TabItem value="CentOS/RedHat">

```bash
sudo yum makecache && sudo yum install dhcp

#yum -y install dhcp-relay
#yum -y install dhcp-server

rpm -ql dhcp
sudo systemctl enable --now dhcpd
sudo systemctl enable --now dhcrelay
```
</TabItem>
</Tabs>

## isc-dhcp-server 配置参数
```bash
  default-lease-time 600; # 设置DHCP客户端的默认租约时间为600秒（10分钟）
  max-lease-time 7200; # 设置DHCP客户端的最大租约时间为7200秒（2小时）
```
### subnet 

```bash


subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.10 10.0.0.20;       # 地址池范围
#  range dynamic-bootp 10.254.239.40 10.254.239.60;
 option subnet-mask 255.255.255.224;
#  option broadcast-address 10.0.0.255; # 广播地址，不设置时默认会根据A/B/C类地址自动计算   
  # option domain-name "example.org"; 
    #设置DHCP客户端的域名,如果一个DHCP客户端的主机名是 "node1"，并且DHCP服务器向它下发了 option domain-name "example.org"; 这个选项，那么该客户端的FQDN将是 "node1.example.org"。
  # DHCP 客户端会将 option domain-name 配置中指定的域名添加到本地 DNS 配置文件 /etc/resolv.conf 中的 search 字段中，以便在解析主机名时可以自动添加域名后缀。例如，如果 option domain-name 配置为 internal.example.org，那么 /etc/resolv.conf 文件中的 search 字段将被更新为：search internal.example.org,这样，在进行 DNS 查询时，如果主机名不包含域名后缀，则会自动添加 internal.example.org 后缀进行查询。
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;  # 默认路由，其实就是网关
  option domain-name-servers ns1.example.org, ns2.example.org; # 设置DHCP客户端的DNS服务器
}

```

### host 

host 块的优先级高于 subnet 块。在 ISC DHCP 中，当客户端请求 IP 地址时，DHCP 服务器将首先在 host 块中查找匹配的主机名或 MAC 地址，如果找到匹配项，则使用该主机的配置。如果在 host 块中找不到匹配项，则 DHCP 服务器将搜索与客户端请求的子网相匹配的子网块，并使用该子网块的配置。

通常，应优先使用 host 块来针对特定的客户端定义独立的配置。subnet 块通常用于为位于同一子网范围内的多个客户端提供共享配置（例如网关、DNS、NTP 等）。

需要注意的是，在匹配到 host 块时，subnet 块中的参数将被覆盖。因此，在你针对特定客户端设置 host 块时，请确保将所需的所有配置都包含在 host 块中，而不是依赖于 subnet 块的默认值。


```bash
#下面的是绑定MAC地址设置保留地址，保留地址不能是地址池中的地址
host node1 {            
  hardware ethernet 08:00:07:26:c0:a5;
  filename "vmunix.node2"; 
  # 开始启动文件的名称，应用于无盘工作站,DHCP服务器向客户端提供的引导文件名，也被称为引导文件路径。客户端会使用这个文件名来下载引导文件，从而启动操作系统。通常情况下，filename是一个相对路径，指向DHCP服务器上存储的引导文件。
  # 指定该主机在启动时需要下载 vmunix.passacaglia 文件；
  # 指定该主机在启动时需要从名为 toccata.example.com 的 TFTP（Trivial File Transfer Protocol）服务器上下载文件。
  # 这个文件可能是一个操作系统内核镜像，是用来启动客户机或者服务器的。在某些场景下，我们可能需要提供给客户机或者服务器一个自定义的操作系统，这时候就可以利用 DHCP 功能来提供操作系统内核镜像。这个功能通常应用于大量部署相同系统配置的场景，比如云计算数据中心、虚拟化环境等。
  # 默认情况下，vmunix.passacaglia 文件是存放在 TFTP 服务器的根目录下，也就是 TFTP 服务器的 tftpboot 目录下。当主机获取该文件的时候，会默认去 TFTP 服务器的根目录下寻找指定的文件，并将其下载到本地进行启动。不过，这个路径可以在 DHCP 服务配置文件中通过 filename 字段重新指定。
  server-name "toccata.fugue.com"; 
  fixed-address fantasia.fugue.com; # 此参数指定DHCP客户端应该被分配的静态IP地址。与通常的动态IP地址分配不同，DHCP服务器将始终分配给该客户端相同的IP地址。这通常用于需要固定IP地址的服务器或其他网络设备。
  # fixed-address 192.168.100.3;      # 根据MAC地址分配的固定IP 
}

```

在大多数情况下，fixed-address 属性必须是一个 IP 地址。然而，有一些 DHCP 服务器软件（比如 ISC DHCP），支持将主机名作为 fixed-address 属性，不过需要满足以下条件：

- DHCP 服务器必须是一个支持 DNS 功能的服务器，这样其可以解析主机名，并将其解析成相应的 IP 地址。
- 必须启用“动态 DNS 更新”选项，这样当 DHCP 服务分配 IP 地址时，它将自动更新 DNS 解析记录，这将启用 DNS 反向解析，使获取相关信息更加容易。
- 在客户端主机上，需要正确配置 DNS 解析，以便其可以在 DHCP 客户端启动时访问 DNS 服务器并获取其 IP 地址。



### shared-network

subnet 关键字只适用于单个子网的情况，而 shared-network 中，可以定义多个 subnet 来表示不同的子网，可以将多个子网组合成一个共享网络。

在使用 shared-network 定义多个子网的情况下，DHCP 服务器和客户端不必在同一网络内。
DHCP 服务器只需要有一个接口连接到网络，然后为该网络中的多个子网提供服务即可。
在这种情况下，DHCP 服务器需要能够路由到每个子网，以便能够向客户端发送 DHCP 响应。
这通常可以通过在 DHCP 服务器上设置静态路由或使用动态路由协议来实现。



当客户端向网络中发送 DHCP 请求时，该请求会被广播到该网络的所有设备。如果 DHCP 服务器与客户端在同一子网中，则可以直接接收到该广播，并向客户端发送 DHCP 响应。但是，如果 DHCP 服务器与客户端不在同一子网中，则需要路由器将该广播转发到 DHCP 服务器所在的子网。因此，DHCP 服务器需要能够路由到每个子网，以便能够接收到来自客户端的 DHCP 请求并向其发送响应。
需要注意的是，不同类型的 DHCP 请求有不同的广播域。例如，DHCP Discover 和 DHCP Request 请求是局域网（LAN）广播，而 DHCP Release 和 DHCP Decline 请求是子网广播。因此，DHCP 服务器需要能够处理不同类型的广播请求，并能够正确地将 DHCP 响应发送回客户端。

:::tip
通常情况下，路由器是不会转发广播的，因为广播是限制在其所在的网络（广播域）内的。
但是，有些路由器支持广播转发功能，也称为 "子网广播转发 (Subnet Broadcast Forwarding，SBF)"
广播转发功能允许路由器将广播数据包从一个广播域转发到另一个广播域，以便广播能够跨越不同的子网传播。
这样，DHCP 服务器就可以接收到来自不同子网的 DHCP 请求，并向客户端发送 DHCP 响应。
需要注意的是，广播转发功能可能会对网络性能和安全性产生影响。如果不正确配置，可能会导致广播风暴、网络拥塞和安全漏洞等问题。
因此，在启用广播转发功能之前，请确保已经了解其工作原理，并采取相应的安全措施。
:::

```bash
shared-network example-network {
  subnet 192.168.1.0 netmask 255.255.255.0 {
    option routers 192.168.1.1;
    option domain-name "example.com";
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    range 192.168.1.100 192.168.1.200;

  }
  subnet 192.168.2.0 netmask 255.255.255.0 {
    option routers 192.168.2.1;
    option domain-name "example.com";
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    range 192.168.2.100 192.168.2.200;
  }
}
```



### class

```bash
class "foo" {
 match if substring (option vendor-class-identifier, 0, 4) = "SUNW";
}

shared-network example-network {
  subnet 192.168.1.0 netmask 255.255.255.0 {
    option routers 192.168.1.1;
    option domain-name "example.com";
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    range 192.168.1.100 192.168.1.200;

  }
  subnet 192.168.2.0 netmask 255.255.255.0 {
    option routers 192.168.2.1;
    option domain-name "example.com";
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    range 192.168.2.100 192.168.2.200;
  }

  pool {
    allow members of "foo";
    range 10.17.224.10 10.17.224.250;
  }
  pool {
    deny members of "foo";
    range 10.0.29.10 10.0.29.230;
  }
}
shared-network 224-29：定义一个名为 example-network 的共享网络，该网络包括两个子网：10.17.224.0/24 和 10.0.29.0/24。每个子网都有一个路由器（rtr-224.example.org 和 rtr-29.example.org），以及一个 IP 地址池。其中，第一个池只允许名为 foo 的类中的客户端使用，该池的 IP 地址范围为 10.17.224.10 到 10.17.224.250；第二个池禁止名为 foo 的类中的客户端使用，该池的 IP 地址范围为 10.0.29.10

```
class "foo"：定义一个名为 foo 的类，该类使用 match 语句来匹配 option vendor-class-identifier 选项的前四个字符是否为 SUNW。这个类可以用于对某些特定类型的客户端应用不同的分配策略。
Class 是 DHCP 服务器配置文件中的一个关键字，用于定义 DHCP 客户端的分类。通过定义不同的 class，管理员可以为不同类型的客户端分配不同的 IP 地址、子网掩码、网关、DNS 服务器等参数，以满足其特定需求。例如，可以为移动设备定义一个 class，为服务器定义一个 class，为办公室工作站定义一个 class 等等。
以下是一个 class 的示例：
```bash
class "mobile-devices" {
match if substring(option vendor-class-identifier, 0, 6) = "Apple";
option domain-name "example.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;
range 10.0.1.100 10.0.1.200;
}
```
这个 class 定义了一个名为 mobile-devices 的分类，匹配条件为客户端的 vendor-class-identifier 字段以 "Apple" 开头。当客户端满足条件时，DHCP 服务器会为其分配一个 IP 地址范围为 10.0.1.100 到 10.0.1.200 的地址，同时指定了域名和 DNS 服务器。


## isc-dhcp-relay  配置参数

 cat /etc/default/isc-dhcp-relay

```bash
# What servers should the DHCP relay forward requests to?
SERVERS=""

# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES=""

# Additional options that are passed to the DHCP relay daemon?
OPTIONS=""
```