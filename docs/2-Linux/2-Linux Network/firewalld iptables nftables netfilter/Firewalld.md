---
title: Firewalld基本使用
---


## 简介

在RHEL7里有几种防火墙共存：firewalld、iptables、ebtables，默认是使用firewalld，他们的作用都是用于维护规则，而真正使用规则干活的是内核的netfilter

**firewalld与iptables对比：**

1. firewalld可以动态修改单条规则，而不需要像iptables那样，在修改了规则后必须得全部刷新才可以生效；
2. firewalld在使用上要比iptables人性化很多，即使不明白“五张表五条链”而且对TCP/IP协议也不理解也可以实现大部分功能。
3. firewalld默认是拒绝，每个服务都需要去设置才能放行。而iptables里默认是每个服务是允许，需要拒绝的才去限制。

## 区域管理

通过将网络划分成不同的区域，制定出不同区域之间的访问控制策略来控制不同程序区域间传送的数据流。例如，互联网是不可信任的区域，而内部网络是高度信任的区域。网络安全模型可以在安装，初次启动和首次建立网络连接时选择初始化。该模型描述了主机所连接的整个网络环境的可信级别，并定义了新连接的处理方式。有如下几种不同的初始化区域：

| 区域                                 | 描述                                                      |
| ------------------------------------ | --------------------------------------------------------- |
| 信任区域（trusted）                  | 所有的网络连接都可以接受。                                |
| 家庭区域（home）：                   | 仅接受ssh、mdns、ipp-client、samba-client、dhcpv6服务链接 |
| 内部区域（internal）                 | 仅接受ssh、mdns、ipp-client、samba-client、dhcpv6服务链接 |
| 工作区（work）                       | 仅接受ssh、ipp-client或dhcpv6-client服务链接              |
| 公共区域（public）**默认区域** | 仅接受ssh、dhcpv6-client服务链接                          |
| 外部区域（external）                 | 出去的ipv4网络连接通过此区域伪装和转发，仅接受ssh服务链接 |
| 非军事区(dmz)                        | 仅接受ssh服务链接                                         |
| 阻塞区域（block）                    | 拒绝所有网络连接                                          |
| 丢弃区域（drop）                     | 丢弃所有网络连接，没有任何回复                            |

## 安装部署

### 安装firewalld

```
yum install firewalld firewall-config
systemctl start firewalld
systemctl enable firewalld
```

### 禁用iptables

```
systemctl  mask  iptables
 Created symlink from /etc/systemd/system/iptables.service to /dev/null.
systemctl  mask  ip6tables
 Created symlink from /etc/systemd/system/ip6tables.service to /dev/null.
```

### 配置文件

firewalld默认提供了九个zone配置文件：`block.xml、dmz.xml、drop.xml、external.xml、  home.xml、internal.xml、public.xml、trusted.xml、work.xml`，他们都保存在 `/usr/lib/firewalld/zones/`目录下。

```
root@node3[11:35:22]:~$ ll /usr/lib/firewalld/zones/
total 36
-rw-r--r--. 1 root root 299 Apr 28 21:31 block.xml
-rw-r--r--. 1 root root 293 Apr 28 21:31 dmz.xml
-rw-r--r--. 1 root root 291 Apr 28 21:31 drop.xml
-rw-r--r--. 1 root root 304 Apr 28 21:31 external.xml
-rw-r--r--. 1 root root 369 Apr 28 21:31 home.xml
-rw-r--r--. 1 root root 384 Apr 28 21:31 internal.xml
-rw-r--r--. 1 root root 315 Apr 28 21:31 public.xml
-rw-r--r--. 1 root root 162 Apr 28 21:31 trusted.xml
-rw-r--r--. 1 root root 311 Apr 28 21:31 work.xml
```

## 使用配置

### 基础指令

版本状态帮助

```
查看状态:
firewall-cmd --state
查看版本：
firewall-cmd --version
查看帮助：
firewall-cmd --help 
```

查看当前活动区域信息:

```
firewall-cmd --get-active-zones   
```

更新防火墙规则：

```
firewall-cmd --reload
firewall-cmd --complete-reload
```

> **`--reload`和 `--complete-reload`的区别就是：**
>
> 1. `--reload`无需断开连接，就是firewalld特性之一动态添加规则，
> 2. `--complete-reload`需要断开连接，类似重启服务

### **查询与设置规则注意事项：**

1. 可指定 --zone= 来对特定Zone进行操作，不设置操作默认Zone

   ```
   firewall-cmd --zone=Zone_name --command
   ```
