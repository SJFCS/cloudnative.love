---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
---
5.OSPF路由的计算过程

（1）每台OSPF路由器根据自己周围的网络拓扑结构生成LSA（Link State Advertisement，链路状态通告），并通过更新报文将LSA发送给网络中的其它OSPF路由器。

（2）每台OSPF路由器都会收集其它路由器通告的LSA，所有的LSA放在一起便组成了LSDB（Link State Database，链路状态数据库）。LSA是对路由器周围网络拓扑结构的描述，LSDB则是对整个自治系统的网络拓扑结构的描述。

（3）OSPF路由器将LSDB转换成一张带权的有向图，这张图便是对整个网络拓扑结构的真实反映。各个路由器得到的有向图是完全相同的。

（4）每台路由器根据有向图，使用SPF算法计算出一棵以自己为根的最短路径树，这棵树给出了到自治系统中各节点的路由。

6.报文

![89c1ad357fd2b4792feb56daa44f0a62.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ospf.assets/2021.03.09-17:31:02-1592928788627-9e1f46c9-0275-4909-9d2d-e8ace76e99f6.png)

二、DR及BDR介绍

1.DR

在广播网和NBMA网络中，任意两台路由器之间都要交换路由信息。如果网络中有n台路由器，则需要建立n(n-1)/2个邻接关系。这使得任何一台路由器的路由变化都会导致多次传递，浪费了带宽资源。为解决这一问题，0SPF 协议定义了指定路由器DR (Designated Router)，所有路由器都只将信息发送给DR，由DR将网络链路状态发送出去。

2.BDR

如果DR由于某种故障而失效，则网络中的路由器必须重新选举DR,再与新的DR同步。这需要较长的时间，在这段时间内，路由的计算是不正确的。为了能够缩;短这个过程，0SPF 提出了BDR (Backup Desi gnated Router，备份指定路由器)的概念。

3.关系

BDR实际上是对DR的一个备份，在选举DR的同时也选举出BDR，BDR 也和本网段内的所有路由器建立邻接关系并交换路由信息。当DR失效后，BDR会立即成为DR。由于不需要重新选举，并且邻接关系事先已建立，所以这个过程是非常短暂的。当然这时还需要再重新选举出一个新的BDR,虽然一样需要较长的时间，但并不会影响路由的计算。

4.DR OTHER

DR和BDR之外的路由器(称为DR 0ther)之间将不再建立邻接关系，也不再交换任何路由信息。这样就减少了广播网和NBMA网络上各路由器之间邻接关系的数量。

5.DR及BDR选举

1，通过hello 包中的router priority 路由器优先级(即接口的优先级)作比较，高的为DR,次高的为BDR,其它的路由器为DRother.对于cisco路由器中默认优先级都为1,最高为255。如果在DR选举中，路由器的优先级为0时，不参加选举;如果是255，且此区域中没有其它优先级为255的路由器，则永远是DR。

2, 在优先级相同的情况下比较RID,RID高者为DR，次高者为BDR

RID:router id I手工配置2，逻辑地址(loopback 环回地址) IP最高的3， 物理端口IP地址最高的。

3.DR/BDR选举完成后，DROTHER就只和DR/BDR逻辑上形成邻居关系，DROTHER组播链路状态信息LSU到ALLDOTHER地址 224.0.0.6，而只有DRBDR监听该地址。而DR组播泛洪LSU的hello 包到 224.0.0.5, DROTHER监听该地址，以使所有非DR/BDR的OSPF路由器跟踪其它邻居的信息。

============

**共有五种区域的主要区别在于它们和外部路由器间的关系：**

标准区域: 一个标准区域可以接收链路更新信息和路由总结。

主干区域(传递区域):主干区域是连接各个区域的中心实体。主干区域始终是“区域0”，所有其他的区域都要连接到这个区域上交换路由信息。主干区域拥有标准区域的所有性质。

存根区域（stub Area）：存根区域是不接受自治系统以外的路由信息的区域。如果需要自治系统以外的路由，它使用默认路由0.0.0.0。

完全存根区域：它不接受外部自治系统的路由以及自治系统内其他区域的路由总结。需要发送到区域外的报文则使用默认路由：0.0.0.0。完全存根区域是Cisco自己定义的。 

不完全存根区域(NSAA): 它类似于存根区域，但是允许接收以LSA Type 7发送的外部路由信息，并且要把LSA Type 7转换成LSA Type 5。

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ospf.assets/2021.03.09-17:31:02-1592929405878-0b9c18d2-403e-49a9-9cab-ff47476be10b.png)

### OSPF中的四种路由器

在OSPF多区域网络中，路由器可以按不同的需要同时成为以下四种路由器中的几种： 

\1. 内部路由器：所有端口在同一区域的路由器，维护一个链路状态数据库。 

\2. 主干路由器：具有连接主干区域端口的路由器。 

\3. 区域边界路由器(ABR)：具有连接多区域端口的路由器，一般作为一个区域的出口。ABR为每一个所连接的区域建立链路状态数据库，负责将所连接区域的路由摘要信息发送到主干区域，而主干区域上的ABR则负责将这些信息发送到各个区域。 

\4. 自治域系统边界路由器(ASBR)：至少拥有一个连接外部自治域网络（如非OSPF的网络）端口的路由器，负责将非OSPF网络信息传入OSPF网络。

### OSPF链路状态公告类型

OSPF路由器之间交换链路状态公告(LSA)信息。OSPF的LSA中包含连接的接口、使用的Metric及其他变量信息。OSPF路由器收集链接状态信息并使用SPF算法来计算到各节点的最短路径。LSA也有几种不同功能的报文，在这里简单地介绍一下： 

