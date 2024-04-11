---
title: 03.Iptables扩展匹配条件模块
---





+ 基本匹配
+ 拓展匹配模块
  

s d p i o

tcp udp icmp

iprange  multiport mac

string time connlimit limit



## 基本匹配参数

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/4.iptables%E5%8C%B9%E9%85%8D%E8%BF%9B%E9%98%B6/2021.04.20-15:09:59-D-assets-4.iptables%E5%8C%B9%E9%85%8D%E8%BF%9B%E9%98%B6-021217_0051_6.png)

iptables -t filter  -p协议 -s源 -d目的    -i进 -o出   -j DROP

-s -d 每个IP之间用逗号隔开，也可以指定为一个网段

-p用于匹配报文的协议类型,可以匹配的协议类型tcp、udp、udplite、icmp、esp、ah、sctp等（centos7中还支持icmpv6、mh）。可自动调用相应模块，-p tcp -m tcp 可以省略写成-p tcp

-i选项是用于匹配报文是从哪个网卡流入的，只能用于PREROUTING链、INPUT链、FORWARD链。

-o选项是用于匹配报文是从哪个网卡流出的，只能用于FORWARD链、OUTPUT链、POSTROUTING链。

看来，FORWARD链属于”中立国”，它能同时使用-i选项与-o选项。

```
#示例如下

iptables -t filter -I INPUT -s 192.168.1.111,192.168.1.118 -j DROP

iptables -t filter -I INPUT -s 192.168.1.0/24 -j ACCEPT

iptables -t filter -I INPUT ! -s 192.168.1.0/24 -j ACCEPT


iptables -t filter -I OUTPUT -d 192.168.1.111,192.168.1.118 -j DROP

iptables -t filter -I INPUT -d 192.168.1.0/24 -j ACCEPT

iptables -t filter -I INPUT ! -d 192.168.1.0/24 -j ACCEPT


iptables -t filter -I INPUT -p icmp -i eth4 -j DROP

iptables -t filter -I OUTPUT -p icmp -o eth4 -j DROP
```

## 协议扩展模块

需要使用-m 模块名称 调用相应模块来实现更高级的匹配规则，特别的当基本匹配-p参数指定协议后，会自动调用相应模块，如 -p tcp -m tcp可省略-m tcp ，变为-p tcp 

说明 比对通讯协议类型是否相符，可以使用 ! 运算子进行反向比对，例如：-p ! tcp ，

意思是指除 tcp 以外的其它类型，包含udp、icmp ...等。如果要比对所有类型，则可以使用 all 关键词，例如：-p all。

### tcp扩展模块

**常用的扩展匹配条件如下：**

`-p tcp -m tcp -{-sport | -dport | -tcp-flags |-syn}`

–sport
用于匹配tcp协议报文的源端口，可以使用冒号指定一个连续的端口范围

```bash
iptables -t filter -I OUTPUT -d 192.168.1.146 -p tcp -m tcp --sport 22 -j REJECT
iptables -t filter -I OUTPUT -d 192.168.1.146 -p tcp -m tcp --sport 22:25 -j REJECT
iptables -t filter -I OUTPUT -d 192.168.1.146 -p tcp -m tcp ! --sport 22 -j ACCEPT
```

–dport
用于匹配tcp协议报文的目标端口，可以使用冒号指定一个连续的端口范围

```bash
iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m tcp --dport 22:25 -j REJECT
iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m tcp --dport :22 -j REJECT
iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m tcp --dport 80: -j REJECT
```
tcp模块的–tcp-flags、–syn参数和state模块请阅读 Iptables安全模块章节
### UDP扩展模块

–sport与–dport，即匹配报文的源端口与目标端口。
只能指定连续的端口范围，并不能一次性指定多个离散的端口，可通过**multiport扩展模块**，指定多个离散的端口。

–sport：匹配udp报文的源地址

–dport：匹配udp报文的目标地址

```
#示例

iptables -t filter -I INPUT -p udp -m udp --dport 137 -j ACCEPT

iptables -t filter -I INPUT -p udp -m udp --dport 137:157 -j ACCEPT

#可以结合multiport模块指定多个离散的端口
```

比如，放行samba服务的137与138这两个UDP端口，示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_1.png)

**当使用扩展匹配条件时，如果未指定扩展模块，iptables会默认调用与”-p”对应的协议名称相同的模块，所以，当使用”-p udp”时，可以省略”-m udp”，示例如下。**

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_2.png)

udp扩展中的–sport与–dport同样支持指定一个连续的端口范围，示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_3.png)

### ICMP扩展模块

常用的扩展匹配条件

–icmp-type：匹配icmp报文的具体类型

