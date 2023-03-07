
## 安装 ISC DHCP

在Linux上使用最广泛的DHCP服务器是ISC DHCP（Internet Systems Consortium DHCP）。这是因为它是开源软件，具有很好的扩展性和可配置性，并且在Linux发行版中往往预安装了ISC DHCP。另外，ISC DHCP是一种经过验证的解决方案，已经被广泛应用于生产环境中。但是，对于具体的使用场景，选择最适合的DHCP服务器取决于网络规模、复杂度和功能需求等因素。

以下是一个基于ISC DHCP的DHCP服务器配置示例：


在Ubuntu、Debian等基于apt的发行版中，可以使用以下命令安装ISC DHCP服务器：

```bash
sudo apt-get install isc-dhcp-server
```
在CentOS 7中，可以使用yum命令安装dhcpd软件：

```bash
sudo yum install dhcp

```
## 配置DHCP服务器：

编辑ISC DHCP服务器的配置文件/etc/dhcp/dhcpd.conf，添加以下内容：

```bash
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.10 192.168.1.50;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}

## 指定ntp
要配置DHCP服务器以指定NTP服务器，请按照以下步骤操作：



打开DHCP服务器的配置文件，通常在/etc/dhcp/dhcpd.conf。



找到要为其配置NTP服务器的子网段的定义，例如：




subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.10 192.168.1.50;
  option routers 192.168.1.1;
}



在子网段定义中添加以下行以指定NTP服务器：


option ntp-servers 192.168.1.100;


其中192.168.1.100是您要使用的NTP服务器的IP地址。如果您有多个NTP服务器，请将它们用逗号分隔。



保存并关闭文件。



重新启动DHCP服务器以应用更改。




现在，DHCP客户端将从DHCP服务器获取NTP服务器的IP地址，并使用它来同步其时间。
##  
https://www.linuxtips.fr/en/setting-up-a-dhcp-server-synced-with-dnd-debian-ubuntu/
##

## 指定固定IP
以下是一个简单的DHCP服务器配置文件，其中包括一个固定IP地址分配的示例：


# /etc/dhcp/dhcpd.conf

# 设置DHCP服务器的名称和域名
option domain-name &quot;example.com&quot;;
option domain-name-servers 8.8.8.8;

# 定义DHCP地址池
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.10 192.168.1.100;
  option routers 192.168.1.1;
  option broadcast-address 192.168.1.255;
}

# 配置固定IP地址
host my-computer {
  hardware ethernet 00:11:22:33:44:55;
  fixed-address 192.168.1.5;
}

# 其他配置选项
default-lease-time 600;
max-lease-time 7200;

在上面的示例中，我们为一个名为“my-computer”的设备分配了固定IP地址192.168.1.5。要将此配置文件加载到DHCP服务器中，请使用以下命令：


sudo service dhcpd restart

请注意，实际的配置文件可能因系统和网络环境的不同而有所不同。
##
```

这里配置了一个子网为192.168.1.0/24的DHCP服务器，分配的IP地址范围是192.168.1.10 - 192.168.1.50，默认网关是192.168.1.1，DNS服务器是Google的公共DNS。

其中，option routers指定了网关地址，option domain-name-servers指定了DNS服务器地址。


## 启动DHCP服务器

启动DHCP服务器命令如下：

```
sudo service isc-dhcp-server start
sudo service dhcp start

```
至此，DHCP服务器的配置就完成了。在子网192.168.1.0/24中连接到网络的设备将自动从DHCP服务器获取IP地址和其他网络配置信息，无需手动配置。

## 配置网络接口：
编辑网络接口的配置文件/etc/network/interfaces，将DHCP服务器的IP地址绑定到网络接口上：
```
auto eth0
iface eth0 inet static
address 192.168.1.1
netmask 255.255.255.0
broadcast 192.168.1.255
```

以上配置表示网络接口eth0使用静态IP地址192.168.1.1，并设置子网掩码为255.255.255.0，广播地址为192.168.1.255。



## 中继安装

DHCP Relay是一个网络协议，它可以将 DHCP 请求从一个网络中转到另一个网络上的 DHCP 服务器。在 Linux 上，可以使用 dhcrelay 命令来配置 DHCP Relay。

安装 dhcp-relay 软件包。在 Ubuntu 上，可以使用以下命令安装它：

```bash
sudo apt-get install dhcp-relay
```

安装 dhcp-relay 软件包。在 CentOS 上，可以使用以下命令安装：

```
sudo yum install dhcp-relay

```

编辑 /etc/default/dhcp-relay 文件，并指定 DHCP 服务器的 IP 地址和需要中转的网络接口。例如，如果 DHCP 服务器的 IP 地址是 192.168.1.1，需要中转的网络接口是 eth0，则可以将以下行添加到 /etc/default/dhcp-relay 文件中：


```bash
DHCPD_SERVERS=&quot;192.168.1.1&quot;
INTERFACES=&quot;eth0&quot;
```
如果要中继多个 DHCP 服务器，可以使用逗号分隔它们的 IP 地址。



3.编辑 /etc/dhcp/dhcrelay.conf 文件，并指定需要中转的 DHCP 子网。例如，如果需要中转的 DHCP 子网是 192.168.2.0/24，则可以将以下行添加到 /etc/dhcp/dhcrelay.conf 文件中：

```bash
relay 192.168.2.0/24
```


启动 dhcrelay 服务。在 Ubuntu 上，可以使用以下命令启动它：

```bash
sudo service isc-dhcp-relay start
sudo systemctl enable --now dhcp-relay

```
完成上述步骤后，DHCP 请求将被转发到指定的 DHCP 服务器上。您可以使用 tcpdump 命令来检查是否已正确配置 DHCP Relay。


