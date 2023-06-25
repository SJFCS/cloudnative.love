---
title: Bind
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Bind 的全名是 Berkeley Internet Name Domain，最初的时候是由加州大学柏克莱分校所发展出来的 BSD UNIX 中的一部份，目前则由 ISC 组织来负责维护与发展。是目前最常用的开源 DNS 服务器软件之一，广泛应用于互联网和企业内部网络中。

## 安装

可以使用以下命令安装并启动 isc-dhcp-server 和 isc-dhcp-relay。

<Tabs>
<TabItem value="Ubuntu/Debian">

```bash
sudo apt-get update && sudo apt-get install bind9
dpkg -L bind9
sudo systemctl enable --now 
```
</TabItem>
<TabItem value="CentOS/RedHat">

```bash
sudo yum install bind
yum install -y bind-utils bind bind-devel bind-chroot
rpm -ql named
sudo systemctl enable --now named
sudo systemctl enable --now named
```
</TabItem>
</Tabs>

## named.conf 配置说明

Bind 的主要设定档为 named.conf 档案主要的内容包含4个部分:

- options
- "." 根域的内容
- localhost 的正反解
- 其他 domain 的正反解

### copy
```
acl internals { 192.168.10.0/24; };				
我们先看一个完整的named.conf 的档案:

options {
directory "/var/named";
allow-transfer{ 192.168.11.7;
                internals;
};
};
controls {
inet 127.0.0.1 allow { localhost; } keys { rndckey; };
};
zone "." {                         //.(root) 的內容
type hint;
file "named.ca";                 
};
zone "localhost"{                  //localhost 的正解
type master;
file "localhost.zone";            
};
zone "0.0.127.in-addr.arpa"{       //localhost 的反解
type master;
file "named.local";                
};
zone "twnic.com.tw"{               //使用者domain的正解
type master;
file "twnic.hosts";                
};
zone "10.168.192.in-addr.arpa"{    //使用者domain的反解
type master;
file "twnic.rev";                  
};
```

由上例关于named.conf 的设定档中可分为许多不同的类型，不同类型皆由{}包起来，以下说明不同设定的类型。

1. acl : 定义一份IP位址对应清单，以利存取时的控制。
```
acl internals { 192.168.10.0/24; };
```				
定义IP位址清单范围为192.168.10.0/24，而"internals"为使用者可自行定义的acl 名称，
设定acl后对于之后相关存取设定时(eg allow-query、allow-transfer...等等)，
便可直接使用acl 名称来代表之前所设定的IP范围。

2. options :控制通用的伺服器组态，设定其他选项的预设值。
```
options {
directory “/var/named”;
allow-transfer{ 192.168.11.7;
                internals;
};
```
表示将named 的区域纪录档(zone file)储存在/var/named 的目录中，
也就是Bind伺服器中所有DNS纪录档案都集中于此。此外，在往后的"DNS Server型态"中会提到的forwarder，
其设定也是加在options内。

至于allow-transfer 选项，它指定DNS 对于特定IP 位址的zone transfer。举例来说， 
我们允许IP 位址为192.168.11.7和IP 范围192.168.10.0/24(由acl定义名称为"internals"，
于之后介绍acl)的主机(可能是我们网域上的一个次要DNS伺服器)请求zone transfer。
如果您漏了这个选项，位于Internet 的任何人都可以请求这个转换。

3. controls :宣告使用ndc程式时控制的方式。
```
controls {
inet 127.0.0.1 allow { localhost; } keys { rndckey; };
};
```

其中”inet”表示利用TCP/IP Socket来存取Internet资源，它是由指定的”ip_addr”(IP address)和”ip_port”(ip_port)所产生，
而此处表示可允许本机(localhost)利用键值(rndckey)进行存取，
此设定会在"DNS server 安全防护"中有详细的说明。

