---
title: 清除 DNS 缓存
---

![1678178429194](image/Clean-DNS-Cache/1678178429194.svg)

https://devconnected.com/how-to-flush-dns-cache-on-linux/

DNS 是域名系统协议的缩写，用于 Linux 系统以检索与名称关联的 IP 地址。

例如，当您执行 ping 请求时，很可能您正在使用DNS 协议来检索服务器 IP。

在大多数情况下，您执行的DNS 请求存储在操作系统的本地缓存中。

但是，在某些情况下，您可能希望刷新服务器的 DNS 缓存。

这可能是因为您更改了网络上服务器的 IP，并且您希望更改立即反映出来。

在本教程中，您将学习如何在 Linux 上轻松刷新 DNS 缓存，无论您使用的是 systemd 还是 dnsmasq。



## Prerequisites

为了能够刷新您的 DNS 缓存，您必须了解DNS 解析在您的 Linux 系统上是如何工作的。


在Linux，除非你已安装并运行Systemd-Resolved，DNSMasq或Nscd之类的缓存服务，否则操作系统不会缓存DNS解释结果。

根据Linux发行版和所使用的缓存服务，清除DNS缓存的过程有所不同。大多数 Linux发行版，例如Ubuntu 18.04之后都使用Systemd-Resolved服务缓存DNS记录。

## 1 
如果你的Linux发行版使用systemd作为初始化服务，可以运行命令,查看服务是否正在运行。
```
sudo systemctl is-active systemd-resolved.service确定Systemd-Resolved
```

如果Systemd-Resolved服务正在运行，命令将会打印active，否则命令打印inactive。

如果Systemd-Resolved服务正在运行，则可以运行命令,清除系统DNS缓存。命令不返回任何消息

```
sudo systemd-resolve --flush-caches
```

```
sudo systemctl is-active systemd-resolved.service

```

## 2

Dnsmasq是轻量级的DHCP和DNS缓存服务器。如果您的系统使用DNSMasq作为缓存服务器。

要清除DNS缓存，则需要重新启动Dnsmasq服务，运行命令sudo systemctl restart dnsmasq.service。

```
sudo systemctl restart dnsmasq.service

```


## 3
Nscd是一个缓存守护程序，它是基于RedHat发行版首选DNS缓存系统。如果你的Linux发行版使用Nscd来缓存DNS记录，

要清除DNS缓存，则需要重新启动Nscd服务。运行命令sudo systemctl restart nscd.service。

```
sudo systemctl restart nscd.service

```

## Chrome 浏览器清除DNS缓存

现代的Web浏览器都有一个内置的DNS客户端，以防止每次访问网站时重复查询DNS解释IP地址。

要清除Google Chrome浏览器DNS缓存。首先打开一个新标签，然后输入`chrome://net-internals/#dns`在Chrome的地址栏。点击清除缓存按钮。


:::info
Chrome如何清除单个域名的缓存
依然是打开开发者工具（F12），应用-存储-清除数据
:::


## Firefox 浏览器清除DNS缓存
要清除Firefox的DNS缓存。首先在右上角，单击汉堡包图标☰打开Firefox的菜单。

点击⚙ Options (Preferences)链接。单击左侧的隐私和安全性或隐私选项卡。向下滚动到该History部分，然后单击Clear History...按钮。

选择要清除的时间范围。选择所有内容将会删除所有内容。选择所有复选框，然后单击立即清除。

如果这对您不起作用，请尝试以下方法并暂时禁用DNS缓存。打开一个新标签，然后about:config在Firefox的地址栏中输入。

搜索network.dnsCacheExpiration，将值暂时设置为0，然后单击确定。然后，改回默认值，然后单击确定。

搜索network.dnsCacheEntries，将值暂时设置为0，然后单击确定。然后，改回默认值，然后单击确定。



## 5

/etc/init.d/nscd restart

现在关于 Fedora，有一个默认设置的名为 NetworkManager-config-server 的包。/etc/NetworkManager/NetworkManager.conf
中没有关于 `dns=dnsmasq` 的配置Flush DNS 命令 redhat 可能需要一些时间来摆脱你的 DNS 存储缓存。没有直接的方法或控件可以做到这一点，但是，您仍然有办法做到这一点。 它所需要的只是重新启动守护进程以摆脱 DNS 缓存。
## 6

刷新 DNS 命令 Windows
```
ipconfig /flushdns
```