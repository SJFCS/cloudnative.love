---
title: 03.Iptables处理动作
---

参考链接：http://www.faqs.org/docs/iptables/targets.html


![image-20210423100939737](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(4)%E5%8A%A8%E4%BD%9C/2021.04.23-11:26:05-D-assets-Iptables%E8%AF%A6%E8%A7%A3-4-%E5%8A%A8%E4%BD%9C-image-20210423100939737.png)

**常用的处理动作： (****-j 指定对满足条件包的处理，常用动作有ACCEPT接受报、DROP丢弃报、REJECT丢弃报并通知对方、REDIRECT重定向包等****)**

-j  参数用来指定要进行的处理动作，常用的处理动作包括：ACCEPT、REJECT、DROP、REDIRECT、MASQUERADE、LOG、DNAT、SNAT、MIRROR、QUEUE、RETURN、MARK，分别说明如下：

ACCEPT     将封包放行，进行完此处理动作后，将不再比对其它规则，直接跳往下一个规则链（natostrouting）。

REJECT     拦阻该封包，并传送封包通知对方，可以传送的封包有几个选择：ICMP port-unreachable、ICMP echo-reply 或是 tcp-reset（这个封包会要求对方关闭联机），进行完此处理动作后，将不再比对其它规则，直接中断过滤程序。 

例如：iptables -A FORWARD -p TCP --dport 22 -j REJECT --reject-with tcp-reset

DROP      丢弃封包不予处理，进行完此处理动作后，将不再比对其它规则，直接中断过滤程序。

REDIRECT    将封包重新导向到另一个端口（PNAT），进行完此处理动作后，将会继续比对其它规则。 

            这个功能可以用来实作通透式porxy 或用来保护 web 服务器。

        例如：iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080

MASQUERADE       改写封包来源 IP 为防火墙 NIC IP，可以指定 port 对应的范围，进行完此处理动作后，直接跳往下一个规则（mangleostrouting）。这个功能与 SNAT 略有不同，当进行 IP 伪装时，不需指定要伪装成哪个 IP，IP 会从网卡直接读，当使用拨接连线时，IP 通常是由 ISP 公司的 DHCP 服务器指派的，这个时候 MASQUERADE 特别有用。

        例如：iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE --to-ports 1024-31000

LOG      使用LOG动作，可以将符合条件的报文的相关信息记录到日志中，但当前报文具体是被”接受”，还是被”拒绝”，都由后面的规则控制，换句话说，LOG动作只负责记录匹配到的报文的相关信息，不负责对报文的其他处理，如果想要对报文进行进一步的处理，可以在之后设置具体规则，进行进一步的处理。

默认记录到日志/var/log/messages记录在指定的文件中，以防止iptables的相关信息与其他日志信息相混淆，修改/etc/rsyslog.conf文件（或者/etc/syslog.conf），在rsyslog配置文件中添加如下配置即可。
vim /etc/rsyslog.conf
kern.warning /var/log/iptables.log
加入上述配置后，报文的相关信息将会被记录到/var/log/iptables.log文件中。
完成上述配置后，重启rsyslog服务（或者syslogd）
service rsyslog restart
服务重启后，配置即可生效，匹配到的报文的相关信息将被记录到指定的文件中。

LOG动作也有自己的选项，常用选项如下（先列出概念，后面有示例）

–log-level选项可以指定记录日志的日志级别，可用级别有emerg，alert，crit，error，warning，notice，info，debug。

–log-prefix选项可以给记录到的相关信息添加”标签”之类的信息，以便区分各种记录到的报文信息，方便在分析时进行过滤。

注：–log-prefix对应的值不能超过29个字符。

        例如：iptables -A INPUT -p tcp -j LOG --log-prefix "INPUT packets"



如果想要NAT功能能够正常使用，需要开启Linux主机的核心转发功能。

```
echo 1 > /proc/sys/net/ipv4/ip_forward
```

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_1.png)

外部主机将响应报文发送给路由器，路由器根据刚才NAT表中的映射记录，将响应报文中的目标IP与目标端口再改为内部主机的IP与端口号，然后再将响应报文发送给内部网络中的主机。整个过程中，外部主机都不知道内部主机的IP地址，内部主机还能与外部主机通讯，于是起到了隐藏网络内主机IP的作用。

NAPT是NAT的一种，全称为Network Address Port Translation，说白了就是映射报文IP地址的同时还会映射其端口号