4. zone :定义zone，所谓zone是只DNS伺服器管理时的逻辑单位， 例如*.twnic.net或*.dns.twnic.net在每个区域中至少须存在一部DNS伺服器。
```
zone "." {  
type hint;
file "named.ca";
};
```
定义“.”，Internet DNS 最上层的位置，而file "named.ca"指定了其记录档(zone file)名称。记录档都存放在/var/named 这个目录下面，也就是前面options 指定的directory。
```
zone "twnic.com.tw"{
type master;
file "twnic.hosts";
};
```
定义twnic.com.tw 这个网域，是网域的正解设定，而其型态(type)是master DNS server，指定区域纪录档(zone file)为”twnic.hosts”。
```
zone "10.168.192.in-addr.arpa"{
type master;
file "twnic.rev";
};
```
这个部份就和上述的设定是相互配合的，是网域的反解设定。要特别注意的是in-addr.arpa 是固定的定义格式，不可改变。而在设定反查询区域的时候﹐您一定要将您的net ID 部份反过来写。例如﹕本地网路为192.168.0.0/24 ﹐它的反查询区域名则是﹕“0.168.192.in-addr.arpa”﹔如果我将netmask 改为16bit﹐即192.168.0.0/16﹐它的反查询区域名就会变成﹕“168.192.in-addr.arpa”。



### options
该配置文件中只能有一个 options，在这里面用于配置全局项。其中下例中的 directory 指令定义区域数据文件的存放目录。

```bash
options {
    directory "/var/named";
};
```

### "." 根域
```bash
zone "." IN {
    type hint;
    file named.ca;
}
```
type hint表示该区域"."类型为hint。
回顾dns解析流程，在客户端让dns服务器迭代查询时，迭代查询的第一步就是让dns服务器去找根域名服务器。但是dns服务器如何知道根域名服务器在哪里？这就是hint类型的作用，它提示dns服务器根据其区域数据文件named.ca中的内容去获取根域名地址，并将这些数据缓存起来，下次需要根域名地址时直接查找缓存即可。

由于根域名地址也是会改变的，有了根区域的提示，就可以永远能获取到最新的根区域地址。其实也可以手动下载这些数据，地址为：https://www.internic.net/domain/named.root

因此，只有根区域"."才会设置为hint类型。

在档案中行首出现";"符号，表示该行内容为注解，此外以"."为首的13个设定内容(Eg 3600000 IN NS A.ROOT-SERVERS.NET.)，则表示13个root 名称伺服器的名称，而每笔皆由4个栏位所组成，'3600000'是TTL(Time To Live)，也就是此纪录在快取中保留的时间(秒)。'IN'表示这是一个internet 地址类型，'NS'是"Name Server"的缩写，它是DNS资源纪录的一种类型，而其后的"A.ROOT-SERVERS.NET."就是表示伺服器的FQDN。其后紧接着另一纪录(EgAROOT-SERVERS.NET. 3600000 A 198.41.0.4)则是纪录此伺服器名称所对应的IP，'A'也是资源纪录的一种类型，之后会有资源纪录的详细介绍。



### "localhost"域名(用于解析localhost为127.0.0.1)和127.0.0.1的方向查找区域。这两个没有定义在named.conf中，而是定义在/etc/named.rfc1912.zones中，然后在named.conf中使用include指令将其包含进来。

```bash
include "/etc/named.rfc1912.zones";
```
其中named.rfc1912.zones中部分内容：

```bash
zone "localhost" IN {
        type master;
        file "named.localhost";
        allow-update { none; };
};
 
zone "1.0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-update { none; };
};
``
当然，反向查找区域可以定义为域而不是直接定义成主机。例如：

```bash
zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-update { none; };
};
```
但这样的话，就需要相对应地修改/var/named/named.loopback文件。

其实根域名"."和"localhost"以及"1.0.0.127.in-addr.arpa"完全没必要去改变，照搬就是了。

所以，/etc/named.conf的内容如下：

```bash
[root@xuexi ~]# cat /etc/named.conf
options {
    directory "/var/named";
};
 
zone "longshuai.com" {
    type master;
    file "db.longshuai.com";
};
 
zone "." IN {
    type hint;
    file "named.ca";
};
 
