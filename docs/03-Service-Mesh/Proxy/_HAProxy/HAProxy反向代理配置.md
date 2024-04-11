---
title: HAProxy反向代理配置
tags:
  - posts
categories:
  - 负载均衡
series: 
  - HAProxy
lastmod: '2021-07-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---



<!--more-->



## HAProxy概述：

　　HAProxy提供高可用性、负载均衡以及基于TCP和HTTP应用的代理，支持虚拟主机，它是免费、快速并且可靠的一种解决方案。根据官方数据，其最高极限支持10G的并发。
　　HAProxy特别适用于那些负载特大的web站点，  这些站点通常又需要会话保持或七层处理。HAProxy运行在当前的硬件上，完全可以支持数以万计的并发连接。并且它的运行模式使得它可以很简单安全的整合进您当前的架构中， 同时可以保护你的web服务器不被暴露到网络上。
其支持从4层至7层的网络交换，Haproxy 甚至还支持 Mysql的均衡负载。

**HAProxy的特点是：**
1、支持两种代理模式：TCP（四层）和HTTP（七层），支持虚拟主机；
2、能够补充Nginx的一些缺点比如Session的保持，Cookie的引导等工作
3、支持url检测后端的服务器出问题的检测会有很好的帮助。
4、更多的负载均衡策略比如：动态加权轮循(Dynamic Round Robin)，加权源地址哈希(Weighted Source Hash)，加权URL哈希和加权参数哈希(Weighted Parameter Hash)已经实现
5、单纯从效率上来讲HAProxy更会比Nginx有更出色的负载均衡速度。
6、HAProxy可以对Mysql进行负载均衡，对后端的DB节点进行检测和负载均衡。
9、支持负载均衡算法：Round-robin（轮循）、Weight-round-robin（带权轮循）、source（原地址保持）、RI（请求URL）、rdp-cookie（根据cookie）
10、不能做Web服务器。

> 　　www.haproxy.org
> 　　http://haproxy.com/ 
> 　　http://haproxy.1wt.eu/ 
> 　　https://github.com/haproxy/haproxy/releases/ 
>
> 文档：http://www.ttlsa.com/linux/haproxy-study-tutorial/

## 二进制安装

### 安装编译环境依赖

```
yum -y install make gcc gcc-c++ openssl-devel
```

### 编译HAProxy二进制文件

**配置编译参数**

```
tar -zxvf haproxy-1.7.9.tar.gz && cd /root/haproxy-1.7.9
useradd haproxy -r -M -s /sbin/nologin
uname -r   #查看内核版本
3.10.0-693.el7.x86_64
make TARGET=linux2628  ARCH=X86_64 PREFIX=/var/lib/haproxy #指定操作系统内核类型和安装的路径。也可以直接修改Makefile配置文件中这
两个变量的值。如下：
vim Makefile
94 PREFIX = /var/lib/haproxy
104 TARGET =linux26
```