2. `Zone_name`可为 `(block dmz drop external home internal public trusted work)`

   可通过 `firewall-cmd --get-zones` 查询所有zone
3. 设置规则时加上 `--permanent` 可用永久生效，没有此参数reload重启后失效

### 查看Zone规则

1. 显示当前默认的zone

   ```
   firewall-cmd --get-default-zone
   ```
2. 显示默认区域的规则

   ```bash
   firewall-cmd --list-all
   ```
3. 显示所有的zone

   ```
   firewall-cmd --get-zones
   ```
4. 显示所有zone的规则

   ```
   firewall-cmd --list-all-zones
   ```

**规则关键字**

| 关键字               | 含义                                                                                                                         |
| :------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| ZONES                | ZONES名称：drop、block、public、external、dmz、work、home、internal、 trusted。                                              |
| target               | 行为：有default(默认)、accept(允许)、%%reject%%(拒绝)、drop(丢弃)四个值可选（具体作用未查到）                                |
| icmp-block-inversion | icmp报文阻塞：可以选择Internet控制报文协议的报文。这些报文可以是信息请求亦可以是对信息请求或错误条件创建的响应。             |
| interfaces           | 接口：可以理解为网卡，接收请求的网卡。                                                                                       |
| sources              | 源地址：可以是ip地址也可以是ip地址段，支持的ip。                                                                             |
| services             | 服务：支持的服务。                                                                                                           |
| ports                | 端口：开放的端口。                                                                                                           |
| protocols            | 协议                                                                                                                         |
| masquerade           | 地址伪装：snat的一种特例，可以实现自动化snat。将一个网段的数据包Snat成一个地址或多的地址，然后发出去，这个不需要指定目标IP。 |
| forward-ports        | 端口转发或映射。                                                                                                             |
| source-ports：       | 源端口                                                                                                                       |
| icmp-blocks          | 据查询是用于防止ICMP攻击的。                                                                                                 |
| rich rules           | 自定义规则                                                                                                                   |

### Zone 区域管理

```bash
# 设置默认的区域
firewall-cmd --set-default-zone=trusted 
# (block dmz drop external home internal public trusted work)

# 添加一个新的zone
firewall-cmd --new-zone=test --permanent
# 删除zone
firewall-cmd --delete-zone=test --permanent
```

> 需要重新加载配置文件生效
>
> ```
> firewall-cmd --reload
> ```

### Service 服务管理

```bash
# 显示所有预定义的服务种类
firewall-cmd --get-services
# 查询当前允许的通过的服务：
firewall-cmd --list-services
```

```bash
# 添加服务
firewall-cmd --add-service=http
# 移除服务
firewall-cmd --remove-service=http
# 多个服务
firewall-cmd --add/remove-service={https,mysql,redis}
```

### Port 端口管理

```bash
# 显示所有允许的端口及协议
firewall-cmd --list-ports
```

```bash
# 添加一个端口
firewall-cmd  --add-port=80/tcp
# 删除一个端口
firewall-cmd --remove-port=6379/tcp

# 添加/删除多个端口
firewall-cmd  --add/remove-port={443/tcp,6379/tcp}
```

### Interface 接口管理

```bash
# 查看指定接口所属Zone：
firewall-cmd --get-zone-of-interface=eth0
```

```bash
# 添加接口
 firewall-cmd --add-interface=eth0
# 移除接口
firewall-cmd --remove-interface=eth1
# 将接口跟zone进行相关联
firewall-cmd --change-interface=eth0 --zone=public
```

### 源地址管理

```bash
# 设置来源ip属于10.0.0.0/24网段的ip允许所有
firewall-cmd --add-source=10.0.0.0/24 --zone=trusted

# 拒绝10.0.0.0/24网段的所有服务
firewall-cmd --add-source=10.0.0.0/24 --zone=drop

# 移除ip地址
firewall-cmd --remove-source=10.0.0.8/32 --zone=trusted
```

### 地址转发

```bash
firewall-cmd --permanent --zone=<区域>  --add-forward-port=port=<源端口号>:proto=<协议>:toport=<目标端口号>:toaddr=<目标IP地址>
 
# 开启地址映射
firewall-cmd --add-masquerade
# 将本地的6666端口映射到后端的172.16.1.8的22端口
firewall-cmd --zone=public --add-forward-port=port=6666:proto=tcp:toport=22:toaddr=172.16.1.8
firewall-cmd --zone=public --add-forward-port port=6666 protocol=tcp to-port=22 to-addr=10.50.1.101

# 移除端口映射
firewall-cmd --zone=public --remove-forward-port=port=6666:proto=tcp:toport=22:toaddr=172.16.1.8
```