```
#示例

iptables -t filter -I INPUT -p icmp -m icmp --icmp-type 8/0 -j REJECT

iptables -t filter -I INPUT -p icmp --icmp-type 8 -j REJECT

iptables -t filter -I OUTPUT -p icmp -m icmp --icmp-type 0/0 -j REJECT

iptables -t filter -I OUTPUT -p icmp --icmp-type 0 -j REJECT

iptables -t filter -I INPUT -p icmp --icmp-type "echo-request" -j REJECT
```

<details>
  <summary><mark><font>在此简单说说ICMP协议 点我展开</font></mark></summary>

ICMP协议的全称为Internet Control Message Protocol，翻译为互联网控制报文协议，它主要用于探测网络上的主机是否可用，目标是否可达，网络是否通畅，路由是否可用等。

icmp报文被细分为如下各种类型

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.22-10:45:42-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_4.png)

从上图可以看出，所有表示”目标不可达”的icmp报文的type码为3，而”目标不可达”又可以细分为多种情况，是网络不可达呢？还是主机不可达呢？再或者是端口不可达呢？所以，为了更加细化的区分它们，icmp对每种type又细分了对应的code，用不同的code对应具体的场景，  所以，我们可以使用type/code去匹配具体类型的ICMP报文，比如可以使用”3/1″表示主机不可达的icmp报文。

上图中的第一行就表示ping回应报文，它的type为0，code也为0，从上图可以看出，ping回应报文属于查询类（query）的ICMP报文，从大类上分，ICMP报文还能分为查询类与错误类两大类，目标不可达类的icmp报文则属于错误类报文。

而我们发出的ping请求报文对应的type为8，code为0。

**了解完上述概念，就好办了，我们来看一些应用场景。**

假设，我们现在想要禁止所有icmp类型的报文进入本机，那么我们可以进行如下设置。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_5.png)

上例中，我们并没有使用任何扩展匹配条件，我们只是使用”-p icmp”匹配了所有icmp协议类型的报文。

如果进行了上述设置，别的主机向我们发送的ping请求报文无法进入防火墙，我们向别人发送的ping请求对应的回应报文也无法进入防火墙。所以，我们既无法ping通别人，别人也无法ping通我们。

 

假设，此刻需求有变，我们只想要ping通别人，但是不想让别人ping通我们，刚才的配置就不能满足我们了，我们则可以进行如下设置（此处不考虑禁ping的情况）

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_6.png)

上图中，使用”-m icmp”表示使用icmp扩展，因为上例中使用了”-p icmp”，所以”-m icmp”可以省略，使用”–icmp-type”选项表示根据具体的type与code去匹配对应的icmp报文，而上图中的”–icmp-type 8/0″表示icmp报文的type为8，code为0才会被匹配到，也就是只有ping请求类型的报文才能被匹配到，所以，别人对我们发起的ping请求将会被拒绝通过防火墙，而我们之所以能够ping通别人，是因为别人回应我们的报文的icmp type为0，code也为0，所以无法被上述规则匹配到，所以我们可以看到别人回应我们的信息。

 

因为type为8的类型下只有一个code为0的类型，所以我们可以省略对应的code，示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_7.png)

 

除了能够使用对应type/code匹配到具体类型的icmp报文以外，我们还能用icmp报文的描述名称去匹配对应类型的报文，示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.23-11:27:24-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-050117_1112_8.png)

没错，上例中使用的 –icmp-type “echo-request”与 –icmp-type 8/0的效果完全相同，参考本文最上方的表格即可获取对应的icmp类型的描述名称。

</details>



## 常用扩展模块

### iprange模块-IP范围匹配

在不使用任何扩展模块的情况下，使用-s选项或者-d选项匹配源目标地址时，只能单个或多个之间用","间隔，不能指定一段连续的IP地址范围。

iprange扩展模块可以指定”一段连续的IP地址范围”，用于匹配报文的源地址或者目标地址。

范围通过"-"连接和其他匹配条件一样，能够使用”!”取反。

**iprange模块的常用选项**

```
–src-range	源地址所在范围
–dst-range	目标地址所在范围
```

### multiport模块-多端口匹配

-m multiport --source-port

-m multiport --destination-port

-m multiport --port

例如： iptables -A INPUT -p tcp -m multiport --port 22,53,80,110

说明 这个参数比较特殊，用来比对来源埠号和目的埠号相同的封包，设定方式同上。



以离散方式定义多端口匹配；最多指定15个端口； 

**常用的扩展匹配条件如下：**

```
-p tcp -m multiport –sports 用于匹配报文的源端口，可以指定离散的多个端口号,端口之间用”逗号”隔开
-p udp -m multiport –dports 用于匹配报文的目标端口，可以指定离散的多个端口号，端口之间用”逗号”隔开
```

