---
title: ntpd ntpdate使用

categories:
  - Linux常用服务
series: 
  - Linux时间管理
lastmod: '2021-04-17'

featuredImage: 
authors: songjinfeng
draft: true
toc: true
---

为了避免主机时间因为长期运作下所导致的时间偏差，进行时间同步 (synchronize) 的工作是非常必要的。



https://www.cnblogs.com/liushui-sky/p/9203657.html

**ntpd、ntpdate 的区别**

下面是网上关于 ntpd 与 ntpdate 区别的相关资料。如下所示所示：

使用之前得弄清楚一个问题，ntpd 与 ntpdate 在更新时间时有什么区别。ntpd 不仅仅是时间同步服务器，它还可以做客户端与标准时间服务器进行同步时间，而且是平滑同步，并非 ntpdate 立即同步，在生产环境中慎用 ntpdate，也正如此两者不可同时运行。

时钟的跃变，对于某些程序会导致很严重的问题。许多应用程序依赖连续的时钟——毕竟，这是一项常见的假定，即，取得的时间是线性的，一些操作，例如数据库事务，通常会地依赖这样的事实：时间不会往回跳跃。不幸的是，ntpdate 调整时间的方式就是我们所说的”跃变 “：在获得一个时间之后，ntpdate 使用 settimeofday(2) 设置系统时间，这有几个非常明显的问题：

第一，这样做不安全。ntpdate 的设置依赖于 ntp 服务器的安全性，攻击者可以利用一些软件设计上的缺陷，拿下 ntp 服务器并令与其同步的服务器执行某些消耗性的任务。由于 ntpdate 采用的方式是跳变，跟随它的服务器无法知道是否发生了异常（时间不一样的时候，唯一的办法是以服务器为准）。

第二，这样做不精确。一旦 ntp 服务器宕机，跟随它的服务器也就会无法同步时间。与此不同，NTPD 在和时间服务器的同步过程中，会把 BIOS 计时器的振荡频率偏差——或者说 Local Clock 的自然漂移 (drift)——记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时。ntpd 不仅能够校准计算机的时间，而且能够校准计算机的时钟。

第三，这样做不够优雅。由于是跳变，而不是使时间变快或变慢，依赖时序的程序会出错（例如，如果 ntpdate 发现你的时间快了，则可能会经历两个相同的时刻，对某些应用而言，这是致命的）。因而，**唯一一个可以令时间发生跳变的点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用 ntpd 来校准时钟，而不是调整计算机时钟上的时间。**

## ntpadte命令

使用 ntpdate 比较简单。格式如下：
ntpdate [-nv] [NTP IP/hostname] 

但这样的同步，只是强制性的将系统时间设置为 ntp 服务器时间。如果 cpu tick 有问题，只是治标不治本。所以，一般配合 cron 命令，来进行定期同步设置。比如，在 crontab 中添加：

0 12 * * * * /usr/sbin/ntpdate 192.168.0.1

这样，会在每天的 12 点整，同步一次时间。ntp 服务器为 192.168.0.1。

使用 ntpd 服务，要好于 ntpdate 加 cron 的组合。因为，ntpdate 同步时间，会造成时间的跳跃，有可能出现相同的时间，对一些依赖时间的程序和服务会造成影响。比如 sleep，timer 等。而且，ntpd 服务可以在修正时间的同时，修正 cpu tick。理想的做法为，在开机的时候，使用 ntpdate 强制同步时间，在其他时候使用 ntpd 服务来同步时间。

要注意的是，ntpd 有一个自我保护设置: 如果本机与上源时间相差太大, ntpd 不运行. 所以新设置的时间服务器一定要先 ntpdate 从上源取得时间初值, 然后启动 ntpd 服务。ntpd 服务运行后, 先是每 64 秒与上源服务器同步一次, 根据每次同步时测得的误差值经复杂计算逐步调整自己的时间, 随着误差减小, 逐步增加同步的间隔. 每次跳动, 都会重复这个调整的过程.

## ntpd 服务的设置

实验

https://www.cnblogs.com/liushui-sky/p/9203657.html

1. 用hostA来作时间服务器，hostA用阿里云当时间源。
2. 用hostB去同步hostA

hostA：当时间服务器要修改`ntp.conf`ntp配置文件，把`restrict default nomodify notrap nopeer noquery`这行注释掉就可以了。如果不注释，就无法充当时**间服务器**了。

```
[root]$ yum -y install ntp
[root]$ systemctl start ntpd
[root]$ systemctl enable ntpd
[root]$ vim /etc/ntp.conf   
    #restrict default nomodify notrap nopeer noquery
    server ntp.aliyun.com iburst
[root]$ systemctl restart ntpd
[root]$ ntpq -p
```

HostB：

为了看出同步的效果，我们把时间手动改错

```bash
[root]$ date -s "2 day"
```

