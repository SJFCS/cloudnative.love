---
title: DNS
sidebar_position: 1
---

:::tip
主机名和FQDN
:::

DNS(Domain Name System, 域名系统) 
在本文中，您将学习 DNS 的基础知识，从 DNS 如何获取 IP 地址和主机名，到正向和反向查找区域的概念。它还将向您展示如何安装和配置 DNS，定义和编辑区域文件，并验证 DNS 是否可以通过命令帮助解析到正确的地址。如果您刚接触 DNS，本文将帮助您使用基本配置在系统上使用它。
推荐阅读书籍：《DNS & bind》

DNS主要是用于将域名解析为IP地址的协议，有时候也用于将IP地址反向解析成域名，所以DNS可以实现双向解析。

DNS可以使用TCP和UDP的53端口，基本使用UDP协议的53端口。


## 解析过程

https://ns1.com/resources/dns-types-records-servers-and-queries

当客户端搜索域时www.example.com，请求最初将转到 Internet 服务提供商 (ISP) 的解析器。它将响应用户请求解析域名。
如果在解析器上找不到 IP 地址，请求将转发到根 DNS 服务器，然后再转发到顶级域 (TLD) 服务器。
TLD 服务器存储顶级域的信息，例如.com或.net。
请求被转发到名称服务器，名称服务器知道有关域和 IP 地址的详细信息。
名称服务器响应 ISP 的解析器，然后解析器用请求的 IP 响应客户端。
当解析器不知道 IP 时，它会将 IP 及其域存储在缓存中以服务将来的查询。



1.本机查找完缓存后如果没有结果，会先查找hosts文件，如果没有找到再把查询发送给DNS服务器，但这仅仅是默认情况，这个默认顺序是可以改变的。在/etc/nsswitch.conf中有一行" hosts: files dns"就是定义先查找hosts文件还是先提交给DNS服务器的，如果修改该行为"hosts:  dns files"则先提交给DNS服务器，这种情况下hosts文件几乎就不怎么用的上了。

## 7.2.1 递归查询和迭代查询

例如A主机要查询C域中的一个主机，A所指向的DNS服务器为B，递归和迭代查询的方式是这样的：

递归查询：A --> B --> C --> B --> A

迭代查询：A --> B       A --> C --> A

DNS递归查询是指客户端向本地DNS服务器发出请求，本地DNS服务器会向根域名服务器发出请求，再向下级域名服务器发出请求，直到找到所需的DNS记录，然后返回结果给客户端。

DNS迭代查询是指客户端向本地DNS服务器发出请求，本地DNS服务器会向根域名服务器发出请求，并返回下一级域名服务器的地址给客户端。客户端会向下一级域名服务器发出请求，本地DNS服务器会重复这个过程，直到找到所需的DNS记录，然后返回结果给客户端。迭代查询是由客户端控制的，因为它负责在每个步骤中选择下一级域名服务器。



也就是说，递归的意思是找了谁谁就一定要给出答案。那么允许递归的意思就是帮忙去找位置，如A对B允许递归，那么B询问A时，A就去帮忙找答案，如果A不允许对B递归，那么A就会告诉B的下一层域的地址让B自己去找。

可以想象，如果整个域系统都使用递归查询，那些公共的根域和顶级域会忙到死，因此更好的方案就是把这些压力分散到每个个人定制的DNS服务器。

所以DNS的解析流程才会如下图。并且在客户端到DNS服务器端的这一阶段是递归查询，从DNS服务器之后的是迭代查询。也就是说，顶级域和根域出于性能的考虑，是不允许给其他任何机器递归的。





为什么客户端到DNS服务器阶段是递归查询？因为客户端本身不是DNS服务器，它自己是找不到互联网上的域名地址的，所以只能询问DNS服务器，最后一定由DNS服务器来返回答案，所以DNS服务器需要对这个客户端允许递归。因此，dns解析器(nslookup、host、dig等)所发出的查询都是递归查询。




## 7.2.5 资源记录(Resource Record,RR)

对于提供DNS服务的系统(DNS服务器)，域名相关的数据都需要存储在文件(区域数据文件)中。这些数据分为多种类别，每种类别存储在对应的资源记录(resource record,RR)中。也就是说，资源记录既用来区分域数据的类型，也用来存储对应的域数据。

DNS的internet类中有非常多的资源记录类型。常用的是SOA记录、NS记录、A记录(IPV6则为AAAA记录)、PTR记录、CNAME记录、MX记录等。

### (1).SOA记录：start of authority，起始授权机构。该记录存储了一系列数据，若不明白SOA记录，请结合下面的NS记录，SOA更多的信息见"子域"部分的内容。格式如下：