示例如下

```
iptables -t filter -I OUTPUT -d 192.168.1.146 -p udp -m multiport --sports 137,138 -j REJECT

iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m multiport --dports 22,80 -j REJECT

iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m multiport ! --dports 22,80 -j REJECT

iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m multiport --dports 80:88 -j REJECT

iptables -t filter -I INPUT -s 192.168.1.146 -p tcp -m multiport --dports 22,80:88 -j REJECT
```



### MAC-MAC地址匹配：

-m mac --mac-source MAC地址

```
例：iptables -A INPUT -m mac --mac-source 00:0c:29:c0:55:3f -j DROP
```



### string扩展模块

使用string扩展模块，可以指定要匹配的字符串，如果报文中包含对应的字符串，则符合匹配条件。

案例：如果报文中包含”OOXX”字符，我们就拒绝报文进入本机

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_2.png)

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_3.png)

上图中'-m string'表示使用string模块，'–algo bm'表示使用bm算法去匹配指定的字符串，'–string "OOXX" '则表示我们想要匹配的字符串为"OOXX"

**string模块的常用选项**

```
–algo：用于指定匹配算法，可选的算法有bm与kmp，此选项为必须选项，我们不用纠结于选择哪个算法，但是我们必须指定一个。
–string：用于指定需要匹配的字符串。
```

### time扩展模块

我们可以通过time扩展模块，根据时间段区匹配报文，如果报文到达的时间在指定的时间范围以内，则符合匹配条件。

比如，”我想要自我约束，每天早上9点到下午6点不能看网页”，擦，多么残忍的规定，如果你想要这样定义，可以尝试使用如下规则。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_4.png)

上图中”-m time”表示使用time扩展模块，–timestart选项用于指定起始时间，–timestop选项用于指定结束时间。

 

如果你想要换一种约束方法，只有周六日不能看网页，那么可以使用如下规则。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_5.png)

没错，如你所见，使用–weekdays选项可以指定每个星期的具体哪一天，可以同时指定多个，用逗号隔开，除了能够数字表示”星期几”,还能用缩写表示，例如：Mon, Tue, Wed, Thu, Fri, Sat, Sun

 

当然，你也可以将上述几个选项结合起来使用，比如指定只有周六日的早上9点到下午6点不能浏览网页。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_6.png)

 

聪明如你一定想到了，既然有–weekdays选项了，那么有没有–monthdays选项呢？必须有啊！

使用–monthdays选项可以具体指定的每个月的哪一天，比如，如下图设置表示指明每月的22号，23号。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_7.png)

 

前文已经总结过，当一条规则中同时存在多个条件时，多个条件之间默认存在”与”的关系，所以，下图中的设置表示匹配的时间必须为星期5，并且这个”星期5″同时还需要是每个月的22号到28号之间的一天，所以，下图中的设置表示每个月的第4个星期5

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_8.png)

 

除了使用–weekdays选项与–monthdays选项，还可以使用–datestart 选项与-datestop选项，指定具体的日期范围，如下。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-09:37:34-D-assets-5.iptables%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_9.png)

上图中指定的日期范围为2017年12月24日到2017年12月27日

上述选项中，–monthdays与–weekdays可以使用”!”取反，其他选项不能取反。

### connlimit扩展模块

使用connlimit扩展模块，可以限制每个IP地址同时链接到server端的链接数量，注意：我们不用指定IP，其默认就是针对”每个客户端IP”，即对单IP的并发连接数限制。

比如，我们想要限制，每个IP地址最多只能占用两个ssh链接远程到server端，我们则可以进行如下限制。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:35:08-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_10.png)

上例中，使用”-m connlimit”指定使用connlimit扩展，使用”–connlimit-above 2″表示限制每个IP的链接数量上限为2，再配合-p tcp –dport 22，即表示限制每个客户端IP的ssh并发链接数量不能高于2。

centos6中，我们可以对–connlimit-above选项进行取反，没错，老规矩，使用”!”对此条件进行取反，示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:35:08-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_11.png)

上例表示，每个客户端IP的ssh链接数量只要不超过两个，则允许链接。

但是聪明如你一定想到了，上例的规则并不能表示：每个客户端IP的ssh链接数量超过两个则拒绝链接（与前文中的举例原理相同，此处不再赘述，如果你不明白，请参考之前的文章）。也就是说，即使我们配置了上例中的规则，也不能达到”限制”的目的，所以我们通常并不会对此选项取反，因为既然使用了此选项，我们的目的通常就是”限制”连接数量。

centos7中iptables为我们提供了一个新的选项，–connlimit-upto，这个选项的含义与”! –commlimit-above”的含义相同，即链接数量未达到指定的连接数量之意，所以综上所述，–connlimit-upto选项也不常用。

 

