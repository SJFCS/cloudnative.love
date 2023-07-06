---
title: TCPdump
---

>参考链接：  
>[tcpdump命令详解](https://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html)  
>[万字长文](https://baijiahao.baidu.com/s?id=1671144485218215170&wfr=spider&for=pc)  
>[实例参考](https://fuckcloudnative.io/posts/tcpdump-examples/)  
>https://www.cnblogs.com/wongbingming/p/13212306.html

- https://icloudnative.io/posts/tcpdump-examples/#2-%E8%BF%87%E6%BB%A4%E5%99%A8
- https://www.cnblogs.com/wongbingming/archive/2020/06/30/13212306.html


## 配合ssh通道传入wireshark

>ssh当通道让tcpdump远程抓包，再将数据实时传送到本地，再用wireshark图形化界面实时打开
>https://blog.csdn.net/koalazoo/article/details/84958752
>
>准备工作
>本地PC机上得有命令行版的ssh，图形化的SecureCRT应该不行
>本地PC机上有wireshark
>远程主机上有tcpdump
>你有远程主机的root权限（否则你也抓不了包啊）
>找到本地PC机上ssh和wireshark的路径（或者加入PATH，用于执行命令）
>工作思路
>基本的想法就是用ssh登录到远程主机上，发起tcpdump抓包，并将tcpdump抓到的结果输出到stdout，再传回本地PC机，而本地PC机上的wireshark以stdin为输入，两者以管道连接传输。
>
>**命令示例**
>
>```
>ssh root@some.host 'tcpdump -i eth0 port 80 -s 0 -l -w -' | wireshark -k -i -
>```
>
>命令执行后会弹出wireshark界面，这时需要切回刚刚的命令行，因为需要输入密码以登录远程主机（已经配置免密另说），连接成功后即开始抓包，并在本地PC的wireshark上实时显示抓包结果。
>
>**参数解释**
>tcpdump中 ‘-l ’ （这里是小写的字母L）是指line-buffer，即不使用缓存，直接输出，否则就会一段段的输出。’-w -'是指写文件，目标文件为标准输出。至于tcpdump另外的参数，想抓什么端口，这个请搜下度娘，一搜一大把。
>
>wireshark中 ‘-k’ 是指马上开始捕获数据，’-i -’ 是指从指定接口获取，源为标准输入。
>
>或者可以用plink（putty的命令行版本）
>
>```
>plink -ssh USER@HOST -pw PASS "tcpdump -s 0 -U -n -i br-lan -w - not port 22" | wireshark -k -i -
>```
## 前言
tcpdump 的参数非常的多，初学者在没有掌握 tcpdump 时，会对这个命令的众多参数产生很多的疑惑。

就比如下面这个命令，我们要通过 host 参数指定 host ip 进行过滤
$ tcpdump host 192.168.10.100

主程序 + 参数名+ 参数值 这样的组合才是我们正常认知里面命令行该有的样子。
可 tcpdump 却不走寻常路，可以在 host 前再加一个限定词，来缩小过滤的范围
$ tcpdump src host 192.168.10.100

前面还可以加更多的条件，如 tcp, udp, icmp 等词，在之前的基础上再过滤一层。
$ tcpdump tcp src host 192.168.10.100

这种参数的不确定性，让大多数人对 tcpdump 的学习始终无法得其精髓。
如果你在网上看到有关 tcpdump 的博客、教程，无一不是给你一个参数组合，告诉你这是实现了怎样的一个过滤器？这样的教学方式，很容易让你依赖别人的文章来使用 tcpdump，而不能将 tcpdump 这样神器消化，达到灵活应用，灵活搭配过滤器的效果。


了解**tcpdump 的参数是如何组成的？这非常重要。**

>![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.25-16:57:57-D-assets-TCPdump-908fa0ec08fa513ddc9fa0046821bcfdb3fbd983.png)
>
>1. option 可选参数：对应本文 **第四节：可选参数解析**
>2. proto 类过滤器：根据协议进行过滤，关键词协议号/协议名：upd, udp, icmp, ip, ip6, arp, rarp,ether,wlan, fddi, tr, decnet
>3. type 类过滤器：可识别的关键词有：host, net, port, portrange，这些词后边需要再接参数。
>4. direction 类过滤器：根据数据流向进行过滤，可识别的关键字有：src, dst，同时你可以使用逻辑运算符进行组合，比如 src or dst
>5. proto、type、direction 这三类过滤器的内容比较简单，也最常用，因此我将其放在最前面，也就是 **第三节：常规过滤规则**一起介绍。
>6.  **第六节：特殊过滤规则** ， tcpdump 还有一些过滤关键词，它不符合以上四种过滤规则

## 理解 tcpdump 的输出
>**2.1 输出内容结构**
>
>tcpdump 输出的内容虽然多，却很规律。
>
>这里以我随便抓取的一个 tcp 包为例来看一下
>
>21:26:49.013621 IP 172.20.20.1.15605 > 172.20.20.2.5920: Flags [P.], seq 49:97, ack 106048, win 4723, length 48
>
>从上面的输出来看，可以总结出：
>
>第一列：时分秒毫秒 21:26:49.013621
>第二列：网络协议 IP
>第三列：发送方的ip地址+端口号，其中172.20.20.1是 ip，而15605 是端口号
>第四列：箭头 >， 表示数据流向
>第五列：接收方的ip地址+端口号，其中 172.20.20.2 是 ip，而5920 是端口号
>第六列：冒号第
>七列：数据包内容，包括Flags 标识符，seq 号，ack 号，win 窗口，数据长度 length，其中 [P.] 表示 PUSH 标志位为 1，更多标识符见下面
>
>**2.2 Flags 标识符**
>
>使用 tcpdump 抓包后，会遇到的 TCP 报文 Flags，有以下几种：
>
>[S] : SYN（开始连接）
>[P] : PSH（推送数据）
>[F] : FIN （结束连接）
>[R] : RST（重置连接）
>[.] : 没有 Flag，由于除了 SYN 包外所有的数据包都有ACK，所以一般这个标志也可表示 ACK

## 常规direction+type过滤规则
>![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.25-16:57:57-D-assets-TCPdump-908fa0ec08fa513ddc9fa0046821bcfdb3fbd983.png)
>
>tcpdump [option参数选项] [protocol协议] [direction方向] [type类型]
>
>[option参数选项] 为tcpdump 输出格式、选择网卡、保存抓包结果等动作
>
>tcpdump 通过过滤器（filter）灵活的语法可以精确地截取关心的数据报，简化分析的工作量。
>
>[protocol协议] [direction方向] [type类型]都属于过滤器，下面来详细介绍一下它们。
>
>
>
>组合示例
## 2. tcpdump常用参数

```bash
$ tcpdump -i eth0 -nn -s0 -v port 80
```

- **-i** : 选择要捕获的接口，通常是以太网卡或无线网卡，也可以是 `vlan` 或其他特殊接口。如果该系统上只有一个网络接口，则无需指定。

- **-nn** :  `-n` 表示不解析域名，直接显示 IP；`-nn` 表示不解析域名和端口。这样不仅方便查看 IP 和端口号，而且在抓取大量数据时非常高效，因为域名解析会降低抓取速度。

- **-s0** : tcpdump 默认只会截取前 `96` 字节的内容，要想截取所有的报文内容，可以使用 `-s number`， `number` 就是你要截取的报文字节数，如果是 0 的话，表示截取报文全部内容。

- **-v** : 使用 `-v`，`-vv` 和 `-vvv` 来显示更多的详细信息，通常会显示更多与特定协议相关的信息。

  

  额外再介绍几个常用参数：

- **-p** : 不让网络接口进入混杂模式。默认情况下使用 tcpdump 抓包时，会让网络接口进入混杂模式。一般计算机网卡都工作在非混杂模式下，此时网卡只接受来自网络端口的目的地址指向自己的数据。当网卡工作在混杂模式下时，网卡将来自接口的所有数据都捕获并交给相应的驱动程序。如果设备接入的交换机开启了混杂模式，使用 `-p` 选项可以有效地过滤噪声。

- 将抓取的数据写入文件

  使用 tcpdump 截取数据报文的时候，默认会打印到屏幕的默认输出，你会看到按照顺序和格式，很多的数据一行行快速闪过，根本来不及看清楚所有的内容。不过，tcpdump 提供了把截取的数据保存到文件的功能，以便后面使用其他图形工具（比如 wireshark，Snort）来分析。

  `-w` 选项用来把数据报文输出到文件：

  ```bash
  $ tcpdump -i eth0 -s0 -w test.pcap
  ```

- 行缓冲模式

  如果想实时将抓取到的数据通过管道传递给其他工具来处理，需要使用 `-l` 选项来开启行缓冲模式（或使用 `-c` 选项来开启数据包缓冲模式）。使用 `-l` 选项可以将输出通过立即发送给其他命令，其他命令会立即响应。

  ```bash
  $ tcpdump -i eth0 -s0 -l port 80 | grep 'Server:'
  ```

- **-e** : 显示数据链路层信息。默认情况下 tcpdump 不会显示数据链路层信息，使用 `-e` 选项可以显示源和目的 MAC 地址，以及 VLAN tag 信息。例如：

```bash
$ tcpdump -n -e -c 5 not ip6

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on br-lan, link-type EN10MB (Ethernet), capture size 262144 bytes
18:27:53.619865 24:5e:be:0c:17:af > 00:e2:69:23:d3:3b, ethertype IPv4 (0x0800), length 1162: 192.168.100.20.51410 > 180.176.26.193.58695: Flags [.], seq 2045333376:2045334484, ack 3398690514, win 751, length 1108
18:27:53.626490 00:e2:69:23:d3:3b > 24:5e:be:0c:17:af, ethertype IPv4 (0x0800), length 68: 220.173.179.66.36017 > 192.168.100.20.51410: UDP, length 26
18:27:53.626893 24:5e:be:0c:17:af > 00:e2:69:23:d3:3b, ethertype IPv4 (0x0800), length 1444: 192.168.100.20.51410 > 220.173.179.66.36017: UDP, length 1402
18:27:53.628837 00:e2:69:23:d3:3b > 24:5e:be:0c:17:af, ethertype IPv4 (0x0800), length 1324: 46.97.169.182.6881 > 192.168.100.20.59145: Flags [P.], seq 3058450381:3058451651, ack 14349180, win 502, length 1270
18:27:53.629096 24:5e:be:0c:17:af > 00:e2:69:23:d3:3b, ethertype IPv4 (0x0800), length 54: 192.168.100.20.59145 > 192.168.100.1.12345: Flags [.], ack 3058451651, win 6350, length 0
5 packets captured
```

### 显示 ASCII 字符串

`-A` 表示使用 `ASCII` 字符串打印报文的全部数据，这样可以使读取更加简单，方便使用 `grep` 等工具解析输出内容。`-X` 表示同时使用十六进制和 `ASCII` 字符串打印报文的全部数据。这两个参数不能一起使用。例如：

```bash
$ tcpdump -A -s0 port 80
```

## 3. tcpdump过滤器

###  [protocol]-抓取特定协议的数据

在`tcpdump [option参数选项]` 后面可以跟上协议名称或协议号来过滤特定协议的流量常用协议号对应表



| 协议 | 协议号 |ether type 号  |
| ---- | ------ |--|
| IP   |   4     | |
| IPV6 |   41     |0x86dd |
| TCP  |    6    | |
| UDP     | 17       | |
| ICMP     |   1     | |
| OSPF     |   89     | |
| VRRP     |   112     | |
| ISIS     |   124     | |
| L2IP     |    115    | |
| ipv4 |        | 0x0800 |
| tags vlan |        | 0x8100 |
| arp |        | 0x0806 |
| 0x8863 |        | pppoe discovery 发现帧 |
| 0x8864 |        | pppoe session 会话帧 |

1. 直接加协议
2. Proto 过滤器
3. protocol 简写proto 加协议/号   ipv4 ipv6
4. ether type头  ip proto?
5. wlan



例：以 UDP 为例，可以加上参数 `udp` 或 `protocol 17`，这两个命令意思相同。

```
tcpdump -i eth0 udp
tcpdump -i eth0 proto 17
同理，tcp 与 protocol 6 意思相同。
```

 二层以太网帧ether type头，占两个字节，指示了帧的类别

这个ether type在tcpdump上，用ether proto来表示。

比如ipv4的另一个表示法：
\# tcpdump -i eth0 ether proto 0x0800

抓vlan包:
\# tcpdump -i eth0 ether proto 0x8100

抓pppoe包:
\# tcpdump -i eth0 -n ether proto 0x8863 '||' ether proto 0x8864



### [direction]-抓取特定方向的数据

1. src
2. dst

1. 也可以使用 `src` 或 `dst` 只抓取源或目的地：

   ```bash
   $ tcpdump -i eth0 dst 10.10.1.20
   ```

2. 

### [type]-抓取特定类型的数据

1. Host 过滤器

   Host 过滤器可以抓取特定 IP 地址的出站入站流量。

   ```bash
   $ tcpdump -i eth0 host 10.10.1.1
   ```

2. Network 过滤器

   Network 过滤器用来过滤某个网段的数据，使用的是 [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) 模式。

   可以使用：

   + 四元组（x.x.x.x）子网掩码为 `255.255.255.0`
   + 三元组（x.x.x）子网掩码为 `255.255.255.0`
   + 二元组（x.x）子网掩码为 `255.255.0.0`
   + 一元组（x）子网掩码为 `255.0.0.0`

**例如：**

+ 抓取所有发往网段 `192.168.1.x` 或从网段 `192.168.1.x` 发出的流量：
  
   ```bash
   $ tcpdump net 192.168.1
   ```
   
+ 也可以使用 CIDR 格式：
  
   ```bash
   $ tcpdump src net 172.16.0.0/12
   ```
3. Port 过滤器

   port

4. portrange



### 组合过滤器-逻辑运算符

过滤的真正强大之处在于你可以随意组合它们.
连接它们常用逻辑符 `与：AND/&&` 、`或：OR/||` 、`非：not/!`。

```bash
"and" or "&&"
"or" or "||"
"not" or "!"
```

>**3.2 基于网段进行过滤：net**
>
>$ tcpdump net 192.168.10.0/24
>
>**3.3 基于端口进行过滤：port**
>
>```bash
>tcpdump port 端口号
>
>如果你想要同时指定两个端口你可以这样写
>
>tcpdump port 80 or port 8088 可以简写成这样 tcpdump port 80 or 8088
>
>指定端口范围
>
>tcpdump portrange 端口号-端口号
>
>对于一些常见协议的默认端口，我们还可以直接使用协议名，而不用具体的端口号
>
>比如 http == 80，https == 443 等
>
>$ tcpdump tcp port http
>```
## 基于协议进行过滤：proto

### 协议号和端口号的区别

![img](D:%5Cassets%5CTCPdump%5Cseo-1255598498.file.myqcloud.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg)



![img](D:%5Cassets%5CTCPdump%5Caliyunzixunbucket.oss-cn-beijing.aliyuncs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg)



![image-20210426170528356](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.26-17:05:29-D-assets-TCPdump-image-20210426170528356.png)



IP协议是网络层协议，协议号是IP包头中的一个字段，标识IP报文中承载的是哪种协议

eg：17号表示是上层即传输层是udp协议，6号表示上层即传输层是tcp协议，89标识上层是ospf协议等等。



tcp/udp是传输层协议，UDP和TCP报文的首部的端口号标识了在应用层的具体应用

eg：80 http服务，23 telnet服务，53 dns服务。



IP数据报则是将UDP或者TCP报文做为其数据部分，再加上IP数据报首部，封装成IP数据报。而协议号则是存在这个IP数据报的首部，端口号在TCP/UDP报文首部。

目的主机收到IP包后，根据IP协议号确定送给哪个模块（TCP/UDP/ICMP...）处理，送给TCP/UDP模块的报文根据端口号确定送给哪个应用程序处理。



>
>
>protocol 可选值：tcp, udp, icmp, http, ip, ip6, arp, rarp, atalk, aarp, decnet, sca, lat, mopdl, moprc, iso, stp, ipx, or netbeui......或者相应的协议号
>
>若你只想查看 icmp 的包，可以直接这样写
>
>$ tcpdump icmp
## 基本IP协议的版本进行过滤

>
>当你想查看 tcp 的包，你也许会这样子写
>
>$ tcpdump tcp
>
>这样子写也没问题，就是不够精准，为什么这么说呢？
>
>ip 根据版本的不同，可以再细分为 IPv4 和 IPv6 两种，如果你只指定了 tcp，这两种其实都会包含在内。
>
>那有什么办法，能够将 IPv4 和 IPv6 区分开来呢？
>
>很简单，如果是 IPv4 的 tcp 包 ，就这样写（友情提示：数字 6 表示的是 tcp 在ip报文中的编号。）
>
>```
>$ tcpdump 'ip proto tcp'
>$ tcpdump ip proto 6
>$ tcpdump 'ip protochain tcp'
>$ tcpdump ip protochain 6
>```
>
>而如果是 IPv6 的 tcp 包 ，就这样写
>
>```
>$ tcpdump 'ip6 proto tcp'
>$ tcpdump ip6 proto 6
>$ tcpdump 'ip6 protochain tcp'
>$ tcpdump ip6 protochain 6
>```
>
>关于上面这几个命令示例，有两点需要注意：
>
>跟在 proto 和 protochain 后面的如果是 tcp, udp, icmp ，那么过滤器需要用引号包含，这是因为 tcp,udp, icmp 是 tcpdump 的关键字。
>
>跟在ip 和 ip6 关键字后面的 proto 和 protochain 是两个新面孔，看起来用法类似，它们是否等价，又有什么区别呢？关于第二点，网络上没有找到很具体的答案，我只能通过 man tcpdump 的提示， 给出自己的个人猜测，但不保证正确。
>
>proto 后面跟的  protocol  的关键词是固定的，只能是 ip, ip6, arp, rarp, atalk, aarp, decnet, sca, lat, mopdl, moprc, iso, stp, ipx, or netbeui 这里面的其中一个。
>
>而 protochain 后面跟的 protocol 要求就没有那么严格，它可以是任意词，只要 tcpdump 的 IP 报文头部里的 protocol 字段为 ` protocol ` 就能匹配上。
>
>理论上来讲，下面两种写法效果是一样的
>
>```
>$ tcpdump 'ip && tcp'
>$ tcpdump 'ip proto tcp'
>```
>
>同样的，这两种写法也是一样的
>
>```
>$ tcpdump 'ip6 && tcp'
>$ tcpdump 'ip6 proto tcp'
>```

## 可选参数解析
>
>**4.1 设置不解析域名提升速度**
>
>-n：显示 ip，不把ip转化成域名，避免执行 DNS lookups 的过程
>-nn：不把协议和端口号转化成名字。
>-N：不打印出host 的域名部分.。比如,，如果设置了此选现，tcpdump 将会打印'nic' 而不是 'nic.ddn.mil'.
>
>**4.2 过滤结果输出到文件**
>
>使用 tcpdump 工具抓到包后，往往需要再借助其他的工具进行分析，比如常见的 wireshark 。
>
>而要使用wireshark ，我们得将 tcpdump 抓到的包数据生成到文件中，最后再使用 wireshark 打开它即可。
>
>使用 -w 参数后接一个以 .pcap 后缀命令的文件名，就可以将 tcpdump 抓到的数据保存到文件中。
>
>$ tcpdump icmp -w icmp.pcap
>
>**4.3 从文件中读取包数据**
>
>使用 -w 是写入数据到文件，而使用 -r 是从文件中读取数据。
>
>读取后，我们照样可以使用上述的过滤器语法进行过滤分析。
>
>$ tcpdump icmp -r all.pcap
>
>**4.4 控制详细内容的输出**
>
>-v：产生详细的输出. 比如包的TTL，id标识，数据包长度，以及IP包的一些选项。同时它还会打开一些附加的包完整性检测，比如对IP或ICMP包头部的校验和。-vv：产生比-v更详细的输出. 比如NFS回应包中的附加域将会被打印, SMB数据包也会被完全解码。（摘自网络，目前我还未使用过）-vvv：产生比-vv更详细的输出。比如 telent 时所使用的SB, SE 选项将会被打印, 如果telnet同时使用的是图形界面，其相应的图形选项将会以16进制的方式打印出来（摘自网络，目前我还未使用过）**4.5 控制时间的显示**
>
>-t：在每行的输出中不输出时间-tt：在每行的输出中会输出时间戳-ttt：输出每两行打印的时间间隔(以毫秒为单位)-tttt：在每行打印的时间戳之前添加日期的打印（此种选项，输出的时间最直观）**4.6 显示数据包的头部**
>
>-x：以16进制的形式打印每个包的头部数据（但不包括数据链路层的头部）-xx：以16进制的形式打印每个包的头部数据（包括数据链路层的头部）-X：以16进制和 ASCII码形式打印出每个包的数据(但不包括连接层的头部)，这在分析一些新协议的数据包很方便。-XX：以16进制和 ASCII码形式打印出每个包的数据(包括连接层的头部)，这在分析一些新协议的数据包很方便。**4.7 过滤指定网卡的数据包**
>
>-i：指定要过滤的网卡接口，如果要查看所有网卡，可以 -i any**4.8 过滤特定流向的数据包**
>
>-Q：选择是入方向还是出方向的数据包，可选项有：in, out, inout，也可以使用 --direction=[direction] 这种写法**4.9 其他常用的一些参数**
>
>-A：以ASCII码方式显示每一个数据包(不显示链路层头部信息). 在抓取包含网页数据的数据包时, 可方便查看数据-l : 基于行的输出，便于你保存查看，或者交给其它工具分析-q : 简洁地打印输出。即打印很少的协议相关信息, 从而输出行都比较简短.-c : 捕获 count 个包 tcpdump 就退出-s : tcpdump 默认只会截取前 96 字节的内容，要想截取所有的报文内容，可以使用 -s number， number 就是你要截取的报文字节数，如果是 0 的话，表示截取报文全部内容。-S : 使用绝对序列号，而不是相对序列号-C：file-size，tcpdump 在把原始数据包直接保存到文件中之前, 检查此文件大小是否超过file-size. 如果超过了, 将关闭此文件,另创一个文件继续用于原始数据包的记录. 新创建的文件名与-w 选项指定的文件名一致, 但文件名后多了一个数字.该数字会从1开始随着新创建文件的增多而增加. file-size的单位是百万字节(nt: 这里指1,000,000个字节,并非1,048,576个字节, 后者是以1024字节为1k, 1024k字节为1M计算所得, 即1M=1024 ＊ 1024 ＝ 1,048,576)-F：使用file 文件作为过滤条件表达式的输入, 此时命令行上的输入将被忽略.**4.10 对输出内容进行控制的参数**
>
>-D : 显示所有可用网络接口的列表-e : 每行的打印输出中将包括数据包的数据链路层头部信息-E : 揭秘IPSEC数据-L ：列出指定网络接口所支持的数据链路层的类型后退出-Z：后接用户名，在抓包时会受到权限的限制。如果以root用户启动tcpdump，tcpdump将会有超级用户权限。-d：打印出易读的包匹配码-dd：以C语言的形式打印出包匹配码.-ddd：以十进制数的形式打印出包匹配码
## 过滤规则组合
>
>有编程基础的同学，对于下面三个逻辑运算符应该不陌生了吧
>
>and：所有的条件都需要满足，也可以表示为 &&
>or：只要有一个条件满足就可以，也可以表示为 ||
>not：取反，也可以使用 !
>举个例子，我想需要抓一个来自10.5.2.3，发往任意主机的3389端口的包
>
>$ tcpdump src 10.5.2.3 and dst port 3389
>
>当你在使用多个过滤器进行组合时，有可能需要用到括号，而括号在 shell 中是特殊符号，因为你需要使用引号将其包含。例子如下：
>
>$ tcpdump 'src 10.0.2.4 and (dst port 3389 or 22)'
>
>而在单个过滤器里，常常会判断一条件是否成立，这时候，就要使用下面两个符号
>
>=：判断二者相等
>==：判断二者相等
>!=：判断二者不相等当你使用这两个符号时，tcpdump 还提供了一些关键字的接口来方便我们进行判断，比如
>
>if：表示网卡接口名、proc：表示进程名pid：表示进程 idsvc：表示 service classdir：表示方向，in 和 outeproc：表示 effective process nameepid：表示 effective process ID
>比如我现在要过滤来自进程名为 nc 发出的流经 en0 网卡的数据包，或者不流经 en0 的入方向数据包，可以这样子写
>
>$ tcpdump "( if=en0 and proc =nc ) || (if != en0 and dir=in)"
>
>4、抓取主机10.37.63.255和主机10.37.63.61或10.37.63.95的通信：
>
>![image-20210427141544830](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.27-14:15:46-D-assets-TCPdump-image-20210427141544830.png)
>
>tcpdump抓TCP三次握手抓包分析：
>
>sudotcpdump-n-S-ilo0host10.37.63.3andtcpport8080
>
>
>![技术分享](D:%5Cassets%5CTCPdump%5C1760830-76e3c0d065f35b35)
>
>---
## 特殊过滤规则
>**5.1 根据 tcpflags 进行过滤**
>
>通过上一篇文章，我们知道了 tcp 的首部有一个标志位。
>
>![img](D:%5Cassets%5CTCPdump%5C21a4462309f790526c2a7b3d5bbf3ecc7bcbd54b.png)
>
>TCP 报文首部
>
>tcpdump 支持我们根据数据包的标志位进行过滤
>
>proto [ expr:size ]
>
>proto：可以是熟知的协议之一（如ip，arp，tcp，udp，icmp，ipv6）expr：可以是数值，也可以是一个表达式，表示与指定的协议头开始处的字节偏移量。size：是可选的，表示从字节偏移量开始取的字节数量。接下来，我将举几个例子，让人明白它的写法，不过在那之前，有几个点需要你明白，这在后面的例子中会用到：
>
>**1、**tcpflags 可以理解为是一个别名常量，相当于 13，它代表着与指定的协议头开头相关的字节偏移量，也就是标志位，所以 tcp[tcpflags] 等价于 tcp[13] ，对应下图中的报文位置。
>
>![img](D:%5Cassets%5CTCPdump%5C4e4a20a4462309f729c9da8c2a42e5f5d6cad659.png)
>
>**2、**tcp-fin, tcp-syn, tcp-rst, tcp-push, tcp-ack, tcp-urg 这些同样可以理解为别名常量，分别代表 1，2，4，8，16，32，64。这些数字是如何计算出来的呢？
>
>以 tcp-syn 为例，你可以参照下面这张图，计算出来的值 是就是 2
>
>![img](D:%5Cassets%5CTCPdump%5C09fa513d269759eedc1f418fe7b7aa106c22dffe.png)
>
>由于数字不好记忆，所以一般使用这样的“别名常量”表示。
>
>因此当下面这个表达式成立时，就代表这个包是一个 syn 包。
>
>tcp[tcpflags] == tcp-syn
>
>要抓取特定数据包，方法有很多种。
>
>下面以最常见的 syn包为例，演示一下如何用 tcpdump 抓取到 syn 包，而其他的类型的包也是同样的道理。
>
>据我总结，主要有三种写法：
>
>1、第一种写法：使用数字表示偏移量
>
>$ tcpdump -i eth0 "tcp[13] & 2 != 0"
>
>2、第二种写法：使用别名常量表示偏移量
>
>$ tcpdump -i eth0 "tcp[tcpflags] & tcp-syn != 0"
>
>3、第三种写法：使用混合写法
>
>$ tcpdump -i eth0 "tcp[tcpflags] & 2 != 0"# or$ tcpdump -i eth0 "tcp[13] & tcp-syn != 0"
>
>如果我想同时捕获多种类型的包呢，比如 syn + ack 包
>
>1、第一种写法
>
>$ tcpdump -i eth0 'tcp[13] == 2 or tcp[13] == 16'
>
>2、第二种写法
>
>$ tcpdump -i eth0 'tcp[tcpflags] == tcp-syn or tcp[tcpflags] == tcp-ack'
>
>3、第三种写法
>
>$ tcpdump -i eth0 "tcp[tcpflags] & (tcp-syn|tcp-ack) != 0"
>
>4、第四种写法：注意这里是 单个等号，而不是像上面一样两个等号，18（syn+ack） = 2（syn） + 16（ack）
>
>$ tcpdump -i eth0 'tcp[13] = 18'# or$ tcpdump -i eth0 'tcp[tcpflags] = 18'
>
>tcp 中有 类似 tcp-syn 的别名常量，其他协议也是有的，比如 icmp 协议，可以使用的别名常量有
>
>icmp-echoreply, icmp-unreach, icmp-sourcequench, icmp-redirect, icmp-echo, icmp-routeradvert,icmp-routersolicit, icmp-timx-ceed, icmp-paramprob, icmp-tstamp, icmp-tstampreply,icmp-ireq, icmp-ireqreply, icmp-maskreq, icmp-maskreply
>
>**5.2 基于包大小进行过滤**
>
>若你想查看指定大小的数据包，也是可以的
>
>$ tcpdump less 32 $ tcpdump greater 64 $ tcpdump <= 128
>
>**5.3 根据 mac 地址进行过滤**
>
>例子如下，其中 ehost 是记录在 /etc/ethers 里的 name
>
>$ tcpdump ether host [ehost]$ tcpdump ether dst [ehost]$ tcpdump ether src [ehost]
>
>**5.4 过滤通过指定网关的数据包**
>
>$ tcpdump gateway [host]
>
>**5.5 过滤广播/多播数据包**
>
>$ tcpdump ether broadcast$ tcpdump ether multicast$ tcpdump ip broadcast$ tcpdump ip multicast$ tcpdump ip6 multicast
>
>---
>
>**如何抓取到更精准的包？**
>
>先给你抛出一个问题：如果我只想抓取 HTTP 的 POST 请求该如何写呢？
>
>如果只学习了上面的内容，恐怕你还是无法写法满足这个抓取需求的过滤器。
>
>在学习之前，我先给出答案，然后再剖析一下，这个过滤器是如何生效的，居然能让我们对包内的内容进行判断。
>
>$ tcpdump -s 0 -A -vv 'tcp[((tcp[12:1] & 0xf0) >> 2):4]'
>
>命令里的可选参数，在前面的内容里已经详细讲过了。这里不再细讲。
>
>本节的重点是引号里的内容，看起来很复杂的样子。
>
>将它逐一分解，我们只要先理解了下面几种用法，就能明白
>
>tcp[n]：表示 tcp 报文里 第 n 个字节tcp[n:c]：表示 tcp 报文里从第n个字节开始取 c 个字节，tcp[12:1] 表示从报文的第12个字节（因为有第0个字节，所以这里的12其实表示的是13）开始算起取一个字节，也就是 8 个bit。查看 tcp 的报文首部结构，可以得知这 8 个bit 其实就是下图中的红框圈起来的位置，而在这里我们只要前面 4个bit，也就是实际数据在整个报文首部中的偏移量。
>
>![img](D:%5Cassets%5CTCPdump%5C5d6034a85edf8db187405da75c6f3452574e745d.png)
>
>&：是位运算里的 and 操作符，比如 0011 & 0010 = 0010>>：是位运算里的右移操作，比如 0111 >> 2 = 00110xf0：是 10 进制的 240 的 16 进制表示，但对于位操作来说，10进制和16进制都将毫无意义，我们需要的是二进制，将其转换成二进制后是：11110000，这个数有什么特点呢？前面个 4bit 全部是 1，后面4个bit全部是0，往后看你就知道这个特点有什么用了。分解完后，再慢慢合并起来看
>
>1、tcp[12:1] & 0xf0 其实并不直观，但是我们将它换一种写法，就好看多了，假设 tcp 报文中的 第12 个字节是这样组成的 10110000，那么这个表达式就可以变成 10110110 && 11110000 = 10110000，得到了 10110000 后，再进入下一步。
>
>2、tcp[12:1] & 0xf0) >> 2 ：如果你不理解 tcp 报文首部里的数据偏移，请先点击这个前往我的上一篇文章，搞懂数据偏移的意义，否则我保证你这里会绝对会听懵了。
>
>tcp[12:1] & 0xf0) >> 2 这个表达式实际是 (tcp[12:1] & 0xf0) >> 4 ) << 2 的简写形式。所以要搞懂 tcp[12:1] & 0xf0) >> 2 只要理解了(tcp[12:1] & 0xf0) >> 4 ) << 2 就行了 。
>
>从上一步我们算出了 tcp[12:1] & 0xf0 的值其实是一个字节，也就是 8 个bit，但是你再回去看下上面的 tcp 报文首部结构图，表示数据偏移量的只有 4个bit，也就是说 上面得到的值 10110000，前面 4 位（1011）才是正确的偏移量，那么为了得到 1011，只需要将 10110000 右移4位即可，也就是 tcp[12:1] & 0xf0) >> 4，至此我们是不是已经得出了实际数据的正确位置呢，很遗憾还没有，前一篇文章里我们讲到 Data Offset 的单位是 4个字节，因为要将 1011 乘以 4才可以，除以4在位运算中相当于左移2位，也就是 <<2，与前面的 >>4 结合起来一起算的话，最终的运算可以简化为 >>2
>
>至此，我们终于得出了实际数据开始的位置是 tcp[12:1] & 0xf0) >> 2 （单位是字节）。
>
>找到了数据的起点后，可别忘了我们的目的是从数据中打到 HTTP 请求的方法，是 GET 呢 还是 POST ，或者是其他的？
>
>有了上面的经验，我们自然懂得使用 tcp[((tcp[12:1] & 0xf0) >> 2):4] 从数据开始的位置再取出四个字节，然后将结果与 GET （注意 GET最后还有个空格）的 16进制写法（也就是 0x47455420）进行比对。
>
>0x47 --> 71 --> G0x45 --> 69 --> E0x54 --> 84 --> T0x20 --> 32 --> 空格
>
>![img](D:%5Cassets%5CTCPdump%5Cd01373f082025aaf5945f930a3a14262024f1aad.png)
>
>如果相等，则该表达式为True，tcpdump 认为这就是我们所需要抓的数据包，将其输出到我们的终端屏幕上。