```
[root]$ yum -y install ntp
[root]$ systemctl start ntpd
[root]$ systemctl enable ntpd
[root]$ vim /etc/ntp.conf   删除默认server
    server HostA的IP iburst
[root]$ systemctl restart ntpd
[root]$ ntpq -p
```

ntpd 服务的相关设置文件如下：

1./etc/ntp.conf：这个是 NTP daemon 的主要设文件，也是 NTP 唯一的设定文件。

```
# 1. 关于权限设定部分
# 权限的设定主要以 restrict 这个参数来设定，主要的语法为：
# restrict IP mask netmask_IP parameter
# 其中 IP 可以是软件地址，也可以是 default ，default 就类似 0.0.0.0
# 至于 paramter 则有：
# ignore　：关闭所有的 NTP 联机服务
# nomodify：表示 Client 端不能更改 Server 端的时间参数，不过，
# Client 端仍然可以透过 Server 端来进行网络校时。
# notrust：该 Client 除非通过认证，否则该 Client 来源将被视为不信任网域
# noquery：不提供 Client 端的时间查询
# notrap：不提供 trap 这个远程事件登入
# 如果 paramter 完全没有设定，那就表示该 IP (或网域)“没有任何限制”
restrict default nomodifynotrapnoquery　# 关闭所有的 NTP 要求封包
restrict 127.0.0.1　　　 # 这是允许本级查询
restrict 192.168.0.1 mask 255.255.255.0 nomodify
#在 192.168.0.1/24 网段内的服务器就可以通过这台 NTP Server 进行时间同步了
# 2. 上层主机的设定
# 要设定上层主机主要以 server 这个参数来设定，语法为：
# server [IP|HOST Name] [prefer]
# Server 后面接的就是我们上层 Time Server 啰！而如果 Server 参数
# 后面加上 perfer 的话，那表示我们的 NTP 主机主要以该部主机来作为
# 时间校正的对应。另外，为了解决更新时间封包的传送延迟动作，
# 所以可以使用 driftfile 来规定我们的主机
# 在与 Time Server 沟通时所花费的时间，可以记录在 driftfile
# 后面接的文件内，例如下面的范例中，我们的 NTP server 与
# cn.pool.ntp.org 联机时所花费的时间会记录在 /etc/ntp/drift 文件内
server 0.pool.ntp.org
server 1.pool.ntp.org
server 2.pool.ntp.org
server cn.pool.ntp.org prefer
#其他设置值，以系统默认值即可
server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10
driftfile /var/lib/ntp/drift
broadcastdelay  0.008
keys /etc/ntp/keys
总结一下，restrict 用来设置访问权限，server 用来设置上层时间服务器，driftfile 用来设置保存漂移时间的文件。
```
## ntp 服务的启动与观察

在启动 NTP 服务前，先对提供服务的这台主机手动的校正一次时间咯。（因为启动服务器，端口会被服务端占用，就不能手动同步时间了）

查看端口：
netstat -ln|grep 123 

如何确认我们的 NTP 服务器已经更新了自己的时间呢？

```

[root[@linux ](/linux ) ~] # ntpstat 

synchronized to NTP server(127.127.1.0) at stratum 11

time correct to within 950ms

polling server every 64 s

#改指令可列出 NTP 服务器是否与上层联机。由上述输出结果可知，时间校正约

#为 950*10(-6) 秒。且每隔 64 秒会主动更新时间。

[root[@linux ](/linux ) ~] # ntptrace –n 127.0.0.1 

127.0.0.1:stratum 11, offset 0.000000，synch distance 0.950951

222.73.214.125：stratum 2，offset –0.000787，synch distance 0.108575

209.81.9.7:stratum 1，offset 0.000028，synch distance 0.00436，refid ‘GPS’
```

#这个指令可以列出目前 NTP 服务器（第一层）与上层 NTP 服务器（第二层）彼此之间的

**常见的错误：**

25 Apr 15:30:17 ntpdate[11520]: no server suitable for synchronization found

其实，这不是一个错误。而是由于每次重启 NTP 服务器之后大约要 3－5 分钟客户端才能与 server 建立正常的通讯连接。当此时用客户端连接服务端就会报这样的信息。一般等待几分钟就可以了。

#关系

[root[@linux ](/linux ) ~] # ntpq –p 

指令 “ntpq -p” 可以列出目前我们的 NTP 与相关的上层 NTP 的状态，以上的几个字段的意义如下：

> remote：即 NTP 主机的 IP 或主机名称。注意最左边的符号，如果由 “+” 则代表目前正在作用钟的上层 NTP，如果是 “*” 则表示也有连上线，不过是作为次要联机的 NTP 主机。
>
> refid：参考的上一层 NTP 主机的地址
>
> st：即 stratum 阶层
>
> when：几秒前曾做过时间同步更新的操作
>
> poll：下次更新在几秒之后
>
> reach：已经向上层 NTP 服务器要求更新的次数
>
> delay：网络传输过程钟延迟的时间
>
> offset：时间补偿的结果
>
> jitter：Linux 系统时间与 BIOS 硬件时间的差异时间