刚才说过，–connlimit-above默认表示限制”每个IP”的链接数量，其实，我们还可以配合–connlimit-mask选项，去限制”某类网段”的链接数量，示例如下：

（注：下例需要一定的网络知识基础，如果你还不了解它们，可以选择先跳过此选项或者先去学习部分的网络知识）

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:35:08-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_12.png)

上例中，”–connlimit-mask 24″表示某个C类网段，没错，mask为掩码之意，所以将24转换成点分十进制就表示255.255.255.0，所以，上图示例的规则表示，一个最多包含254个IP的C类网络中，同时最多只能有2个ssh客户端连接到当前服务器，看来资源很紧俏啊！254个IP才有2个名额，如果一个IP同时把两个连接名额都占用了，那么剩下的253个IP连一个连接名额都没有了，那么，我们再看看下例，是不是就好多了。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:35:08-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_13.png)

上例中，”–connlimit-mask 27″表示某个C类网段，通过计算后可以得知，这个网段中最多只能有30台机器（30个IP），这30个IP地址最多只能有10个ssh连接同时连接到服务器端，是不是比刚才的设置大方多了，当然，这样并不能避免某个IP占用所有连接的情况发生，假设，报文来自192.168.1.40这个IP，按照掩码为27进行计算，这个IP属于192.168.1.32/27网段，如果192.168.1.40同时占用了10个ssh连接，那么当192.168.1.51这个IP向服务端发起ssh连接请求时，同样会被拒绝，因为192.168.1.51这个IP按照掩码为27进行计算，也是属于192.168.1.32/27网段，所以他们共享这10个连接名额。

 

聪明如你一定明白了，在不使用–connlimit-mask的情况下，连接数量的限制是针对”每个IP”而言的，当使用了–connlimit-mask选项以后，则可以针对”某类IP段内的一定数量的IP”进行连接数量的限制，这样就能够灵活许多，不是吗？

### limit扩展模块

connlimit模块是对连接数量进行限制的，limit模块是对”报文到达速率”进行限制的。

用大白话说就是，如果我想要限制单位时间内流入的包的数量，就能用limit模块。

我们可以以秒为单位进行限制，也可以以分钟、小时、天作为单位进行限制。

比如，限制每秒中最多流入3个包，或者限制每分钟最多流入30个包，都可以。

那么，我们来看一个最简单的示例，假设，我们想要限制，外部主机对本机进行ping操作时，本机最多每6秒中放行一个ping包，那么，我们可以进行如下设置（注意，只进行如下设置有可能无法实现限制功能，请看完后面的内容）

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_14.png)

上例中，”-p icmp”表示我们针对ping请求添加了一条规则（ping使用icmp协议），”-m limit”表示使用limit模块， “–limit 10/minute -j ACCEPT”表示每分钟最多放行10个包，就相当于每6秒钟最多放行一个包，换句话说，就是每过6秒钟放行一个包，那么配置完上述规则后，我们在另外一台机器上对当前机器进行ping操作，看看是否能够达到限制的目的，如下图所示。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_15.png)

我们发现，刚才配置的规则并没有如我们想象中的一样，ping请求的响应速率完全没有发生任何变化，为什么呢？我们一起来分析一下。

我们再来回顾一下刚才配置的规则。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_14.png)

其实，我们可以把上图中的规则理解为如下含义。

每6秒放行一个包，那么iptables就会计时，每6秒一个轮次，到第6秒时，达到的报文就会匹配到对应的规则，执行对应的动作，而上图中的动作是ACCEPT。

那么在第6秒之前到达的包，则无法被上述规则匹配到。

之前总结过，报文会匹配链中的每一条规则，如果没有任何一条规则能够匹配到，则匹配默认动作（链的默认策略）。

既然第6秒之前的包没有被上述规则匹配到，而我们又没有在INPUT链中配置其他规则，所以，第6秒之前的包肯定会被默认策略匹配到，那么我们看看默认策略是什么。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_16.png)

现在再想想，我想你应该明白为什么刚才的ping的响应速率没有变化了。

因为，上例中，第六秒的报文的确被对应的规则匹配到了，于是执行了”放行”操作，第6秒之前的报文没有被上图中配置的规则匹配到，但是被默认策略匹配到了，而恰巧，默认动作也是ACCEPT，所以，相当于所有的ping报文都被放行了，怪不得与没有配置规则时的速率一毛一样了。

那么，知错就改，聪明如你一定想到了，我们可以修改INPUT链的默认策略，或者在上例限制规则的后面再加入一条规则，将”漏网之鱼”匹配到即可，示例如下。

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_17.png)