### (2).NS记录：name server，存储的是该域内的dns服务器相关信息。即NS记录标识了哪台服务器是DNS服务器。格式如下：

### (3).A记录：address，存储的是域内主机名所对应的ip地址。格式如下：

### (4).PTR记录：pointer，和A记录相反，存储的是ip地址对应的主机名，该记录只存在于反向解析的区域数据文件中(并非一定)。格式如下：

### (5).CNAME记录：canonical name，表示规范名的意思，其所代表的记录常称为别名记录。之所以如此称呼，就是因为为规范名起了一个别名。什么是规范名？可以简单认为是fqdn。格式如下：




## Forward and reverse lookups 正向和反向查找

正向查找区域使用域名搜索 IP 地址，而反向查找区域使用 IP 地址搜索域名。







## 7.2.2 权威服务器和(非)权威应答
权威服务器（Authoritative Server） 可以理解为直接上层域的DNS服务器。例如www.baidu.com这台主机的上层域是baidu.com，那么对www来说，它的权威服务器就是baidu.com这个域内负责解析的DNS服务器，而对于baidu.com这个主机来说，它的权威服务器是.com这个域负责解析的DNS服务器。

更具体的说，某域的权威服务器是可以直接查看该域数据(即区域数据文件)的DNS服务器，主、从DNS服务器都是权威服务器。

## 什么是 DNS zone ？
DNS区域是域命名空间的一个独特部分，它被委托给一个法律实体——负责维护 DNS 区域的个人、组织或公司。DNS 区域也是一种管理功能，允许对 DNS 组件（例如权威名称服务器）进行精细控制。

当 Web 浏览器或其他网络设备需要查找主机名（例如“example.com”）的 IP 地址时，它会执行 DNS 查找 - 本质上是 DNS 区域检查 - 并被带到管理 DNS 区域的 DNS 服务器那个主机名。该服务器称为域的权威名称服务器。然后，权威名称服务器通过为所请求的主机名提供 IP 地址或其他数据来解析 DNS 查找。
### DNS Zone Levels
域名系统 (DNS) 定义了域命名空间，它指定了顶级域（例如“.com”）、二级域（例如“acme.com”）和低级域，也称为子域（例如“support.acme.com”）。这些级别中的每一个都可以是一个 DNS 区域。

例如，根域“acme.com”可以委托给 Acme Corporation。Acme 负责设置权威的 DNS 服务器，该服务器保存域的正确 DNS 记录。

在 DNS 系统的每个层级，都有一个包含区域文件的名称服务器，该文件保存该区域的可信、正确的 DNS 记录。
### DNS Root Zone
DNS 系统的根，由域名末尾的一个点表示，例如 www.example.com. — 是主要 DNS 区域。自 2016 年以来，根区由互联网名称与数字地址分配机构 (ICANN) 监管，ICANN 将管理权委托给充当互联网号码分配机构 (IANA) 的子公司。

DNS 根区由 13 台逻辑服务器运营，这些服务器由 Verisign、美国陆军研究实验室和 NASA 等组织运营。任何递归 DNS 查询（了解有关DNS 查询类型的更多信息）都从联系这些根服务器之一开始，并请求树中下一级的详细信息——顶级域 (TLD) 服务器。
### TLD Zones
每个顶级域都有一个 DNS 区域，例如“.com”、“.org”或国家代码，例如“.co.uk”。目前有超过 1500 个顶级域。大多数顶级域由 ICANN/IANA 管理。

二级域名，如您现在查看的域名“ ns1.com ”，被定义为单独的 DNS 区域，由个人或组织运营。组织可以运行自己的 DNS 名称服务器，或将管理委托给外部提供商。


### Domain Zones
二级域名，如您现在查看的域名“ ns1.com ”，被定义为单独的 DNS 区域，由个人或组织运营。组织可以运行自己的 DNS 名称服务器，或将管理委托给外部提供商。

![1685590784551](image/README/1685590784551.png)

如果一个域有子域，它们可以是同一区域的一部分。或者，如果子域是一个独立的网站，并且需要单独的 DNS 管理，则可以将其定义为自己的 DNS 区域。在上图中，“blog.example.com”被设置为 DNS 区域，而“support.example.com”是“example.com”DNS 区域的一部分。


### Secondary DNS Zones
DNS 服务器可以部署在主要/次要拓扑中，其中次要 DNS服务器保存主要 DNS 服务器的 DNS 记录的只读副本。主服务器保存主区域文件，辅助服务器构成一个相同的辅助区域；DNS 请求分布在主服务器和辅助服务器之间。当主服务器区域文件全部或部分复制到辅助 DNS 服务器时，就会发生 DNS 区域传输。

