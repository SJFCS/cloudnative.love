---
title: 新一代时间同步工具：Chrony

categories:
  - Linux常用服务
series: 
  - Linux时间管理
lastmod: '2021-05-27'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---
再见 NTP，是时候拥抱下一代时间同步服务 Chrony 了



## 简介

>chrony官网：https://chrony.tuxfamily.org
>
>chrony官方文档：https://chrony.tuxfamily.org/documentation.html


> 参考文档：
>
> [再见 NTP，是时候拥抱下一代时间同步服务 Chrony 了](https://cloud.tencent.com/developer/article/1546322)
>
> [[linux时间同步chrony介绍](https://www.cnblogs.com/pipci/p/12871993.html)
>
> [Chapter 18. Configuring NTP Using the chrony Suite:18.1.1. Differences Between ntpd and chronyd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite#18.1.1.%20Differences%20Between%20ntpd%20and%20chronyd)
>
> [CentOS / RHEL 7 : Chrony V/s NTP (Differences Between ntpd and chronyd)](https://www.thegeekdiary.com/centos-rhel-7-chrony-vs-ntp-differences-between-ntpd-and-chronyd/)


> 推荐阅读：
>
> [chrony输出字段含义](https://www.pianshen.com/article/93751806854/)

**什么是Chrony**

`Chrony` 是一个多功能的 `NTP (Network Time Protocol)` 实现，类 `Unix` 系统上 `NTP` 客户端和服务器的替代品。它可以通过 `NTP` 服务或者类似 `GPS` 时钟接收器的硬件级参考时钟来同步系统时钟，具有更好的时钟准确度，并且对于那些间歇性互联网连接的系统很有帮助。`Chrony` 是免费开源的，并且支持 `GNU/Linux` 和 `BSD` 衍生版（比如：`FreeBSD`、`NetBSD`）、`macOS` 和 `Solaris` 等。

`Chrony` 有两个核心组件：一个是 `chronyd` 守护进程，主要用于调整内核中运行的系统时间和时间服务器同步。它确定计算机增减时间的比率，并对此进行调整补偿。另一个是 `chronyc`，它提供一个用户界面，用于监控性能并进行多样化的配置。`chronyc` 可以在 `chronyd` 实例控制的计算机上工作，也可以在一台不同的远程计算机上工作。

**Chrony对比NTP优势**

1. Chrony实现NTP协议的的自由软件。可使系统时钟与NTP服务器，参考时钟（例如GPS接收器）以及使用手表和键盘的手动输入进行同步。还可以作为NTPv4（RFC 5905）服务器和对等体运行，为网络中的计算机提供时间服务。设计用于在各种条件下良好运行，包括间歇性和高度拥挤的网络连接，温度变化（计算机时钟对温度敏感），以及不能连续运行或在虚拟机上运行的系统。
   Chrony通过Internet同步的两台机器之间的典型精度在几毫秒之内，在LAN上，精度通常为几十微秒。利用硬件时间戳或硬件参考时钟，可实现亚微秒的精度。
   NTP精度在局域网内可达0.1ms，在互联网上绝大多数的地方精度可以达到1-50ms。
2. **ntpdate**强制同步。如果cpu tick有问题，只是治标不治本，一般配合crontab做定时任务。
   使用chronyd、ntpd服务，要好于ntpdate加cron的组合。因为，ntpdate同步时间，会造成时间的跳跃，对一些依赖时间的程序和服务会造成影响。比如sleep，timer等。而且，chronyd、ntpd服务可以在修正时间的同时，修正cpu tick。
3.  `ntpd` 和`Chrony` 的修正是连续的，通过减慢时钟或者加快时钟的方式连续的修正。而 `ntpdate` 搭配 `Crontab` 的校时工具是直接调整时间，会出现间断，并且相同时间可能会出现两次。因此，请放弃使用 `ntpdate` 来校时。
4. 更快的同步，从而最大程度减少了时间和频率误差，对于并非全天 24 小时运行的虚拟计算机而言非常有用，能够更好地响应时钟频率的快速变化，对于具备不稳定时钟的虚拟机或导致时钟频率发生变化的节能技术而言非常有用
5. 在初始同步后，它不会停止时钟，以防对需要系统时间保持单调的应用程序造成影响
6. 在应对临时非对称延迟时（例如，在大规模下载造成链接饱和时）提供了更好的稳定性
7. 无需对服务器进行定期轮询，因此具备间歇性网络连接的系统仍然可以快速同步时

**安装部署**

从 `Centos 7.x` 开始的最小发行版中都已经预装并开启了 `Chrony`。如果你的系统上没有安装 `Chrony`，你也可以使用`$ yum -y install chrony `命令轻松安装它。

> 服务unit文件： /usr/lib/systemd/system/chronyd.service
>
> 配置文件： /etc/chrony.conf
>
> 监听端口： 323/udp，123/udp
> （chrony并且兼容ntpd监听在udp123端口上，自己则监听在udp的323端口上。）

## 基本命令

如果在chrony配置文件中指定了ntp服务器的地址，那么chrony就是一台客户端，会去同步ntp服务器的时间，如果在chrony配置了允许某些客户端来向自己同步时间，则chrony也充当了一台服务器，chrony即可同时充当客户端和服务端。

**chronyc命令有两种模式**

一种是交互式模式，一种是命令行模式。输入chronyc回车就进入交互式模式，进入交互式模式可以使用help命令查看帮助列表

**交互式模式**

```bash
sources [-v]		显示当前时间源的同步信息
sourcestats [-v]	显示当前时间源的同步统计信息
activity			显示有多少 NTP 源在线/离线
clients				报告已访问本服务器的客户端列表
accheck [IP]		检查是否允许对特定主机访问本机NTP服务
add server			手动添加一台新的 NTP 服务器。
delete				手动移除 NTP 服务器或对等服务器
settime				手动设置守护进程时间
tracking			显示系统时间信息
```

**命令行模式**

查看时间同步源服务器的信息

>这里需要注意的是第二个参数，`*` 代表当前同步的源，`-` 代表通过组合算法计算后排除的源。
>

```bash
$ chronyc sources -v
```

查看时间同步源状态

```bash
$ chronyc sourcestats -v
```

查看时间同步源在线/离线

```bash
$ chronyc activity
```

 在客户端报告已访问到服务器

```bash
$ chronyc clients 
```

检查 NTP 访问是否对特定主机可用

```bash
$ chronyc accheck
```

手动添加一台新的 NTP 服务器

```bash
$ chronyc add server
```

手动移除 NTP 服务器或对等服务器

```bash
$ chronyc delete
```

在客户端报告已访问到服务器

```bash
$ chronyc clients
```

手动设置守护进程时间

```bash
$ chronyc settime
```

校准时间服务器，显示系统时间信息

```bash
$ chronyc tracking
```

> `Chrony` 客户端程序的功能非常强大，远不止上面介绍这些。
>
> 如果你想了解更多的使用方法，可以使用
>
>  `man chronyc` 命令获取 `Chrony` 的详细使用方法。
>
> `man chronyd`命令获取 `chronyd` 的详细使用方法。
>
> `man chronyc`命令获取 `chronyc` 的详细使用方法。
>
> `man chrony.conf`命令获取 配置文件详细文档

## 服务端配置举例
1、安装chrony
2、设置chrony服务开机启动
3、防火墙开放UDP端口号123和323
5、配置chrony主配置文件chrony.conf

- 端口 `123/udp` 为标准的 `NTP` 监听端口，如果要对外提供 `NTP Server` 功能，必须开启防火墙和监听地址为外部可访问地址。如需修改，你可以通过配置 `port` 参数来修改。
- 端口 `323/udp` 为默认的管理端口。如需修改，你可以通过配置 `cmdport` 参数来修改。

修改防火墙设置，以放行对 `123/udp` 的请求，这里以 `CentOS 7` 的 `Firewalld` 为例。

```javascript
$ firewall-cmd --zone=public --add-port=123/udp --permanent$ firewall-cmd --reload
```

**/etc/chrony.conf 增加如下内容，其它保持默认即可**

备注：详细指令参数可以使用命令`man chrony.conf`查看

快速配置脚本

```
sed -i -e '/^server/s/^/#/'  -e '1a server ntp.aliyun.com iburst' /etc/chrony.conf
```

```bash
# 配置外部时间服务器，将配置文件中默认的全部注释掉
# 配置外部时间服务器，将配置文件中默认的全部注释掉
# server - 可用于时钟服务器，prefer 表示优先主机、iburst 选项当服务器可达时，头四次 NTP 请求，发送一个八个数据包而不是通常的一个数据包， 包间隔通常为2秒,而不是以 minpoll x 指定的最小间隔，可加快初始同步速度。
# 其他的参数有 minpoll x 默认值是 6，代表 64s。maxpoll x 默认值是 9，代表 512s。
server ntp.ntsc.ac.cn prefer 　　　　 ##中国国家授时中心
server ntp1.aliyun.com 　　　　　　 ##中国授时

#只允许192.168.0网段的客户端进行时间同步,(allow 0.0.0.0/0代表允许所以任意设备)
# allow/deny - 指定一台主机、子网，或者网络以允许或拒绝访问本服务器
allow 192.168.0.0/24

#启用内核时间与 RTC 时间同步 (自动写回硬件)，系统时间每11分钟会拷贝到实时时钟（RTC）
rtcsync

#server不可用时，允许将本地时间作为标准时间授时给其它客户端，如果服务器本身也不能同步时间，那么就用本地时间替代，层级为 10
local stratum 10
====================可选===================================
# 记录系统时钟获得/丢失时间的速率，根据实际时间计算出计算机增减时间的比率，将它记录到至drift文件中，会在重启后为系统时钟作出补偿
driftfile /var/lib/chrony/drift
# makestep根据需要通过加速或减慢时钟来逐渐校正任何时间偏移。
# 如果系统时钟的偏移量大于10秒，则允许在前三次更新中步进调整系统时钟
makestep 10 3
# 指定包含NTP验证密钥的文件
keyfile /etc/chrony.keys
# 指定存放日志文件的目录
logdir /var/log/chrony
# stratumweight 该参数用于设置当 chronyd 从可用源中选择同步源时，每个层应该添加多少距离到同步距离。默认情况下设置为 0，让 chronyd 在选择源时忽略源的层级。
stratumweight 0.05
# 禁用客户端访问的日志记录
noclientlog
# 如果时钟调整大于0.5秒，则向系统日志发送消息
logchange 0.5


cmdallow / cmddeny - 可以指定哪台主机可以通过chronyd使用控制命令
bindcmdaddress - 允许chronyd监听哪个接口来接收由chronyc执行的命令
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
makestep - 通常chronyd将根据需求通过减慢或加速时钟，使得系统逐步纠正所有时间偏差。在某些特定情况下，系统时钟可能会漂移过快，导致该调整过程消耗很长的时间来纠正系统时钟。该指令强制chronyd在调整期大于某个域值时调整系统时钟
##
server： 指明时间服务器地址；
allow NETADD/NETMASK 允许那些客户端来同步
allow all： ；允许所有客户端主机
deny NETADDR/NETMASK
deny all： 拒绝所有客户端；
bindcmdaddress： 命令管理接口监听的地址；
local stratum 10： 即使自己未能通过网络时间服务器同步到时间，也允许将本地时间作为标准时间授时给其它客户端。
```

## 实验：

**集群采用Chrony对接外部NTP Server配置**

集群环境对接NTP Server配置时，建议主节点对接NTP Server，从节点对接主节点。

1. 每个节点检查是否安装Chrony服务
```bash
ansible all -m shell -a 'rpm -q chrony'
```
2. 停止所有节点的NTPD服务
```bash
ansible all -m shell -a 'systemctl stop ntpd'

ansible all -m shell -a 'systemctl disable ntpd'
```
3. 手动同步主节点时间与NTP Server时间基本一致
```bash
ntpdate –s x.x.x.x 其中x.x.x.x为NTP Server的IP地址
```
4. 修改主节点的/etc/chrony.conf文件：

> 修改内容：
>
> A、 注释掉配置文件中的所有server；
>
> B、 新增NTP Serve的配置
>
> C、 新增本地时间同步配置
>
> D、 配置允许连接的集群和本地地址
>
> E、 取消注释，允许同步本地时间

主节点的/etc/chrony.conf 修改内容如下文标 #部分所示：

```bash
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.centos.pool.ntp.org iburst      #注释原有所有server
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
server x.x.x.x iburst minpoll 4 maxpoll 4  #有外部server时添加，x.x.x.x为外部NTP Server的地址。
server 127.127.1.0   #本地server 同步本地时间，必选。
# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3
# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *
# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2
# Allow NTP client access from local network.
#allow 192.168.0.0/16 
allow 127.0.0.1/8   #新增允许本地客户端访问
allow x.x.0.0/16    #新增允许集群网网段访问，这里按照要求替换为集群的管理网段。
# Serve time even if not synchronized to a time source.
local stratum 10  #取消注释，允许同步本地时间
# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys
# Specify directory for log files.
logdir /var/log/chrony
# Select which information is logged.
#log measurements statistics tracking

```

5. 手动同步从节点时间与主节点时间基本一致
```bash
ntpdate -s x.x.x.x 其中x.x.x.x为CloudOS的主节点IP地址
```
6.  从节点修改Chrony.conf配置文件

> 修改内容：
>
> A、 注释掉配置文件中的所有server；
>
> B、 新增NTP Serve的配置

从节点/etc/chrony.conf  修改内容如下文的标 #部分所示：

```bash
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.centos.pool.ntp.org iburst         #注释原有所有server
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
server x.x.x.x iburst minpoll 4 maxpoll 4       #新增同步主节点，x.x.x.x为主节点IP地址
# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3
# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *
# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2
# Allow NTP client access from local network.
#allow 192.168.0.0/16
# Serve time even if not synchronized to a time source.
#local stratum 10
# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys
# Specify directory for log files.
logdir /var/log/chrony
# Select which information is logged.
#log measurements statistics tracking

```

所有节点启动chrony
```bash
ansible all -m shell -a 'systemctl start chronyd'

ansible all -m shell -a 'systemctl enable chronyd'
```
所有节点检查时间状态
```bash
ansible all -m shell -a 'chronyc sources -v'

ansible all -m shell -a 'timedatectl'
```