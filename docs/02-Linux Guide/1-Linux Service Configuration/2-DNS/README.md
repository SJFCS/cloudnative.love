---
title: DNS
sidebar_position: 1
---


fqdn



DNS(Domain Name System, 域名系统)用于正向查找（Forward Lookup）查找域名对应的IP地址和反向查找（Reverse Lookup）查找 IP 地址对应的域名。

:::tip

- DNS 可以使用 TCP 和 UDP 的 53 端口，基本使用 UDP 协议的 53端口。

- FQDN 通常为 `主机名.DNS域`
- Linux 中可以修改 `/etc/nsswitch.conf` 文件中 `hosts: files dns` 来定义 hosts 文件和 DNS 服务器的查找优先级
:::

## DNS Zone

![1685590784551](image/README/1685590784551.svg)

在 DNS 树结构中，根域是最高级别的域，位于 DNS 树的顶部。根域是一个特殊的域，它没有名称，只有一个点号`.`来代表它本身。根域的作用是提供 DNS 树的起点，为 DNS 解析提供基础支持。当 DNS 客户端发起一个查询时，它会首先向其本地 DNS 服务器发送查询请求，如果本地 DNS 服务器无法解析查询请求，则会向根域名服务器发送查询请求，以获取相应的顶级域名服务器信息。

除了根域之外，DNS 区域可以分为以下几种类型：

- **主区域**  
  主区域是指 DNS 服务器上存储的原始 DNS 数据。管理员可以在主区域文件中定义 DNS 资源记录，这些记录在整个 DNS 环境中起着关键作用。
- **从属区域**  
  从属区域是指 DNS 服务器上存储的与主区域相同或相似的 DNS 数据。从属区域可以让 DNS 管理员创建分布式 DNS 环境，以提高性能和可靠性。
- **反向区域**  
  反向区域是指通过 IP 地址反向查找主机名的 DNS 区域。在反向区域中，管理员可以定义 PTR 记录，将 IP 地址映射到相应的主机名。

:::tip 权威服务器和(非)权威应答
权威服务器（Authoritative Server） 可以理解为直接上层域的 DNS 服务器。

例如 `demo.example.com` 对于 `demo` 主机的上层域是 `example.com`，即为它的权威服务器。

更具体的说，某域的权威服务器是可以直接查看该域数据(即区域数据文件)的 DNS 服务器，主、从DNS服务器都是权威服务器。
:::

## 递归查询和迭代查询

假如 Host A 默认指向 DNS Server B 当查询 `demo.example.com` 的 IP 地址时查询流程应该如下所示

- **递归查询**  
  Host A --> DNS Server B --> `.` --> `com.` --> `example.`--> DNS Server B --> Host A
- **迭代查询**  
  Host A --> DNS Server B --> A  
  Host A --> `.` --> A  
  Host A --> `com.` --> A  
  Host A --> `example.` --> A  

上面演示了没有缓存的情况下递归查询和迭代查询的完整过程。

:::tip
- 顶级域和根域出于性能的考虑，是不允许给其他任何机器递归的。通常客户端到 DNS 服务器端的这一阶段是递归查询，从 DNS 服务器之后的是迭代查询。

- nslookup、host、dig 等所发出的查询都是递归查询。

- 在下面两种情况下，不需要额外的查询轮次（如递归或迭代查询），它会立即返回 DNS 记录返回给客户端:
  - 第一种情况是当 DNS 服务器本地或者缓存中已经存在所需的 DNS 记录时，它可以直接返回记录给客户端。
  - 第二种情况是当通过 DNS 权威服务器查询其下主机，也会立即返回 DNS 记录返回给客户端。  
    例如 Host A 默认指向 `example.com` 当查询 `demo.example.com` 会立即返回 DNS 记录返回给客户端
:::

## 资源记录(Resource Record,RR)