如上图所示，第一条规则表示每分钟最多放行10个icmp包，也就是6秒放行一个，第6秒的icmp包会被上例中的第一条规则匹配到，第6秒之前的包则不会被第一条规则匹配到，于是被后面的拒绝规则匹配到了，那么，此刻，我们再来试试，看看ping的报文放行速率有没有发生改变。

如下图所示

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_18.png)

刚开始还真吓我一跳，难道配置的规则还是有问题？

结果发现，只有前5个ping包没有受到限制，之后的ping包已经开始受到了规则的限制了。

从上图可以看出，除了前5个ping包以外，之后的ping包差不多每6秒才能ping通一次，看来，之后的ping包已经受到了规则的控制，被限制了流入防火墙的速率了，那么，前5个ping包是什么鬼？为什么它们不受规则限制呢？其实，这个现象正好引出另一个话题，出现上图中的情况，是因为另一个选项：”–limit-burst”

limit-burst选项是干什么用的呢？我们先用不准确的大白话描述一遍，”–limit-burst”可以指定”空闲时可放行的包的数量”，其实，这样说并不准确，但是我们可以先这样大概的理解，在不使用”–limit-burst”选项明确指定放行包的数量时，默认值为5，所以，才会出现上图中的情况，前5个ping包并没有受到任何速率限制，之后的包才受到了规则的限制。

 

如果想要彻底了解limit模块的工作原理，我们需要先了解一下”令牌桶”算法，因为limit模块使用了令牌桶算法。

我们可以这样想象，有一个木桶，木桶里面放了5块令牌，而且这个木桶最多也只能放下5块令牌，所有报文如果想要出关入关，都必须要持有木桶中的令牌才行，这个木桶有一个神奇的功能，就是每隔6秒钟会生成一块新的令牌，如果此时，木桶中的令牌不足5块，那么新生成的令牌就存放在木桶中，如果木桶中已经存在5块令牌，新生成的令牌就无处安放了，只能溢出木桶（令牌被丢弃），如果此时有5个报文想要入关，那么这5个报文就去木桶里找令牌，正好一人一个，于是他们5个手持令牌，快乐的入关了，此时木桶空了，再有报文想要入关，已经没有对应的令牌可以使用了，但是，过了6秒钟，新的令牌生成了，此刻，正好来了一个报文想要入关，于是，这个报文拿起这个令牌，就入关了，在这个报文之后，如果很长一段时间内没有新的报文想要入关，木桶中的令牌又会慢慢的积攒了起来，直到达到5个令牌，并且一直保持着5个令牌，直到有人需要使用这些令牌，这就是令牌桶算法的大致逻辑。

 

那么，就拿刚才的”令牌桶”理论类比我们的命令，”–limit”选项就是用于指定”多长时间生成一个新令牌的”，”–limit-burst”选项就是用于指定”木桶中最多存放几个令牌的”，现在，你明白了吗？？示例如下

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.21-10:36:39-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042517_1621_19.png)

上例表示，令牌桶中最多能存放3个令牌，每分钟生成10个令牌（即6秒钟生成一个令牌）。

之前说过，使用”–limit”选项时，可以选择的时间单位有多种，如下

/second

/minute

/hour

/day

比如，3/second表示每秒生成3个”令牌”，30/minute表示没分钟生成30个”令牌”。



## 其他

参数 --mark

范例 iptables -t mangle -A INPUT -m mark --mark 1

说明 用来比对封包是否被表示某个号码，当封包被比对成功时，我们可以透过 MARK 处理动作，将该封包标示一个号码，号码最不可以超过 4294967296。

参数 -m owner --uid-owner

范例 iptables -A OUTPUT -m owner --uid-owner 500

说明 用来比对来自本机的封包，是否为某特定使用者所产生的，这样可以避免服务器使用 

root 或其它身分将敏感数据传送出，可以降低系统被骇的损失。可惜这个功能无法比对出

来自其它主机的封包。

参数 -m owner --gid-owner

范例 iptables -A OUTPUT -m owner --gid-owner 0

说明 用来比对来自本机的封包，是否为某特定使用者群组所产生的，使用时机同上。

参数 -m owner --pid-owner

范例 iptables -A OUTPUT -m owner --pid-owner 78

说明 用来比对来自本机的封包，是否为某特定行程所产生的，使用时机同上。

参数 -m owner --sid-owner

范例 iptables -A OUTPUT -m owner --sid-owner 100

说明 用来比对来自本机的封包，是否为某特定联机（Session ID）的响应封包，使用时

机同上。

## 须先了解TCP ICMP扩展知识

## TCP扩展模块补充

–tcp-flags

