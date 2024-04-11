---
title: 主机名和 FQDN
---

FQDN 是 Fully Qualified Domain Name的缩写，称为完全合格域名，是指包含了所有域的主机名，其中包括根域。FQDN可以说是主机名的一种完全表示形式，它从逻辑上准确地表示出主机在什么地方。


"hostname" 命令用于显示计算机的主机名，而 "hostname -f" 命令用于显示计算机的完全限定域名（FQDN）。FQDN 包括主机名和域名，可以用来唯一地标识计算机在网络中的位置。

完全限定域名的英文是 Fully Qualified Domain Name（FQDN）。
FQDN 是一个域名的完整、唯一的标识符，它包含了所有的父级域名和该域名本身。例如，"www.example.com" 就是一个 FQDN，其中 "www" 是子域名，"example" 是二级域名，".com" 是顶级域名。

FQDN 在计算机网络中起着非常重要的作用，它可以唯一地标识一个主机或网络设备。

主机名和完全限定域名的值通常存储在计算机的 /etc/hostname 和 /etc/hosts 文件中。这些值也可以通过网络配置工具（如 NetworkManager）进行配置。


## 命令
FQDN = Hostname + DomainName

Linux下查看方式：
- hostname， 查看主机名
- hostname -f 查看FQDN
- dnsdomainname 查看域
- uname -n 查看主机名


## 优先级
在 Linux 系统中，主机名的优先级如下（按照从高到低的顺序）：



手动设置的主机名（通过 hostname 命令设置）

DHCP 提供的主机名（如果启用了 DHCP）

/etc/hostname 文件中的值


而完全限定域名的优先级如下：



手动设置的完全限定域名（通过修改 /etc/hosts 文件或 DNS 配置文件）

DHCP 提供的完全限定域名（如果启用了 DHCP）

通过主机名和域名的组合自动生成的完全限定域名

## 条件
如果已经手动设置了完全限定域名，则使用手动设置的值；

如果没有手动设置完全限定域名，但是在 /etc/hosts 文件中为其中一个主机名指定了完全限定域名，则使用该主机名对应的完全限定域名；

如果以上两种情况都不满足，则使用主机名和默认域名的组合来生成完全限定域名。默认域名通常可以在 /etc/resolv.conf 文件中找到。  





## 例子
修改 /etc/hosts 文件来实现。在该文件中，可以为计算机指定多个主机名和 IP 地址的映射关系，其中每个条目都可以包括主机名、完全限定域名和 IP 地址。例如：

```bash
127.0.0.1   localhost.localdomain   localhost
```
在这个例子中，"localhost.localdomain" 就是手动设置的完全限定域名，可以根据需要修改为其他值。


指定默认域名可以通过修改 /etc/resolv.conf 文件来实现。在该文件中，可以指定 DNS 解析器和默认域名。例如：

```bash
search example.com
nameserver 8.8.8.8
```


## hosts

在 /etc/hosts 文件中，每个条目的格式通常为：
```
IP地址   完全限定域名   主机名
```
其中，IP 地址和完全限定域名是必需的，主机名是可选的。在这个例子中，127.0.0.1 是 IP 地址，而 "localhost.localdomain" 和 "localhost" 都是主机名。如果顺序颠倒，则会导致解析出现问题。因此，应该按照上面的格式来编写 /etc/hosts 文件，确保每个条目的顺序正确。如果需要修改主机名或完全限定域名，则应该同时修改所有相关的条目。



当/etc/hosts。

192.168.160.131 puppet-mst puppet-mst.eisen
“hostname -f”将返回puppet-mst，当它--

192.168.160.131 puppet-mst.eisen puppet-mst
主机名-f”将返回puppet-mst.eisen


## NetworkManager 配置主机名
NetworkManager配置主机名和使用nmcli命令行工具设置主机名是等价的，它们都是使用NetworkManager来管理网络配置。两种方法都会实时更新主机名，使其在网络中可用。选择哪种方法取决于您更喜欢使用哪种工具来管理网络配置。

要使用NetworkManager配置主机名，可以执行以下步骤：

编辑NetworkManager配置文件。在大多数Linux发行版中，该文件位于/etc/NetworkManager/NetworkManager.conf。
在[main]部分下添加 `hostname=your_hostname`，然后`systemctl restart NetworkManager`重启NetworkManager服务，以使更改生效

或者使用nmcli命令行工具来配置主机名。以下是使用nmcli设置主机名的步骤：
```bash
nmcli general hostname

nmcli general hostname your_hostname

systemctl restart NetworkManager
```

- https://josephcz.xyz/technology/linux/never-use-2ld-as-hostname/