**最后提及一点，ntp 服务，默认只会同步系统时间。如果想要让 ntp 同时同步硬件时间，可以设置 / etc/sysconfig/ntpd 文件。**添加 SYNC_HWCLOCK=yes 这样，就可以让硬件时间与系统时间一起同步。

------------------------------------------

**各个选项信息：**

#系统时间与 BIOS 事件的偏差记录

driftfile /etc/ntp/drift

restrict 控制相关权限。

语法为： restrict IP 地址 mask 子网掩码 参数

其中 IP 地址也可以是 default ，default 就是指所有的 IP

参数有以下几个：

ignore  ：关闭所有的 NTP 联机服务

nomodify：客户端不能更改服务端的时间参数，但是客户端可以通过服务端进行网络校时。

notrust ：客户端除非通过认证，否则该客户端来源将被视为不信任子网

noquery ：不提供客户端的时间查询：用户端不能使用 ntpq，ntpc 等命令来查询 ntp 服务器

notrap ：不提供 trap 远端登陆：拒绝为匹配的主机提供模式 6 控制消息陷阱服务。陷阱服务是 ntpdq 控制消息协议的子系统，用于远程事件日志记录程序。

nopeer ：用于阻止主机尝试与服务器对等，并允许欺诈性服务器控制时钟

kod ： 访问违规时发送 KoD 包。

restrict -6 表示 IPV6 地址的权限设置。

**1：设定 NTP 主机来源（其中 prefer 表示优先主机），192.168.7.49 是本地的 NTP 服务器，所以优先指定从该主机同步时间。**

```
server 192.168.7.49 prefer
server 0.rhel.pool.ntp.org iburst
server 1.rhel.pool.ntp.org iburst
server 2.rhel.pool.ntp.org iburst
server 3.rhel.pool.ntp.org iburst
```

**2：限制你允许的这些服务器的访问类型, 在这个例子中的服务器是不容许修改运行时配置或查询您的 Linux NTP 服务器**

```
restrict 192.168.0.0 mask 255.255.255.0 notrust nomodify notrap
```

在上例中，掩码地址扩展为 255，因此从 192.168.0.1-192.168.0.254 的服务器都可以使用我们的 NTP 服务器来同步时间

#此时表示限制向从 192.168.0.1-192.168.0.254 这些 IP 段的服务器提供 NTP 服务。

```
restrict 192.168.0.0 mask 255.255.255.0 notrust nomodify notrap noquery
```

#设置默认策略为允许任何主机进行时间同步

restrict default ignore

**3：确保 localhost（这个常用的 IP 地址用来指 Linux 服务器本身）有足够权限. 使用没有任何限制关键词的语法：**

restrict 127.0.0.1

restrict -6 ::1

**B：配置 / etc/ntp/stpe-tickers 文件**

修改 / etc/ntp/stpe-tickers 文件，内容如下（当 ntpd 服务启动时，会自动与该文件中记录的上层 NTP 服务进行时间校对）

[root[@localhost ](/localhost ) ntp]# more /etc/ntp/step-tickers 



[![](https://cdn.nlark.com/yuque/0/2020/png/307910/1600416063296-9d6cc152-b40e-4aaf-b97c-921eb9416761.png#alt=)

](http://images0.cnblogs.com/blog/73542/201508/201228444419312.png)

remote   - 本机和上层 ntp 的 ip 或主机名，“+” 表示优先，“*” 表示次优先

refid    - 参考上一层 ntp 主机地址

st       - stratum 阶层

when     - 多少秒前曾经同步过时间

poll     - 下次更新在多少秒后

reach    - 已经向上层 ntp 服务器要求更新的次数

delay    - 网络延迟

offset   - 时间补偿

jitter   - 系统时间与 bios 时间差

要查看 ntpd 进程的状态，请运行以下命令，按 Ctrl+C 停止查看进程。

[![](https://cdn.nlark.com/yuque/0/2020/png/307910/1600416063491-9f058cc5-9368-4807-8e76-a550a6baac69.png#alt=)

](http://images0.cnblogs.com/blog/73542/201508/201228454723729.png)

第一列中的字符指示源的质量。星号 ( * ) 表示该源是当前引用。

remote 列出源的 IP 地址或主机名。

when   指出从轮询源开始已过去的时间（秒）。

poll   指出轮询间隔时间。该值会根据本地时钟的精度相应增加。

reach  是一个八进制数字，指出源的可存取性。值 377 表示源已应答了前八个连续轮询。

offset 是源时钟与本地时钟的时间差（毫秒）。