LSA TYPE 1：router LSA由每台路由器为所属的区域产生的LSA，描述本区域路由器链路到该区域的状态和代价。一个边界路由器可能产生多个LSA TYPE1。 

LSA TYPE 2：network LSA由DR产生，含有连接某个区域路由器的所有链路状态和代价信息。只有DR可以监测该信息。 

LSA TYPE 3：summary LSA由ABR产生，含有ABR与本地内部路由器连接信息，可以描述本区域到主干区域的链路信息。它通常汇总缺省路由而不是传送汇总的OSPF信息给其他网络。 

LSA TYPE 4：Summary LSA由ABR产生，由主干区域发送到其他ABR, 含有ASBR的链路信息，与LSA TYPE 3的区别在于TYPE 4描述到OSPF网络的外部路由，而TYPE 3则描述区域内路由。 

LSA TYPE 5：AS External LSA由ASBR产生，含有关于自治域外的链路信息。除了存根区域和完全存根区域，LSA TYPE 5在整个网络中发送。 

LSA TYPE 6：multicast OSPF LSA，MOSF可以让路由器利用链路状态数据库的信息构造用于多播报文的多播发布树。 

LSA TYPE 7：Not-So-Stubby LSA由ASBR产生的关于NSSA的信息。LSA TYPE 7可以转换为LSA TYPE 5。

### 协议类型

Hello报文，通过周期性地发送来发现和维护邻接关系；
DD(链路状态数据库描述)报文，描述本地路由器保存的LSDB(链路状态数据库)；
LSR(LS Request)报文，向邻居请求本地没有的LSA；
LSU(LS Update)报文，向邻居发送其请求或更新的LSA；
LSAck(LS ACK)报文，收到邻居发送的LSA后发送的确认报文。

### OSPF网络类型

根据路由器所连接的物理网络不同，OSPF将网络划分为四种类型：广播多路访问型（Broadcast multiAccess）、非广播多路访问型（None Broadcast MultiAccess，NBMA）、点到点型（Point-to-Point）、点到多点型（Point-to-MultiPoint）。 
广播多路访问型网络如：Ethernet、Token Ring、FDDI。NBMA型网络如：Frame Relay、X.25、SMDS。Point-to-Point型网络如：PPP、HDLC。

### 指派路由器（DR）和备份指派路由器（BDR）

在多路访问网络上可能存在多个路由器，为了避免路由器之间建立完全相邻关系而引起的大量开销，OSPF要求在区域中选举一个DR。每个路由器都与之建立完全相邻关系。DR负责收集所有的链路状态信息，并发布给其他路由器。选举DR的同时也选举出一个BDR，在DR失效的时候，BDR担负起DR的职责。 

点对点型网络不需要DR，因为只存在两个节点，彼此间完全相邻。 协议组成OSPF协议由Hello协议、交换协议、扩散协议组成。本文仅介绍Hello协议，其他两个协议可参考RFC2328中的具体描述。 

当路由器开启一个端口的OSPF路由时，将会从这个端口发出一个Hello报文，以后它也将以一定的间隔周期性地发送Hello报文。OSPF路由器用Hello报文来初始化新的相邻关系以及确认相邻的路由器邻居之间的通信状态。 

对广播型网络和非广播型多路访问网络，路由器使用Hello协议选举出一个DR。在广播型网络里，Hello报文使用多播地址224.0.0.5周期性广播，并通过这个过程自动发现路由器邻居。在NBMA网络中，DR负责向其他路由器逐一发送Hello报文。



==============

- 路由过滤：

OSPF的路由过滤，是针对计算出的路由进行的过滤，并不会对LSA及LSDB产生影响，LSA仍能泛洪。路由的过滤，只会对本路由器的路由表产生影响，不会对其他路由器的路由产生影响。

路由过滤实现方法：

filter-policy *acl* import：只能过滤OSPF路由表里的路由，并不能阻止LSA泛洪；



- LSA过滤：

LSA过滤，是对产生的链路状态的直接过滤，对LSDB产生影响。LSA被过滤后，同时也会对路由产生影响。也就是说，LSA过滤，不仅过滤了LSA，也同时过滤了路由。因为路由是基于LSDB计算出的。

LSA过滤工具：

- filter-policy *acl* export：在ASBR上对ASE、NSSA类的LSA进行过滤，可以对本路由器引入而产生的ASE、NSSA LSA做过滤，过滤彻底。
- asbr-summary *IP* not-advertise：在ASBR上对自己产生的ASE、NSSA做过滤，以及在NSSA区域的ABR上过滤7类转成5类的LSA。
- filter *acl* export：在区域内使用。在ABR上用来过滤summary LSA(LSA3).只能过滤LSA3；
- ospf filter-lsa-out用来配置对OSPF接口出方向的LSA进行过滤

\-------
---

# OSPF学习笔记

**3.OSPF报文**

◆OSPF报文封装在IP报文中，协议号为89。

◆OSPF报文类型有5种：

◆Hello 报文

◆DD（Database Description）报文

◆LSR（Link State Request）报文

◆LSU（Link State Update）报文

◆LSACK（Link State Acknowledgment）报文

**4.邻居状态机**

**9.OSPF支持的网络类型**

缺省情况下，OSPF认为以太网的网络类型是广播类型，PPP、HDLC的网络类型是点到点类型。

缺省情况下，OSPF认为帧中继、 ATM的网络类型是NBMA。

**12.OSPF区域**

每个区域都维护一个独立的LSDB。Area 0是骨干区域，其他区域都必须与此区域相连。