## 前言

tcpdump是一个用于截取网络分组，并输出分组内容的工具。凭借强大的功能和灵活的截取策略，使其成为类UNIX系统下用于网络分析和问题排查的首选工具。支持针对网络层、协议、主机、网络或端口的过滤，并提供and、or、not等逻辑语句来帮助你去掉无用的信息。

如果要使用tcpdump抓取其他主机MAC地址的数据包，必须开启网卡混杂模式，所谓混杂模式，用最简单的语言就是让网卡抓取任何经过它的数据包，不管这个数据包是不是发给它或者是它发出的。
```bash
device eth0 left promiscuous mode 网卡 eth0 离开了混杂模式。
ifconfig eth0 promisc 设置网卡eth0为混杂模式
ifconfig eth0 -promisc 取消网卡eth0的混杂模式```
```

## 命令格式
```
tcpdump [ -DenNqvX ] [ -c count ] [ -F file ] [ -i interface ] [ -r file ]
        [ -s snaplen ] [ -w file ] [ expression ]
```

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.26-09:43:45-D-assets-TCPdump-10797253-0ac0eb9ebc75adb4.png)



![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/TCPdump/2021.04.25-16:57:57-D-assets-TCPdump-908fa0ec08fa513ddc9fa0046821bcfdb3fbd983.png)

>
>
>### 抓包选项：
>
>-c：指定要抓取的包数量。
>
>-i interface：指定tcpdump需要监听的接口。默认会抓取第一个网络接口
>
>-n：对地址以数字方式显式，否则显式为主机名，也就是说-n选项不做主机名解析。
>
>-nn：除了-n的作用外，还把端口显示为数值，否则显示端口服务名。
>
>-P：指定要抓取的包是流入还是流出的包。可以给定的值为"in"、"out"和"inout"，默认为"inout"。
>
>-s len：设置tcpdump的数据包抓取长度为len，如果不设置默认将会是65535字节。对于要抓取的数据包较大时，长度设置不够可能会产生包截断，若出现包截断，
> ：输出行中会出现"[|proto]"的标志(proto实际会显示为协议名)。但是抓取len越长，包的处理时间越长，并且会减少tcpdump可缓存的数据包的数量，
> ：从而会导致数据包的丢失，所以在能抓取我们想要的包的前提下，抓取长度越小越好。
>
>### 输出选项：
>
>-e：输出的每行中都将包括数据链路层头部信息，例如源MAC和目标MAC。
>
>-q：快速打印输出。即打印很少的协议相关信息，从而输出行都比较简短。
>
>-X：输出包的头部数据，会以16进制和ASCII两种方式同时输出。
>
>-XX：输出包的头部数据，会以16进制和ASCII两种方式同时输出，更详细。
>
>-v：当分析和打印的时候，产生详细的输出。
>
>-vv：产生比-v更详细的输出。
> -vvv：产生比-vv更详细的输出。
>
>### 其他功能性选项：
>
>-D：列出可用于抓包的接口。将会列出接口的数值编号和接口名，它们都可以用于"-i"后。
>
>-F：从文件中读取抓包的表达式。若使用该选项，则命令行中给定的其他表达式都将失效。
>
>-w：将抓包数据输出到文件中而不是标准输出。可以同时配合"-G
>
>time"选项使得输出文件每time秒就自动切换到另一个文件。可通过"-r"选项载入这些文件以进行分析和打印。
>
>-r：从给定的数据包文件中读取数据。使用"-"表示从标准输入中读取。
>
>
>
>### expression 表达式
>
>==**一个基本的表达式单元格式为"proto dir type ID"**==
>
>对于表达式语法，参考  pcap-filter 【pcap-filter - packet filter syntax】
>
>- 类型 type
>
>host, net, port, portrange
>
>例如：host 192.168.201.128  ,  net 128.3, port 20, portrange 6000-6008'
>
>- 目标 dir
>
>src,  dst,  src  or dst, src and dst
>
>- 协议 proto
>
>tcp， udp ， icmp，若未给定协议类型，则匹配所有可能的类型
>
>==表达式单元之间可以使用操作符" and / && / or / || / not / ! "进行连接，从而组成复杂的条件表达式==。如"host foo and not port ftp and not port ftp-data"，这表示筛选的数据包要满足"主机为foo且端口不是ftp(端口21)和ftp-data(端口20)的包"，常用端口和名字的对应关系可在linux系统中的/etc/service文件中找到。
>
>另外，同样的修饰符可省略，如"tcp dst port ftp or ftp-data or domain"与"tcp dst port ftp or tcp dst port ftp-data or tcp dst port domain"意义相同，都表示包的协议为tcp且目的端口为ftp或ftp-data或domain(端口53)。
>
>使用括号"()"可以改变表达式的优先级，但需要注意的是括号会被shell解释，所以应该使用反斜线""转义为"()"，在需要的时候，还需要包围在引号中。
>
># tcpdump示例
>
>==**tcpdump只能抓取流经本机的数据包 **==
>
>### 1. 默认启动
>
>
>
>```undefined
>tcpdump
>```
>
>默认情况下，直接启动tcpdump将监视第一个网络接口(非lo口)上所有流通的数据包。这样抓取的结果会非常多，滚动非常快。
>
>### 2 . 监视指定网络接口的数据包
>
>
>
>```undefined
>tcpdump -i ens33
>```
>
>### 3. 监视指定主机的数据包，例如所有进入或离开node1的数据包
>
>
>
>```undefined
>tcpdump -i ens33  host node1
>```
>
>### 4. 打印node1<-->node2或node1<-->node3之间通信的数据包
>
>
>
>```undefined
>tcpdump -i ens33 host node1 and \(node2 or node3\)
>```
>
>### 5. 打印node1与任何其他主机之间通信的IP数据包,但不包括与node4之间的数据包
>
>
>
>```undefined
>tcpdump -i ens33 host node1 and not node4
>```
>
>### 6. 截获主机node1 发送的所有数据
>
>
>
>```undefined
>tcpdump -i ens33 src host node1
>```
>
>### 7. 监视所有发送到主机node1 的数据包
>
>
>
>```undefined
>tcpdump -i ens33 dst host node1
>```
>
>### 8. 监视指定主机和端口的数据包
>
>
>
>```undefined
>tcpdump -i ens33 port 8080 and host node1
>```
>
>### 9. 监视指定网络的数据包，如本机与192.168网段通信的数据包，"-c 10"表示只抓取10个包
>
>
>
>```css
>tcpdump -i ens33 -c 10 net 192.168
>```
>
>### 10. 打印所有通过网关snup的ftp数据包
>
>
>
>```bash
>tcpdump 'gateway snup and (port ftp or ftp-data)'
>```
>
>注意,表达式被单引号括起来了,这可以防止shell对其中的括号进行错误解析
>
>### 11. 抓取ping包
>
>
>
>```swift
>tcpdump -c 5 -nn -i ens33 
>
>==指定主机抓ping包==
>tcpdump -c 5 -nn -i eth0 icmp and src 192.168.100.62
>```
>
>### 12. 抓取到本机22端口包
>
>
>
>```swift
>tcpdump -c 10 -nn -i ens33 tcp dst port 22
>```
>
>### 13. 解析包数据
>
>
>
>```swift
>tcpdump -c 2 -q -XX -vvv -nn -i ens33 tcp dst port 22
>```