参考 [DNS资源纪录(Resource Record)介绍](http://dns-learning.twnic.net.tw/bind/intro6.html)

域名相关的数据都需要存储在文件(区域数据文件)中。这些数据分为多种类别，每种类别存储在对应的资源记录(resource record,RR)中。

- SOA  
  Start Of Authority，起始授权机构，该记录出现在 DNS 区域文件的开头，记录当前 DNS 区域的授权名称服务器、域管理员的详细联系信息、域序列号以及 DNS 信息的刷新频率。每一个记录档只能有一个 SOA，而且一定是档案中第一个“记录”，
  下面的示例分别是 "school.edu.tw" 和 "root.school.edu.tw" 也就是school.edu.tw 主机和 root 的信箱。这里要注意的是我们以 "root.school.edu.tw" 代表 "root@school.edu.tw"   
  ```
  @    IN      SOA          school.edu.tw. root.school.edu.tw.  ( 
                                    1999051401      ; Serial 
                                    3600            ; Refresh 
                                    300             ; Retry 
                                    3600000         ; Expire 
                                    3600 )          ; Minimum
  ```
  在两个括号中间的选项表示SOA的设定内容，底下会有更详细的说明。

- NS  
  name server，标识了该域内的 DNS 服务器相关信息。需注意的是不可以IP位址表示。
  ```
  IN  NS   dns.twnic.net.tw.
  ```
- A  
  address，将 DNS 网域名称对应到 IPv4 的 32 位元位址。
  ```
  server  IN  A  140.123.102.10
  ```
- AAAA  
  可将 DNS 网域名称对应到 IPv6 的 128 位元位址。
  ```
  twnic.net.tw.  86400  IN  AAAA  3ffe: :bbb:93:5
  ```

- PTR    
  pointer，定义某个 IP 对应的 domain name，即将 IP 位址转换成主机的 FQDN （反向 DNS 查找）。
  ```
  20   IN  PTR  mail.twnic.net.tw.
  ```
- CNAME  
  canonical name，表示规范名的意思，其所代表的记录常称为别名记录。可为同一部主机设定许多别名，例如 mix.twnic.net.tw 的别名可为 www.twnic.net.tw 和 ftp.twnic.net.tw ，因此所设定的别名都会连至同一部伺服器。
  ```
  www  IN  CNAME  mix
  ```
- MX 
  mail exchanger，指定域的 SMTP 电子邮件服务器，而数字则是该主机邮件传递时的优先次序，此值越低表示有越高的邮件处理优先权。
  ```
  server  IN   MX  10  mail.twnic.net.tw.
  ```
- CERT  
  证书记录，存储加密证书 PKIX、SPKI、PGP 等。
- SRV  
  服务位置记录，类似于 MX，但用于其他通信协议。
- TXT  
  文本记录通常携带机器可读的数据，例如机会加密、发送者策略框架、DKIM、DMARC 等。

- **SOA设定内容说明**  
  SOA record，以之前例子来看，其中@ 这个符号是缩写，代表named.conf 中这个zone file 所对应的zone。SOA 后面的两个参数是指这个zone file 是在哪部主机(school.edu.tw)定义的，以及这个zone file 的负责人(注意是写成root.school.edu.tw)，然后是用括号括起来的5 个参数， 分别由底下说明。

  - Serial  
    代表这个zone file 的版本，每当zone file 内容有变动，name server 管理者就应该增加这个号码，因为slave 会将这个号码与其copy 的那份比对以便决定是否要再copy 一次(即进行zone transfer)。

  - Refresh
    slave server 每隔这段时间(秒)，就会检查 master server 上的 serial number。  
    不过这里会发生一个问题就是，在 master server 在update data 完成到 slave server 来检查时再 update 可能还有 好一段时间，因此这段期间 master/slave DNS server 间 zone files 就可能出现不一致。  
    所以在 Bind 较新的版本中便加入"notify"功能，使用者在"named.conf" 设定中在需要的 zone 中加入"notify"的设定，则 master server在 update 完成某个 zone file 的 data 后便会主动发个讯息(NOTIFY)，借以通知该其它的 slave servers，因此如果 slave servers 也有支援这个"notify"功能时，接下来 slave servers 马上就可以做 zone transfer 来 update data。
    ```
    zone "twnic.com.tw" { 
    type master;
    file "twnic.hosts";
    notify yes;
    also-notify { 192.168.10.1; }; //指定slave server的IP位址
    };
                
    区域“twnic.com.tw”{
      类型母版;
      文件 “twnic.hosts”;
      通知是;
      also-notify { 192.168.10.1; }; //指定slave server的IP位址
    };
    ```
  - Retry  
    当 slave server 无法和 master 进行 serial check 时，要每隔几秒 retry 一次。
  - Expire  
    当时间超过 Expire 所定的秒数而 slave server 都无法和 master 取得连络，那么 slave 会删除自己的这份 copy。
  - Minimum  
    代表这个 zone file 中所有 record 的内定的 TTL 值，也就是其它的 DNS server cache 这笔 record 时，最长不应该超过这个时间。



## 更多

- https://ns1.com/resources/dns-types-records-servers-and-queries
- https://ns1.com/resources/dns-zones-explained
- https://www.redhat.com/sysadmin/dns-configuration-introduction
- https://www.cnblogs.com/f-ck-need-u/p/7367503.html

- https://www.v2ex.com/t/742709
- https://boce.aliyun.com/detect/dns/DNS_PING-55e41bb2aff9db99decd9d9da1be445d-1652369079406
- https://www.cnblogs.com/f-ck-need-u/p/7367503.html
- https://www.thesslstore.com/blog/dns-over-tls-vs-dns-over-https
- https://developers.google.com/speed/public-dns/docs/dns-over-tls?hl=zh-cn
- https://developers.google.com/speed/public-dns/docs/using?hl=zh-cn
- [Dnscrypt-proxy](https://wiki.archlinux.org/title/Dnscrypt-proxy)
- DNS over TLS 和 DNS over HTTPS
- 基于 TLS 的 DNS (DoT) 和基于 HTTPS 的 DNS (DoH) 听起来它们是同一事物的可互换术语。他们实际上完成了同样的事情——加密 DNS 请求——但有一个很大的不同：他们使用的端口。
- ddns
- smart dns
