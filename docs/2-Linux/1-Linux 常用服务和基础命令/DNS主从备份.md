---
title: DNS主从备份

categories:
  - Linux常用服务
series: 
  - DNS_Bind
lastmod: '2021-04-17'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



## 安装Bind

```bash
# Master & Slave
yum install bind -y
或 yum install -y bind-utils bind bind-devel bind-chroot
```
![image-20210525165231125](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Desktop/2021.05.25-17:17:10-C-Users-sjfdz-Desktop-image-20210525165231125.png)

## 主配置文件

> **编辑 vi /etc/named.conf**
>
> options{} 中添加修改如下


1. 主节点：
   ``` bash
   vi /etc/named.conf
   
   	listen-on port 53 { 10.4.7.101; };
   	allow-query     { any; };
   	forwarders      { 8.8.8.8;114.114.114.114; };
   ```
2. 从节点：

   ``` bash
   vi /etc/named.conf
   
   	listen-on port 53 { 10.4.7.102; };
   	allow-query     { any; };
   	forwarders      { 8.8.8.8;114.114.114.114; };
   ```

> **字段含义：主节点示例 cat /etc/named.conf**

``` bash
cat /etc/named.conf

options {
	listen-on port 53 { 10.4.7.101; };# 设置named监听的端口号、IP地址
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };# 允许DNS查询的客户端地址
    forwarders      { 8.8.8.8;114.114.114.114; };  # 设置上层DNS服务器

	recursion yes;
	
# 可关闭dnssec降低开销：       dnssec-enable no;       dnssec-validation no;
	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.root.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
# 可注释 		# include "/etc/named.root.key";

```
## 区域配置文件

> vi /etc/named.rfc1912.zones 末尾追加

1. 主节点

```bash
# vi /etc/named.rfc1912.zones
# 末尾追加

zone "host.com" IN {
        type master;
        file "host.com.zone";
        masterfile-format text;
        allow-transfer {10.4.7.102;};
        notify yes;
        also-notify {10.4.7.102;};
        allow-update {none;};
};

zone "ops.com" IN {
        type master;
        file "ops.com.zone";
        masterfile-format text;
        allow-transfer {10.4.7.102;};
        notify yes;
        also-notify {10.4.7.102;};
        allow-update {none;};
};

zone "7.4.10.in-addr.arpa" IN {
        type master;
        file "10.4.7-host.com.arpa";
        masterfile-format text;
        allow-transfer {10.4.7.102;};
        notify yes;
        also-notify {10.4.7.102;};
        allow-update {none;};
};
```
2. 从节点
```bash
# vi /etc/named.rfc1912.zones
# 末尾追加
zone "host.com" IN {
        type slave;
        file "slaves/host.com.zone";
        masters { 10.4.7.101; };
        masterfile-format text;
};

zone "ops.com" IN {
        type slave;
        file "slaves/ops.com.zone";
        masters { 10.4.7.101; };
        masterfile-format text;
};
zone "7.4.10.in-addr.arpa" IN {
        type slave;
        file "slaves/10.4.7-host.com.arpa";
        masters { 10.4.7.101; };
        masterfile-format text;
};
```
3. 单节点配置（如果你不想配置主从同步的话）

``` bash
zone "host.com" IN {
        type master;
        file "host.com.zone";
        allow-update { 10.4.7.101; }; //允许动态更新的客户端地址
};

zone "ops.com" IN {
        type master;
        file "ops.com.zone";
        allow-update { 10.4.7.101; };
};
```

## 区域数据文件

> 只需配置主节点，从节点待服务启动后会自动同步

+ 创建配置文件

   ```bash
   cp -a named.localhost 10.4.7-host.com.arpa
   cp -a named.localhost host.com.zone
   cp -a named.localhost ops.com.zone
   ```
   
+ 注意用户和权限
   ``` bash
   root@host7-101[21:17:14]:~$ ll /var/named/
   -rw-r----- 1 root  named  273 May 24 21:03 host.com.zone
   -rw-r----- 1 root  named  495 May 24 21:06 ops.com.zone
   -rw-r----- 1 root  named  364 May 25 05:28 10.4.7-host.com.arpa
   ```
+ 如果用户组不合法可能配置文件无法被reload服务启动会失败，权限不合法则可能无法完成主从同步、修改权限如下
   ```bash
   chgrp named /var/named/abcdocker.com.zone 
   chmod 640 /var/named/abcdocker.com.zone
   ```
1. host.com.zone 

   ```bash
   # vi host.com.zone 
   $TTL 1D
   @	IN SOA	ns.host.com.  email.outlook.com. (
   					2021052566	; serial
   					1D	; refresh
   					1H	; retry
   					1W	; expire
   					3H )	; minimum
   		NS		ns1.host.com.
   		NS		ns2.host.com.
   ns1	A	10.4.7.101
   ns2	A	10.4.7.102
   host7-101       A       10.4.7.101
   host7-102       A       10.4.7.102
   host7-103       A       10.4.7.103
   
   ```