```bash
# 将80端口的流量转发至8080
firewall-cmd --add-forward-port=port=80:proto=tcp:toport=8080
# 将80端口的流量转发至192.168.0.1
firewall-cmd --add-forward-port=proto=80:proto=tcp:toaddr=192.168.1.0.1
#将80端口的流量转发至192.168.0.1的8080端口
firewall-cmd --add-forward-port=proto=80:proto=tcp:toaddr=192.168.0.1:toport=8080
```

> [--permanent] [--zone=zone] --add-forward-port=port=portid[-portid]:proto=protocol[:toport=portid[-portid]][:toaddr=address[/mask]]
> [--timeout=timeval]
> Add the IPv4 forward port for zone. If zone is omitted, default zone will be used. This option can be specified multiple times. If a timeout is
> supplied, the rule will be active for the specified amount of time and will be removed automatically afterwards.  timeval is either a number
> (of seconds) or number followed by one of characters s (seconds), m (minutes), h (hours), for example 20m or 1h.
>
> ```
>    The port can either be a single port number portid or a port range portid-portid. The protocol can either be tcp, udp, sctp or dccp. The
>    destination address is a simple IP address.
>
>    The --timeout option is not combinable with the --permanent option.
>
>    For IPv6 forward ports, please use the rich language.
>
>    Note: IP forwarding will be implicitly enabled if toaddr is specified.
> ```

### 端口映射

10.50.1.0/24访问本机54321端口，就转发到10.50.1.101的22端口上

```bash
echo "1" > / /proc/sys/net/ipv4/ip_forward

firewall-cmd --add-masquerade --permanent

firewall-cmd --add-rich-rule 'rule family="ipv4" source address="10.50.1.0/24" forward-port port="54321" protocol="tcp" to-port="22" to-addr="10.50.1.101"'

[root@node3 GNU-Linux-x86]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens33
  sources:
  services: dhcpv6-client ssh
  ports:
  protocols:
  masquerade: yes
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="10.50.1.0/24" forward-port port="54321" protocol="tcp" to-port="22" to-addr="10.50.1.101"

```

### 网闸

```
拒绝所有包：# firewall-cmd --panic-on
取消拒绝状态：# firewall-cmd --panic-off
查看是否拒绝：# firewall-cmd --query-panic
```

### 自定义服务名称

```
 编写配置文件
根据 /usr/lib/firewalld/services/下的服务编写配置文件
/usr/lib/firewalld/services/my_service.xml

<?xml version="1.0" encoding="utf-8"?>
<service>
<short>Secure WWW (my_service)</short>
<description>my_service</description>
<port protocol="tcp" port="443"/>
</service>

添加这个服务
firewall-cmd   --add-service=my_service 
firewall-cmd   --list-all 
public (active)  
target: default  
icmp-block-inversion: no  
interfaces: eth0  
sources:   
services: ssh dhcpv6-client my_service
ports:  
protocols:   
masquerade: no  
forward-ports:   
source-ports:   
icmp-blocks:   
rich rules: 
```

## 指令总结

```
参数 zone区域相关指令 作用
--get-default-zone 查询默认的区域名称
--set-default-zone=<区域名称> 设置默认的区域，使其永久生效
--get-active-zones 显示当前正在使用的区域与网卡名称
--get-zones 显示总共可用的区域
--new-zone= 新增区域
--delete-zone= 删除区域
--get-services 显示预先定义的服务
--add-service=<服务名> 设置默认区域允许该服务的流量
--remove-service=<服务名> 设置默认区域不再允许该服务的流量
--list-services 显示默认区域允许的服务
Port端口相关指令
--add-port=<端口号/协议> 设置默认区域允许该端口的流量
--remove-port=<端口号/协议> 设置默认区域不再允许该端口的流量
--list-port 显示默认区域允许的端口
Interface网卡相关指令
--get-zone-of-interface=<网卡名称> 查看接口在哪个区域
--add-interface=<网卡名称> 将源自该网卡的所有流量都导向某个指定区域
--remove-interface=<网卡名称> 删除接口
地址源相关命令
--add-source= 添加来源地址
--remove-source= 移除来源地址
其他相关指令
--list-all 显示当前区域的网卡配置参数、资源、端口以及服务等信息
--reload 让"永久生效"的配置规则立即生效，并覆盖当前的配置规则
--panic-on 阻断一切网络连接
--panic-off 恢复网络连接
```

> https://www.cnblogs.com/223zhp/p/12061362.html
>
> https://www.cnblogs.com/vicowong/p/11210144.html
>
> https://blog.51cto.com/andyxu/2137046