内部网络的报文发送出去时，报文的源IP会被修改，也就是源地址转换：Source Network Address Translation，缩写为SNAT。 网络内部的主机可以借助SNAT隐藏自己的IP地址，同时还能够共享合法的公网IP，让局域网内的多台主机共享公网IP访问互联网。

SNET：

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C1036128-20161102184753033-243372896.png)

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C1036128-20161102184826486-418364414.png)

![N](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5Cimage-20210425092955885.png)

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_11.png)

外部网络的报文响应时，响应报文的目标IP会再次被修改，也就是目标地址转换：Destinationnetwork address translation，缩写为DNAT。

```
“-t nat”表示操作nat表，我们之前一直在灌输一个概念，就是不同的表有不同的功能，filter表的功能是过滤，nat表的功能就是地址转换，所以我们需要在nat表中定义nat规则。

“-A POSTROUTING”表示将SNAT规则添加到POSTROUTING链的末尾，在centos7中，SNAT规则只能存在于POSTROUTING链与INPUT链中，在centos6中，SNAT规则只能存在于POSTROUTING链中。

你可能会问，为什么SNAT规则必须定义在POSTROUTING链中，我们可以这样认为，POSTROUTING链是iptables中报文发出的最后一个”关卡”，我们应该在报文马上发出之前，修改报文的源地址，否则就再也没有机会修改报文的源地址了，在centos7中，SNAT规则也可以定义在INPUT链中，我们可以这样理解，发往本机的报文经过INPUT链以后报文就到达了本机，如果再不修改报文的源地址，就没有机会修改了。

“-s 10.1.0.0/16″表示报文来自于10.1.0.0/16网段，前文中一直在使用这个匹配条件，我想此处应该不用赘述了。

“-j SNAT”表示使用SNAT动作，对匹配到的报文进行处理，对匹配到的报文进行源地址转换。

“–to-source 192.168.1.146″表示将匹配到的报文的源IP修改为192.168.1.146，前文中，我们已经总结过，某些动作会有自己的选项，”–to-source”就是SNAT动作的常用选项，用于指定SNAT需要将报文的源IP修改为哪个IP地址。
```

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_13.png)

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_14.png)

----------------

DNET:

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C1036128-20161102200509033-575942301.png)

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_19.png)

如上图所示，我们先将nat表中的规则清空了，从头来过，清空nat表规则后，定义了一条DNAT规则。

“-t nat -I PREROUTING”表示在nat表中的PREROUTING链中配置DNAT规则，DNAT规则只配置在PREROUTING链与OUTPUT链中。

“-d 192.168.1.146 -p tcp –dport 3389″表示报文的目标地址为公司的公网IP地址，目标端口为tcp的3389号端口，而我们知道，windows远程桌面使用的默认端口号就是3389，当外部主机访问公司公网IP的3389号端口时，报文则符合匹配条件。

“-j DNAT –to-destination 10.1.0.6:3389″表示将符合条件的报文进行DNAT，也就是目标地址转换，将符合条件的报文的目标地址与目标端口修改为10.1.0.6:3389，”–to-destination”就是动作DNAT的常用选项。

那么综上所述，上图中定义的规则的含义为，当外网主机访问公司公网IP的3389时，其报文的目标地址与端口将会被映射到10.1.0.6:3389上。

 

好了，DNAT规则定义完了，现在能够直接使用外网主机访问私网中的服务了吗？

理论上只要完成上述DNAT配置规则即可，但是在测试时，只配置DNAT规则后，并不能正常DNAT，经过测试发现，将相应的SNAT规则同时配置后，即可正常DNAT，于是我们又配置了SNAT

示例如下。

![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_20.png)

注：理论上只配置DNAT规则即可，但是如果在测试时无法正常DNAT，可以尝试配置对应的SNAT，此处按照配置SNAT的流程进行。

没错，与刚才定义SNAT时使用的规则完全一样。

MASQUERADE：

当我们拨号网上时，每次分配的IP地址往往不同，不会长期分给我们一个固定的IP地址，如果这时，我们想要让内网主机共享公网IP上网，就会很麻烦，因为每次IP地址发生变化以后，我们都要重新配置SNAT规则，这样显示不是很人性化，我们通过MASQUERADE即可解决这个问题，MASQUERADE会动态的将源地址转换为可用的IP地址，其实与SNAT实现的功能完全一致，都是修改源地址，只不过SNAT需要指明将报文的源地址改为哪个IP，而MASQUERADE则不用指定明确的IP，会动态的将报文的源地址修改为指定网卡上可用的IP地址，示例如下：![img](D:%5Cassets%5CIptables%E8%AF%A6%E8%A7%A3(4)%E5%A4%84%E7%90%86%E5%8A%A8%E4%BD%9C%5C051517_1411_26.png)