2. ops.com.zone

   ```bash
   # vi  ops.com.zone
   $TTL 1D
   @       IN SOA  ns.ops.com.  email.outlook.com. (
                                           2021052560       ; serial
                                           1D      ; refresh
                                           1H      ; retry
                                           1W      ; expire
                                           3H )    ; minimum
           NS      ns1.ops.com.
           NS      ns2.ops.com.
   ns1	A	10.4.7.101
   ns2	A	10.4.7.102
   harbor	A	10.4.7.100
   kubernetes A    10.4.7.100
   ```

3. 10.4.7-host.com.arpa (反向解析可不配置)

   ```bash
   # vi 10.4.7-host.com.arpa 
   $TTL 1D
   @	IN SOA	ns.host.com email.outlook.com (
   					2021052560	; serial
   					1D	; refresh
   					1H	; retry
   					1W	; expire
   					3H )	; minimum
   	NS	ns1.host.com.
           NS      ns2.host.com.
   ns1	A	10.4.7.101
   ns2	A	10.4.7.102
   101	PTR	ns1.host.com.
   102	PTR	ns2.host.com.
   101	PTR	host7-101.host.com.
   102	PTR	host7-102.host.com.
   103 PTR	host7-103.host.com.
   ```

##  服务启动&验证

1. 启动服务并加入开机自启

   ```bash
   #  master & slave
   named-checkconf
   systemctl start named
   systemctl enable  named
   ```

2. 验证服务状态

   

   ```bash
   # 将各节点dns修改为10.4.7.101并重启网卡
   cat /etc/resolv.conf
   # Generated by NetworkManager
   search host.com
   nameserver 10.4.7.101
   # 重启网络之后，NetworkManager会自动更新/etc/resolv.conf，search host.com 表示默认会搜索host.com，即ping    host7-101.host.com的域名可以缩写为，ping host7-101 
   
   # 查看
   rpm -qa bind
   netstat -lntup|grep 53
   nslookup
   dig hdss7-22.host.com
   dig -t A hdss7-11.host.com @10.4.7.11 +short
   10.4.7.11
   ```

   若为虚机环境，可在windows宿主机配置如下

   自动跃点是为了优先走此网卡的DNS，可在宿主机用域名测试集群服务。

   ![image-20210526085734277](D:/assets/3.%20DNS%E4%B8%BB%E4%BB%8E%E5%A4%87%E4%BB%BD/image-20210526085734277.png)

   ![image-20210526085950452](D:/assets/3.%20DNS%E4%B8%BB%E4%BB%8E%E5%A4%87%E4%BB%BD/image-20210526085950452.png)

3. 验证主从同步

   ```
   重启两端服务，主节点启动时会向NS记录发送同步数据
   查看从节点
   root@host7-102[04:26:31]:/var/named/slaves$ pwd
   /var/named/slaves
   root@host7-102[04:26:35]:/var/named/slaves$ ll
   total 12
   -rw-r--r-- 1 named named 502 May 25 03:59 10.4.7-host.com.arpa
   -rw-r--r-- 1 named named 387 May 25 04:01 host.com.zone
   -rw-r--r-- 1 named named 382 May 25 03:59 ops.com.zone
   ```
   

在主节点/var/named/host.com.zone中增加一条A记录，并将 serial 值+1，然后rndc reload
这时message 会提示下图，在从节点查看zone文件是否同步


![image-20210525163114975](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/2.%20%E5%9F%BA%E7%A1%80%E9%85%8D%E7%BD%AE/2021.05.25-17:17:15-D-assets-2.%20%E5%9F%BA%E7%A1%80%E9%85%8D%E7%BD%AE-image-20210525163114975.png)

## 常见问题

也可写在主配置文件中，注意{}，若配置错误 named-checkconf 和日志里会提示主配置文件有误，并不会提示此文件错误，，，

1. ipv6
   
2. 没权限

3. 使用bind 配置DNS，主从无法同步 更新了主服务器的zone文件修改了serial这个值比SLAVE 服务器的值大，
   主服务器上更新区域后，但是从服务器却没有更新，但是删除从服务器上区域文件后，重新启动服务器才行，说明丛服务器是可以更新区域文件过来的，但是为什么却无法实时更新呢？

4. 

   #修改属组权限，否则同步容易出现问题
   
   ```
   [root@dns01-113 ~]# chgrp named /var/named/abcdocker.com.zone 
   [root@dns01-113 ~]# chmod 640 /var/named/abcdocker.com.zone
   ```
   
   从节点  主配置文件 ip
   
   从节点配置有误修改重启后，不能同步，主节点也要重启，才能同步，（两边同时重启

![image-20210525163526758](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/2.%20%E5%9F%BA%E7%A1%80%E9%85%8D%E7%BD%AE/2021.05.25-17:17:17-D-assets-2.%20%E5%9F%BA%E7%A1%80%E9%85%8D%E7%BD%AE-image-20210525163526758.png)
