---
title: DNS
sidebar_position: 1
---

DNS(Domain Name System, 域名系统)用于正向查找（Forward Lookup）查找域名对应的IP地址和反向查找（Reverse Lookup）查找 IP 地址对应的域名。

:::tip

- DNS 可以使用 TCP 和 UDP 的 53 端口，基本使用 UDP 协议的 53端口。

- FQDN 通常为 `主机名.DNS域`
- Linux 中可以修改 `/etc/nsswitch.conf`文件中`hosts: files dns` 行来定义 hosts 文件和 DNS 服务器的查找优先级
:::

## DNS Zone

![1685590784551](image/README/1685590784551.svg)

在 DNS 树结构中，根域是最高级别的域，位于 DNS 树的顶部。根域是一个特殊的域，它没有名称，只有一个点号`.`来代表它本身。根域的作用是提供 DNS 树的起点，为 DNS 解析提供基础支持。当 DNS 客户端发起一个查询时，它会首先向其本地DNS服务器发送查询请求，如果本地 DNS 服务器无法解析查询请求，则会向根域名服务器发送查询请求，以获取相应的顶级域名服务器信息。

除了根域之外，DNS 区域可以分为以下几种类型：

- 主区域：主区域是指 DNS 服务器上存储的原始 DNS 数据。管理员可以在主区域文件中定义 DNS 资源记录，这些记录在整个 DNS 环境中起着关键作用。
- 从属区域：从属区域是指 DNS 服务器上存储的与主区域相同或相似的 DNS 数据。从属区域可以让 DNS 管理员创建分布式 DNS 环境，以提高性能和可靠性。
- 反向区域：反向区域是指通过 IP 地址反向查找主机名的 DNS 区域。在反向区域中，管理员可以定义 PTR 记录，将 IP地址映射到相应的主机名。

:::tip 权威服务器和(非)权威应答
权威服务器（Authoritative Server） 可以理解为直接上层域的 DNS 服务器。

例如 `demo.example.com` 对于 `demo` 主机的上层域是 `example.com`，即为它的权威服务器。

更具体的说，某域的权威服务器是可以直接查看该域数据(即区域数据文件)的 DNS 服务器，主、从DNS服务器都是权威服务器。
:::

## 递归查询和迭代查询

假如 Host A 默认指向 DNS Server B 当查询 `demo.example.com` 的 IP 地址时查询流程应该如下所示

- 递归查询：  
  Host A --> DNS Server B --> `.` --> `com.` --> `example.`--> DNS Server B --> Host A
- 迭代查询：
  Host A --> DNS Server B --> A
  Host A --> `.` --> A
  Host A --> `com.` --> A
  Host A --> `example.` --> A

上面演示了没有缓存的情况下递归查询和迭代查询的完整过程。

:::tip
顶级域和根域出于性能的考虑，是不允许给其他任何机器递归的。  
通常客户端到 DNS 服务器端的这一阶段是递归查询，从 DNS 服务器之后的是迭代查询。

nslookup、host、dig 等所发出的查询都是递归查询。
:::

在下面两种情况下，不需要额外的查询轮次（如递归或迭代查询），它会立即返回 DNS 记录返回给客户端:

- 第一种情况是当 DNS 服务器本地或者缓存中已经存在所需的 DNS 记录时，它可以直接返回记录给客户端。
- 第二种情况是当通过 DNS 权威服务器查询其下主机，也会立即返回 DNS 记录返回给客户端。  
  例如 Host A 默认指向 `example.com` 当查询 `demo.example.com` 会立即返回 DNS 记录返回给客户端

## 资源记录(Resource Record,RR)

域名相关的数据都需要存储在文件(区域数据文件)中。这些数据分为多种类别，每种类别存储在对应的资源记录(resource record,RR)中。

- SOA 记录：  
  start of authority，起始授权机构。该记录存储了一系列数据，若不明白SOA记录，请结合下面的NS记录，SOA更多的信息见"子域"部分的内容。格式如下：
- NS 记录：  
  name server，存储的是该域内的dns服务器相关信息。即NS记录标识了哪台服务器是DNS服务器。格式如下：
- A(IPV6则为AAAA记录)记录：
  address，存储的是域内主机名所对应的ip地址。格式如下：
- PTR 记录：  
  pointer，和A记录相反，存储的是ip地址对应的主机名，该记录只存在于反向解析的区域数据文件中(并非一定)。格式如下：
- CNAME 记录：  
  canonical name，表示规范名的意思，其所代表的记录常称为别名记录。之所以如此称呼，就是因为为规范名起了一个别名。什么是规范名？可以简单认为是fqdn。格式如下：

- 地址映射记录（A Record）——也称为 DNS 主机记录，存储主机名及其对应的 IPv4 地址。
- IPv6 地址记录（AAAA 记录）——存储主机名及其对应的 IPv6 地址。
- 规范名称记录（CNAME 记录）— 可用于将一个主机名作为另一个主机名的别名。当 DNS 客户端请求包含指向另一个主机名的 CNAME 的记录时，将使用新主机名重复 DNS 解析过程。
- 邮件交换器记录（MX 记录）— 指定域的 SMTP 电子邮件服务器，用于将外发电子邮件路由到电子邮件服务器。
- 名称服务器记录 (NS Record)——指定一个 DNS 区域，如“example.com”被委托给一个特定的权威名称服务器，并提供名称服务器的地址。
- 反向查找指针记录（PTR 记录）— 允许 DNS 解析器提供 IP 地址并接收主机名（反向 DNS 查找）。
- 证书记录（CERT Record）——存储加密证书——PKIX、SPKI、PGP等。
- 服务位置（SRV 记录）——服务位置记录，类似于 MX，但用于其他通信协议。
- 文本记录（TXT 记录）——通常携带机器可读的数据，例如机会加密、发送者策略框架、DKIM、DMARC 等。
- 授权开始（SOA 记录）——该记录出现在 DNS 区域文件的开头，并指示当前 DNS 区域的授权名称服务器、域管理员的详细联系信息、域序列号以及 DNS 信息的频率信息对于这个区域应该刷新。

## 文章

- <https://ns1.com/resources/dns-types-records-servers-and-queries>
- <https://ns1.com/resources/dns-zones-explained>
- <https://www.redhat.com/sysadmin/dns-configuration-introduction>
- <https://www.cnblogs.com/f-ck-need-u/p/7367503.html>

- <https://www.v2ex.com/t/742709>
- <https://boce.aliyun.com/detect/dns/DNS_PING-55e41bb2aff9db99decd9d9da1be445d-1652369079406>
- <https://www.cnblogs.com/f-ck-need-u/p/7367503.html>
- <https://www.thesslstore.com/blog/dns-over-tls-vs-dns-over-https/>
- <https://developers.google.com/speed/public-dns/docs/dns-over-tls?hl=zh-cn>
- <https://developers.google.com/speed/public-dns/docs/using?hl=zh-cn>

[Dnscrypt-proxy](https://wiki.archlinux.org/title/Dnscrypt-proxy)
DNS over TLS 和 DNS over HTTPS

基于 TLS 的 DNS (DoT) 和基于 HTTPS 的 DNS (DoH) 听起来它们是同一事物的可互换术语。他们实际上完成了同样的事情——加密 DNS 请求——但有一个很大的不同：他们使用的端口。
ddns
smart dns