![img](https://images2018.cnblogs.com/blog/47893/201807/47893-20180704232950077-462259532.png)

**编译HAProxy**

```
make install PREFIX=/var/lib/haproxy  
#如果没有修改Makefile配置文件中PREFIX变量的值，就必须在此重新对，PREFIX=/var/lib/haproxy赋值，否则直接执行 make install 时，make install会直接读取Makefile文件中PREFIX的变量值。
```

## 负载均衡配置

### 负载均衡配置参数

```bash
vim /usr/local/haproxy/etc/haproxy.cfg      #手动创建配置文件
#---------------------------------------------------------------------
# 全局设置
#---------------------------------------------------------------------
global
    log 127.0.0.1  local2 #日志文件的输出定向。产生的日志级别为local3. 系统中local1-7，用户自己定义
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid  #将所有进程写入pid文件
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon						#以后台形式运行haproxy
    stats socket /var/lib/haproxy/stats
#nbproc 1  #启动1个haproxy实例。应该设置成和CPU核心数一样。
#debug      #调试错误时用
#quiet      #安静

#---------------------------------------------------------------------
# 所有 "listen "和 "backend "部分的共同默认值是，如果在他们的块中没有指定的话
#---------------------------------------------------------------------
defaults
    mode                    http    #工作模式，所处理的类别,默认采用http模式，可配置成tcp作4层消息转发
    log                     global
    option                  httplog #日志类别，记载http日志
#    option  httpclose      #每次请求完毕后主动关闭http通道,haproxy不支持keep-alive,只能模拟这种模式的实现
    option                  dontlognull #不记录空连接，产生的日志
    option http-server-close
    option forwardfor       except 127.0.0.0/8 #如果后端服务器需要获得客户端真实ip需要配置的参数，可以从Http Header中获得客户端ip
    option                  redispatch  #当serverid对应的服务器挂掉后，强制定向到其他健康服务器
    retries                 3  #3次连接失败就认为服务器不可用，主要通过后面的check检查
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s #连接超时时间。 单位：ms 毫秒
    timeout client          1m  #客户端连接超时时间
    timeout server          1m  #服务器端连接超时时间
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

balance roundrobin                    #负载均衡算法
stats  uri    /haproxy-stats          #haproxy 监控页面的访问地址 # 可通过 http://localhost:80/haproxy-stats 访问
option  httpchk GET /index.html       #健康检测#注意实际工作中测试时，应该下载某一个页面来进行测试，因此这个页面应该是个小页面，而不要用首页面。这里是每隔一秒检查一次页面。

#---------------------------------------------------------------------
# frontend前端配置
#---------------------------------------------------------------------
frontend  main *:5000
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js

    use_backend static          if url_static
    default_backend             app
# frontend http          #前端配置，http名称可自定义
# bind 0.0.0.0:80        #发起http请求80端口，会被转发到设置的ip及端口
# default_backend app   #转发到后端 写上后端名称
#---------------------------------------------------------------------
# static backend 静态后端，用于提供图像、样式表等。
#---------------------------------------------------------------------
backend static
    balance     roundrobin
    server      static 127.0.0.1:4331 check
#---------------------------------------------------------------------
# 各种后端之间的循环平衡
#---------------------------------------------------------------------
backend app      #后端配置，名称上下关联
    balance     roundrobin
    server  app1 127.0.0.1:5001 check inter 2000 rise 3 fall 3 weight 40
    server  app2 127.0.0.1:5002 check inter 2000 rise 3 fall 3 weight 30
    server  app3 127.0.0.1:5003 check inter 2000 rise 3 fall 3 weight 20
    server  app4 127.0.0.1:5004 check inter 2000 rise 3 fall 3 weight 10
    # inter 2000 健康检查时间间隔2秒
    # rise 3 检测多少次才认为是正常的
    # fall 3 失败多少次才认为是不可用的
    # weight  权重
```

**你可以通过 haproxy -c -f 检查语法**

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```



> **关于负载均衡算法**
>  　　**#source 　　 根据请求源IP**
>  　　**#static-rr 　　根据权重**
>  　　**#leastconn  最少连接者先处理**
>  　　**#uri 　　　　根据请求的uri**
>  　　**#url_param  根据请求的url参数**
>  　　**#rdp-cookie 据据cookie(name)来锁定并哈希每一次请求**
>  　　**#hdr(name) 根据HTTP请求头来锁定每一次HTTP请求**
>  　　**#roundrobin 轮询方式**

### 负载均衡配置示例

```bash
frontend http
bind 0.0.0.0:8189
default_backend backend_www_example_com

backend backend_www_example_com
    balance     roundrobin
    server  web-node1 10.50.1.101:80 check inter 2000 rise 3 fall 3 weight 20
    server  web-node2 10.50.1.103:80 check inter 2000 rise 3 fall 3 weight 10
```

### 管理界面配置

```bash
listen admin_stats
	stats   enable      
	bind    *:8080    //监听的ip端口       
	mode    http    //开关
	option  httplog
	log     global
	maxconn 10       
	stats   refresh 30s   //统计页面自动刷新时间       
	stats   uri /admin_status    //访问的uri   ip:8080/admin       
	stats   realm haproxy       
	stats   auth admin:admin  //认证用户名和密码
	stats   hide-version   //隐藏HAProxy的版本号
	stats   admin if TRUE   //管理界面，如果认证成功了，可通过webui管理节点
```

![image-20210831105913614](D:\ac\HAProxy反向代理配置\image-20210831105913614.png)

### 配置socket实现backend下线与上线

开启socket

```
stats socket /var/lib/haproxy/haproxy.sock1 mode 600 level admin 
```

测试

```
yum install socat
echo "disable server backend_www_example_com/web-node1" | socat stdio /var/lib/haproxy/haproxy.sock
```

![image-20210825082011949](D:\ac\Untitled\image-20210825082011949.png)

```
echo "enable server backend_www_example_com/web-node1" | socat stdio /var/lib/haproxy/haproxy.sock
```

![image-20210825082023106](D:\ac\Untitled\image-20210825082023106.png)



> https://blog.csdn.net/qq_19550657/article/details/105139854
>
> https://www.cnblogs.com/happy1983/p/9265358.html
>
> https://blog.csdn.net/weixin_34208283/article/details/92873671
>
> https://www.cnblogs.com/276815076/p/6992557.html
>
> https://blog.csdn.net/weixin_34007020/article/details/93011764
>
> https://blog.51cto.com/jiechao2012/1359511