用于匹配报文的tcp头的标志位

 比对 TCP 封包的状态旗号，参数分为两个部分，第一个部分列举出想比对的旗号，

      第二部分则列举前述旗号中哪些有被设，未被列举的旗号必须是空的。TCP 状态旗号包括：SYN（同步）、ACK（应答）、

FIN（结束）、RST（重设）、URG（紧急）PSH（强迫推送） 等均可使用于参数中，除此之外还可以使用关键词 ALL 和 

NONE 进行比对。比对旗号时，可以使用 ! 运算子行反向比对。

<details>
  <summary><mark><font>在此简单说说TCP头标志 点我展开</font></mark></summary>

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.22-09:49:00-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042817_0124_1.png)

在使用iptables时，使用tcp扩展模块的”–tcp-flags”选项，即可对上图中的标志位进行匹配，判断指定的标志位的值是否为”1″，而tcp header的结构不是我们今天讨论的重点，我们继续聊tcp的标识位，在tcp协议建立连接的过程中，需要先进行三次握手，而三次握手就要依靠tcp头中的标志位进行。

**三次握手：**

1. **(B) --> [SYN] --> (A)**

	 假如服务器A和客户机B通讯. 当A要和B通信时，B首先向A发一个SYN (Synchronize) 标记的包，告诉A请求建立连接.  
   图为tcp三次握手中的第一次握手，客户端（IP为98）使用本地的随机端口54808向服务端（IP为137）发起连接请求，tcp头的标志位中，只有SYN位被标识为1，其他标志位均为0。
   [TCP Flags: ··········S·]，其中的”S”就表示SYN位，整体表示只有SYN位为1。
   
   ![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.22-09:50:14-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042817_0124_2.png)
   
	>注意: 一个 SYN包就是仅SYN标记设为1的TCP包(参见TCP包头Resources). 认识到这点很重要，只有当A受到B发来的SYN包，才可建立连接，除此之外别无他法。因此，如果你的防火墙丢弃所有的发往外网接口的SYN包，那么你将不能让外部任何主机主动建立连接。  

2. (B) `<-- [SYN/ACK] <--(A)`

   接着，A收到后会发一个对SYN包的确认包(SYN/ACK)回去，表示对第一个SYN包的确 认，并继续握手操作.  
   图为第二次握手，[TCP Flags: ·······A··S·]表示只有ACK标志位与SYN标志位为1，
   ![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(5)%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97/2021.04.22-10:12:13-D-assets-Iptables%E8%AF%A6%E8%A7%A3-5-%E6%89%A9%E5%B1%95%E5%8C%B9%E9%85%8D%E6%9D%A1%E4%BB%B6%E6%A8%A1%E5%9D%97-042817_0124_3.png)注意: SYN/ACK包是仅SYN 和 ACK 标记为1的包.  

   > 说到这里，就已经能够引出我们今天要说的话题了，就是iptables ”–tcp-flags”选项，假设，我现在想要匹配到”第一次握手”的报文，则可以使用如下命令：
   > `iptables -t filter -I INPUT -p tcp -m tcp --tcp-flags SYN,ACK,FIN,RST,URG,PSH SYN -j REJECT`
   >
   > *我们可以把这串字符拆成两部分去理解，第一部分为”SYN,ACK,FIN,RST,URG,PSH”，第二部分为”SYN”。*
   > *第一部分表示：我们需要匹配报文tcp头中的哪些标志位，那么上例的配置表示，我们需要匹配报文tcp头中的6个标志位，这6个标志位分别为为”SYN、ACK、FIN、RST、URG、PSH”，我们可以把这一部分理解成需要匹配的标志位列表。
   > 第二部分表示：第一部分的标志位列表中，哪些标志位必须为1，上例中，第二部分为SYN，则表示，第一部分需要匹配的标志位列表中，SYN标志位的值必须为1，其他标志位必须为0。*
   >
   > **所以上文命令表示：**
   >
   > 需要匹配报文tcp头中的”SYN、ACK、FIN、RST、URG、PSH”这些标志位，其中SYN标志位必须为1，其他的5个标志位必须为0，这与上文中wireshark抓包时的情况相同，正是tcp三次握手时第一次握手时的情况，[TCP Flags: ··········S·]。
   >
   > 

3. (B) --> [ACK] --> (A)  

    B收到SYN/ACK 包,B发一个确认包(ACK)，通知A连接已建立。至此，三次握手完成， 一个TCP连接完成  

    注意: ACK包就是仅ACK 标记设为1的TCP包. 需要注意的是当三此握手完成、连接建立以后，TCP连接的每个包都会设置ACK位  

    这就是为何连接跟踪很重要的原因了. 没有连接跟踪,防火墙将无法判断收到的ACK包是否属于一个已经建立的连接.一般的包过滤(Ipchains)收到ACK包时,会让它通过(这绝对不是个好主意). 而当状态型防火墙收到此种包时，它会先在连接表中查找是否属于哪个已建连接，否则丢弃该包  