如上图所示，我们指定，通过外网网卡出去的报文在经过POSTROUTING链时，会自动将报文的源地址修改为外网网卡上可用的IP地址，这时，即使外网网卡中的公网IP地址发生了改变，也能够正常的、动态的将内部主机的报文的源IP映射为对应的公网IP。

可以把MASQUERADE理解为动态的、自动化的SNAT，如果没有动态SNAT的需求，没有必要使用MASQUERADE，因为SNAT更加高效。



REDIRECT：

使用REDIRECT动作可以在本机上进行端口映射
比如，将本机的80端口映射到本机的8080端口上
iptables -t nat -A PREROUTING -p tcp –dport 80 -j REDIRECT –to-ports 8080
经过上述规则映射后，当别的机器访问本机的80端口时，报文会被重定向到本机的8080端口上。
REDIRECT规则只能定义在PREROUTING链或者OUTPUT链中。




SNAT       改写封包来源 IP 为某特定 IP 或 IP 范围，可以指定 port 对应的范围，进行完此处理动作后，将直接跳往下一个规则（mangleostrouting）。

        例如：iptables -t nat -A POSTROUTING -p tcp-o eth0 -j SNAT --to-source 194.236.50.155-194.236.50.160:1024-32000

DNAT      改写封包目的地 IP 为某特定 IP 或 IP 范围，可以指定 port 对应的范围，进行完此处理动作后，将会直接跳往下一个规炼（filter:input 或 filter:forward）。

        例如：iptables -t nat -A PREROUTING -p tcp -d 15.45.23.67 --dport 80 -j DNAT --to-destination 192.168.1.1-192.168.1.10:80-100



MIRROR    镜射封包，也就是将来源 IP 与目的地 IP 对调后，将封包送回，进行完此处理动作后，将会中断过滤程序。

QUEUE     中断过滤程序，将封包放入队列，交给其它程序处理。透过自行开发的处理程序，可以进行其它应用，

           例如：计算联机费......等。

RETURN    结束在目前规则炼中的过滤程序，返回主规则炼继续过滤，如果把自订规则炼看成是一个子程序，那么这个动作，就相当提早结束子程序并返回到主程序中。

MARK     将封包标上某个代号，以便提供作为后续过滤的条件判断依据，进行完此处理动作后，将会继续比对其它规则。

        例如：iptables -t mangle -A PREROUTING -p tcp --dport 22 -j MARK --set-mark 2





```
REJECT动作的常用选项为–reject-with

使用–reject-with选项，可以设置提示信息，当对方被拒绝时，会提示对方为什么被拒绝。

可用值如下

icmp-net-unreachable

icmp-host-unreachable

icmp-port-unreachable,

icmp-proto-unreachable

icmp-net-prohibited

icmp-host-pro-hibited

icmp-admin-prohibited

当不设置任何值时，默认值为icmp-port-unreachable。

 
```

# 小结

### SNAT相关操作

配置SNAT，可以隐藏网内主机的IP地址，也可以共享公网IP，访问互联网，如果只是共享IP的话，只配置如下SNAT规则即可。

```
iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -j SNAT --to-source 公网IP
```

 

如果公网IP是动态获取的，不是固定的，则可以使用MASQUERADE进行动态的SNAT操作，如下命令表示将10.1网段的报文的源IP修改为eth0网卡中可用的地址。

```
iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -o eth0 -j MASQUERADE
```

 

### DNAT相关操作

配置DNAT，可以通过公网IP访问局域网内的服务。

注：理论上来说，只要配置DNAT规则，不需要对应的SNAT规则即可达到DNAT效果。

但是在测试DNAT时，对应SNAT规则也需要配置，才能正常DNAT，可以先尝试只配置DNAT规则，如果无法正常DNAT，再尝试添加对应的SNAT规则，SNAT规则配置一条即可，DNAT规则需要根据实际情况配置不同的DNAT规则。

```
iptables -t nat -I PREROUTING -d 公网IP -p tcp --dport 公网端口 -j DNAT --to-destination 私网IP:端口号

iptables -t nat -I PREROUTING -d 公网IP -p tcp --dport 8080 -j DNAT --to-destination 10.1.0.1:80

iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -j SNAT --to-source 公网IP
```

 

在本机进行目标端口映射时可以使用REDIRECT动作。

```
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
```

配置完成上述规则后，其他机器访问本机的80端口时，会被映射到8080端口。