https://ns1.com/resources/what-exactly-is-secondary-dns

### All About the DNS Zone File
### DNS Zone Types
区域文件有两种类型:

- A DNS Primary File which authoritatively describes a zone
  一个 DNS 主文件，它以权威的方式描述一个区域
- A DNS Cache File which lists the contents of a DNS cache—this is only a copy of the authoritative DNS zone
  列出 DNS 缓存内容的 DNS 缓存文件ーー这只是权威 DNS 区域的副本


### DNS Zone Records
DNS 区域记录

在区域文件中，每一行表示一个 DNS 资源记录(RR)。记录由以下字段组成:

Name is an alphanumeric identifier of the DNS record. It can be left blank, and inherits its value from the previous record.
Name 是 DNS 记录的字母数字标识符。它可以保留为空，并从以前的记录继承其值。
TTL (time to live) specifies how long the record should be kept in the local cache of a DNS client. If not specified, the global TTL value at the top of the zone file is used.
TTL (生存时间)指定记录应该在 DNS 客户机的本地缓存中保存多长时间。如果未指定，则使用区域文件顶部的全局 TTL 值。
Record class indicates the namespace—typically IN, which is the Internet namespace.
记录类指示命名空间ーー通常为 IN，即 Internet 命名空间。
Record type is the DNS record type—for example an A record maps a hostname to an IPv4 address, and a CNAME is an alias which points a hostname to another hostname.
记录类型是 DNS 记录类型ーー例如，A 记录将主机名映射到 IPv4地址，CNAME 是将主机名指向另一个主机名的别名。
Record data has one or more information elements, depending on the record type, separated by a white space. For example an MX record has two elements—a priority and a domain name for an email server.
根据记录类型，记录数据有一个或多个信息元素，它们之间用空格分隔。例如，MX 记录有两个元素: 优先级和电子邮件服务器的域名。




### Zone File Structure
区域文件结构
DNS 区域文件以两个强制记录开始:

Global Time to Live (TTL), which specifies for how records should be kept in local DNS cache.
全局生存时间(TTL) ，指定记录应如何保存在本地 DNS 缓存中。
Start of Authority (SOA) record—specifies the primary authoritative name server for the DNS Zone.
Start of Authority (SOA)记录ー指定 DNS 区域的主要权威名称服务器。
After these two records, the zone file can contain any number of resource records, which can include:

在这两条记录之后，区域文件可以包含任意数量的资源记录，这些记录可以包括:

Name Server records (NS)—specifies that a specific DNS Zone, such as “example.com” is delegated to a specific authoritative name server
Name Server record (NS)ー指定将特定的 DNS 区域(如“ example.com”)委托给特定的权威名称服务器
IPv4 Address Mapping records (A)—a hostname and its IPv4 address.
IPv4地址映射记录(A)ーー主机名及其 IPv4地址。
IPv6 Address records (AAAA)—a hostname and its IPv6 address.
IPv6地址记录(AAAA)ーー主机名及其 IPv6地址。
Canonical Name records (CNAME)—points a hostname to an alias. This is another hostname, which the DNS client is redirected to
规范名称记录(CNAME)ー将主机名指向别名。这是另一个主机名，DNS 客户端将重定向到该主机名
Mail exchanger record (MX)—specifies an SMTP email server for the domain.
邮件交换器记录(MX)ー指定域的 SMTP 电子邮件服务器。





DNS Zone File Example
DNS 区域文件示例









## Secondary DNS 辅助 DNS 究竟是什么？





https://www.redhat.com/sysadmin/dns-configuration-introduction

https://www.cnblogs.com/f-ck-need-u/p/7367503.html

- https://wiki.archlinux.org/title/Dnscrypt-proxy
- https://www.v2ex.com/t/742709
- https://boce.aliyun.com/detect/dns/DNS_PING-55e41bb2aff9db99decd9d9da1be445d-1652369079406

https://www.cnblogs.com/f-ck-need-u/p/7367503.html

https://www.thesslstore.com/blog/dns-over-tls-vs-dns-over-https/
https://developers.google.com/speed/public-dns/docs/dns-over-tls?hl=zh-cn
https://developers.google.com/speed/public-dns/docs/using?hl=zh-cn
https://ns1.com/resources/dns-zones-explained

Dnscrypt-proxy
DNS over TLS 和 DNS over HTTPS
DNS-over-TLS
基于 TLS 的 DNS (DoT) 和基于 HTTPS 的 DNS (DoH) 听起来它们是同一事物的可互换术语。他们实际上完成了同样的事情——加密 DNS 请求——但有一个很大的不同：他们使用的端口。