**四次挥手**
```
1. (B) --> ACK/FIN --> (A)  
2. (B) <-- ACK <-- (A)  
2. (B) <-- ACK/FIN <-- (A)  
3. (B) --> ACK --> (A)  
```

注意: 由于TCP连接是双向连接, 因此关闭连接需要在两个方向上做。ACK/FIN 包( 标记设为1)通常被认为是FIN(终结)包.然而, 由于连接还没有关闭, FIN包总是打上ACK标记. 没有ACK标记而仅有FIN标记的包不是合法的包，并且通常被认为是恶意的 

**连接复位Resetting a connection**  

四次握手不是关闭TCP连接的唯一方法. 有时,如果主机需要尽快关闭连接(或连接超时,端
口或主机不可达),RST (Reset)包将被发送. 注意在，由于RST包不是TCP连接中的必须
部分, 可以只发送RST包(即不带ACK标记). 但在正常的TCP连接中RST包可以带ACK
确认标记  

请注意RST包是可以不要收到方确认的

**无效的TCP标记：Invalid TCP Flags**

</details>

```bash
iptables -t filter -I INPUT -p tcp -m tcp --dport 22 --tcp-flags SYN,ACK,FIN,RST,URG,PSH SYN -j REJECT
可以用ALL表示”SYN,ACK,FIN,RST,URG,PSH”
iptables -t filter -I OUTPUT -p tcp -m tcp --sport 22 --tcp-flags ALL SYN,ACK -j REJECT
```

–syn
用于匹配tcp新建连接的请求报文，相当于使用”–tcp-flags SYN,RST,ACK,FIN  SYN”

```bash
iptables -t filter -I INPUT -p tcp -m tcp --dport 22 --syn -j REJECT
```

## state扩展模块

未完待续

https://www.zsythink.net/archives/1597

https://blog.csdn.net/dog250/article/details/78372576

https://clodfisher.github.io/2018/09/nf_conntrack/

https://blog.csdn.net/u010472499/article/details/78292811

https://blog.csdn.net/lmy4710/article/details/9115473

http://blog.chinaunix.net/uid-168249-id-2860698.html

https://www.linuxidc.com/Linux/2013-07/87543.htm

http://www.faqs.org/docs/iptables/userlandstates.html

https://blog.csdn.net/ixidof/article/details/42584329

http://blog.chinaunix.net/uid-168249-id-2860899.html

--tcp-flags 和 -m --state 都是我们常说的状态防火墙的基础。

前面提到的--tcp-flags 通常针对畸形报文。
--state 是针对连接状态
大部分防火墙对于连入的连接往往会进行非常严格的过滤，但对于连出的连接却疏于防范。 有一种“反弹端口”原理的木马，使用“隧道”技术，客户端的监听端口开在防火墙信任的端口上，把所有要传送的数据全部封装到合法的报文里进行传送，从服务器发起连接， --state 就是针对这类的。

**states四种状态**

| 状态        | 备注                                                         |
| ----------- | ------------------------------------------------------------ |
| NEW         | conntrack 模块会把具体连接中的第一个数据包视为NEW包将被匹配(NEW与协议无关)。在某些情况下，这可能会导致某些问题，但是当我们需要从其他防火墙中恢复丢失的连接，或者连接已经超时但实际上没有关闭时，它也可能非常有用。 |
| ESTABLISHED | ESTABLISHED可看到两个方向的流量，并持续匹配这些数据包。 建立连接不难理解：当一台主机发送数据包后稍后会收到另一台主机的回复。NEW状态当接收到去往或通过防火墙的reply packet时，状态将变为ESTABLISHED ，说白了当具体连接中第一个NEW包通过后，后续包状态都会变成ESTABLISHED |
| RELATED     | 表示这个封包是与我们主机发送出去的封包有关， 可能是响应封包或者是联机成功之后的传送封包！这个状态很常被设定，因为设定了他之后，只要未来由本机发送出去的封包，即使我们没有设定封包的 INPUT 规则，该有关的封包还是可以进入我们主机， 可以简化相当多的设定规则。当你执行Linux下执行traceroute（Windows下对应的命令为tracert）命令时，这个traceroute会发出一个封包，该封包的TTL（生存时间，Time To Live）位1，当这个包遇到路由器的时候它的TTL会减少1，这时TTL = 0，然后这个包会被丢弃，丢弃这个包的路由器会返回一个ICMP Type 11的封包给你，并告诉你那个发出的数据包气数已尽。而这个ICMP Type 11的链接状态就是“RELATED”。RELATED状态的数据包与“协议”无关，“只要回应回来的是因为本机先送出的一个数据包导致另一个连接的产生，而这一条新连接上的所有数据包都是属于RELATED状态的数据包”。 |
| INVALID     | 便是无法识别该数据包，或该数据包不具有任何状态。可能导致的原因：系统内存不足或ICMP错误消息无法相应任何已知连接。这类包一般会被视为恶意包而被丢弃。 |