include "/etc/named.rfc1912.zones";
```
:::caution
/etc/named*的属组都是named，且权限要为640。

```bash
chown root:named /etc/named.conf
chmod 640 /etc/named.conf
```

然后使用/usr/sbin/named-checkconf命令来检查下/etc/named.conf文件的配置是否正确，如果不返回任何信息，则表示配置正确。
```bash
named-checkconf
```
:::

#### 设定/etc/named/named.local档案
这个纪录档是指"0.0.127.in-addr.arpa"区域的反解纪录档。此档案的预设内容如下:

```
$TTL    86400
@       IN      SOA     localhost. root.localhost.  (
                                      1997022700 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
              IN      NS      localhost.

1       IN      PTR     localhost.
```
以上档案与之前介绍的localhost.zone档案类似，不一样的地方是在最后一行。它是一笔"PTR"纪录，也就是反向解析的纪录，它与"A"的功能刚好相反。

在说明最后一行之前，先解释"in-addr.arpa"，此为DNS在标准中定义的特殊网域，借以提供可靠的反向查询方法。

127.0.0.1所对应的主机名称为localhost，因为这里是反向查询，所以IP 顺序是倒过来写的，于是这个反查询IP 就是"1.0.0.127.in-addr.arpa."。由于此处的ORIGIN(@)定义为"0.0.127.in-addr.arpa."，所以在纪录档中如果名称没有包含小数点，则会自动补上$ORIGIN或是网域名称的字尾。因此，最后一行的开始为"1"，其实就是"1.0.0.127.in-addr.arpa."的意思。
### 其他 domain

zone关键字后面接的是域和类，域是自定义的域名。
IN是internet的简称，是bind 9中的默认类，可以省略。
type定义该域的类型是"master | slave | stub | hint | forward"中的哪种，
file定义该域的区域数据文件(区域数据文件的说明见下文)，因为这里是相对路径db.longshuai.com，它的相对路径是相对于/var/named的，也可以指定绝对路径/var/named/db.longshuai.com。

```bash
zone "longshuai.com" IN{
    type master;
    file "db.longshuai.com"
};
```



:::tip 拆分配置文件 include

bind 所有配置都要写在named.conf 吗  可以分开吗
不一定，Bind可以将配置分散在多个文件中。在named.conf中，可以使用include语句来引用其他配置文件，例如：

include "/path/to/other/file.conf";
:::



```bash
[root@servera ~] # vim /etc/named.conf
listen-on port 53 { 127.0.0.1; <DNS server address>; };
allow-query { localhost; any; };
```

## 定义正向和反向区域


在/etc/named.conf 或/etc/named.rfc1912.zone 中定义正向和反向区域(您可以在这两个文件中的任何一个中定义区域)。在本例中，我将区域定义细节附加到/etc/named.rfc1912.zone 文件。

```bash
[root@servera ~] # vim /etc/named.rfc1912.zones
  zone "example.com" IN { type master;
  file "example.forward.zone";
  allow-update { none; };
};

  zone "25.168.192.in-addr.arpa" IN { 
   type master;
   file "example.reverse.zone";
   allow-update { none; };
};
```

## 创建正向和反向区域文件

您还需要在/var/命名目录中创建正向和反向区域文件。

注意: 默认情况下，named.conf 文件包含用于检查区域文件的/var/name 目录。在安装 BIND 包期间，将创建名为 ed.localhost 和 named.loop back 的示例区域文件。

:::caution 将名称服务器 IP 添加到/etc/Resolv.conf

首先，必须禁用 NetworkManager 的 DNS 处理，因为它使用活动连接配置文件中的 DNS 设置动态更新/etc/Resolv.conf 文件。若要禁用此选项并允许手动编辑/etc/Resolv.conf，必须创建一个文件(例如，90-dns-none。Conf) ，作为/etc/NetworkManager/conf/目录中的根目录，该目录包含以下内容:
```
[main]
dns=none
```

保存文件并重新加载(重新启动) NetworkManager。
systemctl reload NetworkManager


重新加载 NetworkManager 后，它不会更新/etc/Resolv.conf。现在，您可以手动将名称服务器的 IP 地址添加到/etc/Resolv.conf 文件中。

```bash
[root@servera ~] # vim /etc/resolv.conf
# Generated by NetworkManager 
#search localdomain example.com 
#nameserver 192.168.25.132

domain twnic.com.tw
nameserver 192.168.10.1
nameserver 192.168.2.5
search twnic.com.tw twnic.net.tw
```
- “domain”指定本地的网域名称，如果查询时的名称没有包含小数点，则会自动补上此处的网域名称为字尾再送给DNS伺服器。
- “nameserver”指定用户端要求进行名称解析的nameserver IP位址，在此可指定多部DNS伺服器，则用户端将会依序提出查询要求。
- “search”这个选项为非必要选项，而功能在于若使用者指定主机名称查询时，所需要搜寻的网域名称。例如，当我们设“search twnic.com.tw”时，当DNS伺服器在做名称解析过程中，无法对输入的名称，例如pc1，找出相对应的IP时，则DNS会利用search的设定值加上需查询的名称，即pc1.twnic.com.tw来进行解析，解析失败时则会尝试pc1.twnic.net.tw。
需要注意的是当我们想尝试多种在没有包含小数点，于字尾补上所需要搜寻的网域名称时，我们会在"search"中指定几种组合给DNS伺服器，而不能在"domain"中指定。因为“domain”是指定本地的网域名称，而搜寻时也以“domain”为优先尝试，如果失败之后才会尝试"search"中的组合。
:::



## DNS server型态(type)
在bind的设定档named.conf中，可设定的伺服器型态共有5种:

1.  master: 主要伺服器，在网域中负责名称解析。
2.  slave: 为了避免master发生故障时影响网路上的名称解析工作，可以安装其他的DNS伺服器，并且会定期复制master中的资料。
3.  stub: 与slave类似，但只会复制master的NS纪录，而非所有区域(zone)资讯。
4.  hint: 表示为root伺服器。
5.  forward: 可将来自用户端的名称解析要求代为转送至其他伺服器。
    
### 设定master/slave server
    
透过master 和slave 的架构，要进行资料变更的时候﹐只需在master上面 维护就好，然后slave 会定期的自动过来将更新资料同步回去。而slave 会在 refresh 时间到达的时候，就尝试和master 进行资料同步的动作，这在DNS 系统里面有一个专门术语﹐叫做“zone transfer”(区域转移)。
    
    
### 设定hint:
    
``` 
zone "." {                 // 表示這是對於.(root)的解析。
    type hint;             // 型態為hint。
    file "named.ca";       // 讀取的檔案為named.ca
};
```
    
### 设定master:

```
zone "twnic.com.tw"{
type master;
file "named.cs";
};
```
    
### 设定slave:
    
``` 
zone "mlc.com.tw" {           
       type slave;                    
       file "slave/slave.mlcnet"; 
       masters { 163.19.163.7; };
};
```
    
    
slave的设定只不过将type master改为slave并额外加入master的IP位址。
    
### 设定forwarder
    
我们除了能够用slave 来分担master 工作、减少网路流量之外，还可以透过 另外一种DNS 机制来减低网路流量的，那就是forwarder 设定了。所谓的forwarder，就是当某一台name server主机遇到非本机负责zone之查询请求的时候，将不直接向root zone 查询而把请求转交给指定的forwarder (一台或多台) 主机代为查询。如果name server上面指定了forwarder，那这个name server发现cache 没 有记录的话，将不向root 查询，而是将自己扮成一个client，向forwarder 送 出同样的请求，然后等待查询结果；而逐级往下查询的动作，则交由forwarder 负责﹐name server自己就轻松多了。但无论这个结果是自己直接查询得来的﹐还是forwarder 送回来的，name server都会保存一份资料在cache 中。这样，其后的相同查询就快多了，这对于name server所服务的client 而言更是有效率得多。

```
options {
.....
forwarders {   
139.175.10.20;     //設定forwarder的IP位址
168.95.1.1; };
};
``` 