> 开篇的例子是不是有问题啊，我理解客户端访问服务端80端口时是以本地的一个随机端口访问的，那么服务端回应客户端时，应该是回应到客户端的随机端口而不是80端口。所以客户端访问服务端的80端口并不需要放行自己的80端口。如果是我理解错了
>
> > 理解的没错，客户端使用随机端口，访问服务端80端口，服务端用80端口响应到客户端的随机端口，但是如果，我们是为了只接受80端口的“响应”报文，不是让服务端主动通过80端口向客户端发送数据时，我们该怎么办？一旦从客户端放行服务端的80端口，那么从服务端的80端口也能逆向主动访问客户端，当我们想要只让客户端主动访问服务端的80端口并接收响应报文时，而不是服务端也可以通过自己的80主动访问客户端时，才会用这个方法，开篇的例子是这个意思，是在客户端的防火墙上对服务端的80端口做限制，开篇的例子没有错，

## 小结

老规矩，为了方便以后回顾，我们将上文中提到的命令总结如下。

 

### iprange模块

包含的扩展匹配条件如下

–src-range：指定连续的源地址范围

–dst-range：指定连续的目标地址范围

```
#示例

iptables -t filter -I INPUT -m iprange --src-range 192.168.1.127-192.168.1.146 -j DROP

iptables -t filter -I OUTPUT -m iprange --dst-range 192.168.1.127-192.168.1.146 -j DROP

iptables -t filter -I INPUT -m iprange ! --src-range 192.168.1.127-192.168.1.146 -j DROP
```

 

### string模块

常用扩展匹配条件如下

–algo：指定对应的匹配算法，可用算法为bm、kmp，此选项为必需选项。

–string：指定需要匹配的字符串

```
#示例

iptables -t filter -I INPUT -p tcp --sport 80 -m string --algo bm --string "OOXX" -j REJECT

iptables -t filter -I INPUT -p tcp --sport 80 -m string --algo bm --string "OOXX" -j REJECT
```

 

### time模块

常用扩展匹配条件如下

–timestart：用于指定时间范围的开始时间，不可取反

–timestop：用于指定时间范围的结束时间，不可取反

–weekdays：用于指定”星期几”，可取反

–monthdays：用于指定”几号”，可取反

–datestart：用于指定日期范围的开始日期，不可取反

–datestop：用于指定日期范围的结束时间，不可取反

```
#示例

iptables -t filter -I OUTPUT -p tcp --dport 80 -m time --timestart 09:00:00 --timestop 19:00:00 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 443 -m time --timestart 09:00:00 --timestop 19:00:00 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time --weekdays 6,7 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time --monthdays 22,23 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time ! --monthdays 22,23 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time --timestart 09:00:00 --timestop 18:00:00 --weekdays 6,7 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time --weekdays 5 --monthdays 22,23,24,25,26,27,28 -j REJECT

iptables -t filter -I OUTPUT -p tcp --dport 80  -m time --datestart 2017-12-24 --datestop 2017-12-27 -j REJECT
```

 

### connlimit 模块

常用的扩展匹配条件如下

–connlimit-above：单独使用此选项时，表示限制每个IP的链接数量。

–connlimit-mask：此选项不能单独使用，在使用–connlimit-above选项时，配合此选项，则可以针对”某类IP段内的一定数量的IP”进行连接数量的限制，如果不明白可以参考上文的详细解释。

```
#示例

iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 2 -j REJECT

iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 20 --connlimit-mask 24 -j REJECT

iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 10 --connlimit-mask 27 -j REJECT
```

 

### limit模块

常用的扩展匹配条件如下

–limit-burst：类比”令牌桶”算法，此选项用于指定令牌桶中令牌的最大数量，上文中已经详细的描述了”令牌桶”的概念，方便回顾。

–limit：类比”令牌桶”算法，此选项用于指定令牌桶中生成新令牌的频率，可用时间单位有second、minute 、hour、day。

```
#示例 #注意，如下两条规则需配合使用，具体原因上文已经解释过，忘记了可以回顾。

iptables -t filter -I INPUT -p icmp -m limit --limit-burst 3 --limit 10/minute -j ACCEPT

iptables -t filter -A INPUT -p icmp -j REJECT
```
