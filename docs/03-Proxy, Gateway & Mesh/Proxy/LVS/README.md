---
title: LVS
---
## LVS 简介
[LVS（Linux Virtual Server）](htts://www.linuxvirtualserver.org/) 是一个由章文嵩博士发起的开源项目，旨在为Linux平台提供高性能的四层负载均衡解决方案。LVS 可通过多种负载均衡算法实现流量分发，包括轮询、最小连接数、权重等。自 Linux 2.4 内核起，LVS的核心功能已经完全内置于内核模块中。

LVS 由两部分组成：
- IPVS（IP Virtual Server）：  
  工作在内核态，负责实现负载均衡功能，IPVS 支持多种负载均衡算法，如轮询、加权轮询、最少连接等。
- ipvsadm：  
  LVS 的用户态命令行工具，可以通过修改内核中 IPVS 的配置来实现负载均衡的调整和维护。

## LVS常用名词概念
| 缩写 | 全称            | 解释                                                             |
| ---- | --------------- | ---------------------------------------------------------------- |
| LB   | Load Balancer   | 负载均衡                                                         |
| HA   | High Available  | 高可用                                                           |
| DS   | Director Server | 指的是前端负载均衡器节点，也就是运行LVS的节点                    |
| RS   | Real Server     | 后端真实的工作服务器                                             |
| VIP  | Virtual IP      | 虚拟的 IP 地址，作为用户请求的目标的IP地址，一般是DS的外部IP地址 |
| DIP  | Director IP     | 主要用于和内部主机通讯的IP地址，一般是DS的内部IP地址             |
| RIP  | Real Server IP  | 后端服务器的 IP 地址                                             |
| CIP  | Client IP       | 访问客户端的 IP 地址                                             |

## lvs工作模式：
LVS的IP负载均衡技术是通过IPVS模块来实现的，它安装在Director Server上，会虚拟出一个VIP。访问的请求首先经过VIP到达负载调度器，然后由负载调度器从Real Server列表中选取一个服务节点响应用户的请求。 

原生只有3种模式(NAT,TUN,DR), Full-NAT和Enhence-NAT 非原生方案。

### NAT 地址转换 
<!-- https://image.z0ukun.com/2019/10/5d3fe70e37520_articlex.png
https://img2018.cnblogs.com/blog/209993/201908/209993-20190823183938579-1292197947.png
https://images2017.cnblogs.com/blog/1218087/201708/1218087-20170812131318304-879594804.png -->

**Virtual Server via Network Address Translation （ VS/NAT ）**

当收到客户端的请求后，**LB会对请求包做目的地址转换（DNAT）**，将请求包的目的IP改写为RS的IP。  
当收到RS的响应后，**LB会对响应包做源地址转换（SNAT）**，将响应包的源IP改写为LB的IP。

**NAT模式的优点：**
- LB会透传客户端IP到RS（DR模式也会透传）  
  　虽然LB在转发过程中做了NAT转换，但是因为只是做了部分地址转发，所以RS收到的请求包里是能看到客户端IP的。

- 支持映射（NAT映射表）
  **LB和RS之间的端口可以不同**，LB会将数据包的目标端口和地址重写为所选RS的地址和端口。

- RIP可以是私网IP，用于LVS与RS之间通讯

**NAT模式的缺点：**
- 一般需要将RS的默认网关地址配置为LB的浮动IP地址  
　　因为RS收到的请求包源IP是客户端的IP，**为了保证响应包在返回时能走到LB上面**，所以一般需要将RS的默认网关地址配置为LB的虚拟服务IP地址，如果客户端地址固定，也可以配置明细路由。
- LB和RS须位于同一个子网，并且客户端不能和LB/RS位于同一子网  
　LVS NAT模式是基于二层转发的，所以需要保证LB和RS位于同一子网。  
  又因为需要保证RS的响应包能走回到LB上，则客户端不能和RS位于同一子网。否则RS直接就能获取到客户端的MAC，响应包就走二层直接回给客户端了，不会走三层经过网关，也就走不到LB上面了。这时候由于没有LB做SNAT，客户端收到的响应包源IP是RS的IP，而客户端的请求包目的IP是LB的虚拟服务IP，这时候客户端无法识别响应包，会直接丢弃。

- 进出流量都需要LVS进行处理，LVS容易成为集群瓶颈


### FULL-NAT
**（Full NetWork Address Translation-全部网络地址转换，双向数据包都进行SNAT与DNAT）**是阿里在多年前的2.6.32版本的内核上开发支持了fullnat，并开源出来，阿里开源的这个该版本不仅支持了fullnat，而且还支持TOA功能，可以把客户端的IP和Port带到RealServer，但是该版本已经停止维护。

FULLNAT模式下，LB会对请求包和响应包都做SNAT+DNAT。LB完全作为一个代理服务器，FULLNAT下，客户端感知不到RS，RS也感知不到客户端，它们都只能看到LB。

<!-- https://images2017.cnblogs.com/blog/1218087/201708/1218087-20170812153421226-1859553413.png -->
**FULL-NAT模式的优点：**
- 不同于NAT和DR要求LB和RS位于一个子网，FULLNAT对于组网结构没有要求。只需要保证客户端和LB、LB和RS之间网络互通即可。

**FULL-NAT模式的缺点：**
- RS看不到cip（NAT模式下可以看到）  
  ps: 一般会将cip放入TCP包的Option中传递给RS，RS上一般部署自己写的toa模块来从Options中读取的cip，这样RS能看到cip了, 当然这不是一个开源的通用方案。参考这个文章: [改造LVS支持TOA](https://www.jianshu.com/p/e770a11481e9)

- 进出流量还是都走的lvs，容易成为瓶颈（跟NAT一样都有这个问题）

Full NAT解决了NAT模式下需要同网段的问题，但是还是没解决进出流量都走LVS的问题（LVS要修改进出的包），下面ENAT模式（Enhence NAT）方案将回包方向的NAT处理放在RS上完成，降低了lvs负担。

### ENAT模式（Enhence NAT）
也是阿里推出的方案
**ENAT –（enhence NAT 或者叫三角模式/DNAT）**

1.client发出请求（cip，vip）；
2.请求包到达lvs，lvs修改请求包为（vip，rip），并将cip放入TCP Option中；
3.请求包根据ip路由到达rs， ctk模块读取TCP Option中的cip；
4.回复包(RIP, vip)被ctk模块截获，并将回复包改写为（vip, cip)；
5.因为回复包的目的地址是cip所以不需要经过lvs，可以直接发给client。

<!-- https://image.z0ukun.com/2019/10/5d3ff10ced07f_articlex.png -->

**ENAT模式的优点：**
- 不要求LVS和RS在同一个vlan
- 出方向流量不需要走LVS，减小对LVS压力
**ENAT模式的缺点：**
- 自定义方案，需要在所有RS上安装ctk组件（类似full NAT中的toa）

### IP-TUN 隧道
**Virtual Server via IP Tunneling （ VS/TUN ）**

<!-- https://resource.tinychen.com/20200422090745.png

https://resource.tinychen.com/20200427092756.png

https://img2018.cnblogs.com/blog/209993/201908/209993-20190823183955817-1520049498.png -->

采用NAT技术时，虽然对于客户端来说整个服务器集群中的LVS负载均衡过程是无感的（因为对于客户端来说请求包发送的目标IP和响应包返回的源IP都没有改变），但是由于请求和响应报文都必须经过LB进行重写，当客户请求越来越多时，LB的处理能力将成为整个集群中的瓶颈。

由于一般数据请求包往往远小于响应数据包的大小。所以LVS（TUN）的思路就是将请求与响应数据分离，LB把请求报文通过IP隧道转发至RS，而RS将响应直接返回给客户端，所以LB只需要处理请求报文。采用 VS/TUN技术后，集群系统的最大吞吐量可以提高 10 倍。


**基本流程：**

1、请求包到达LVS后，LVS将请求包封装成一个新的IP报文；
2、新的IP包的目的IP是某一RS的IP，然后转发给RS；
3、RS收到报文后IPIP内核模块解封装，取出用户的请求报文；
4、发现目的IP是VIP，而自己的tunl0网卡上配置了这个IP，从而愉快地处理请求并将结果直接发送给客户。

**优点：**

- 集群节点可以跨vlan
- 跟DR一样，响应报文直接发给client
- 需要LB和RS上面的服务使用的端口必须保持一致，因此在添加配置规则的时候无需指定RS的端口。

**缺点**：

- RS上必须安装运行IPIP模块
- 多增加了一个IP头
- LVS和RS上的tunl0虚拟网卡上配置同一个VIP（类似DR）

### DR 直接路由
https://image.z0ukun.com/2019/10/d3fe0ea4e76e_articlex.png
https://resource.tinychen.com/20200422090907.png

https://img2018.cnblogs.com/blog/209993/201908/209993-20190823184010254-1390634692.png
https://images2017.cnblogs.com/blog/1218087/201708/1218087-20170812112314226-276970386.png
**Virtual Server via Direct Routing （ VS/DR ）**

VS/DR通过改写请求报文的MAC地址，将请求发送到RS，而RS将响应直接返回给客户。这种方法没有IP隧道的开销，对集群中的RS也没有必须支持IP隧道协议的要求，但是因为使用的是MAC地址进行二层转发，所以要求LB和RS都有一块网卡连在同一物理网段上。

与隧道模式不同的是，直接路由模式（DR模式）要求调度器与后端服务器必须在同一个局域网内，VIP地址需要在调度器与后端所有的服务器间共享，因为最终的真实服务器给客户端回应数据包时需要设置源IP为VIP地址，目标IP为客户端IP，这样客户端访问的是调度器的VIP地址，回应的源地址也依然是该VIP地址（真实服务器上的VIP），客户端是感觉不到后端服务器存在的。由于多台计算机都设置了同样一个VIP地址，所以在直接路由模式中要求调度器的VIP地址是对外可见的，客户端需要将请求数据包发送到调度器主机，而所有的真实服务器的VIP地址必须配置在Non-ARP的网络设备上，也就是该网络设备并不会向外广播自己的MAC及对应的IP地址，真实服务器的VIP对外界是不可见的，但真实服务器却可以接受目标地址VIP的网络请求，并在回应数据包时将源地址设置为该VIP地址。调度器根据算法在选出真实服务器后，在不修改数据报文的情况下，将数据帧的MAC地址修改为选出的真实服务器的MAC地址，通过交换机将该数据帧发给真实服务器。整个过程中，真实服务器的VIP不需要对外界可见。


客户端的请求包到达负载均衡器的虚拟服务IP端口后，负载均衡器不会改写请求包的IP和端口，但是会改写请求包的MAC地址为后端RS的MAC地址，然后将数据包转发；真实服务器处理请求后，响应包直接回给客户端，不再经过负载均衡器。所以DR模式的转发效率是最高的

这种方法没有 IP 隧道的开销，对集群中的真实服务器也没有必须支持 IP 隧道协议的要求，但是要求调度器与真实服务器都有一块网卡连 在同一物理网段上。


**DR模式的特点：**
    数据包在LB转发过程中，源/目的IP端口都不会变化，LB只是将数据包的MAC地址改写为RS的MAC地址，然后转发给相应的RS。
    每台RS上都必须在环回网卡上绑定LB的虚拟服务IP
    RS处理完请求后，响应直接回给客户端，不再经过LB
    LB和RS须位于同一个子网（）否则LB只能获取到RS网关的MAC地址。

  我的理解：
  三台RS 配置相同三层ip 但mac作为二层地址是不认同的
  客户端访问lb的vip，ipvs处理数据，修改目的mac，将数据通过二层发往对应rs，rs配置有相同的vip所以数据包会被接收，同时保证服务监听在此ip的端口上，此时服务发送响应，由于没改变源地址（客户端地址）所以响应信息会走路由到达客户端，不经过lb处理。
由于RS的本地lo接口上面绑定了VIP，且这时MAC地址是RS自身的MAC地址，所以RS接收到数据包后会处理请求，然后将响应数据包直接发送到客户端
由于LB只是简单地对数据包的MAC地址更改为RS的MAC地址并且将其重新发送到局域网中，所以要求LB和RS必须要在同一个局域网中，这样才能直接利用MAC来进行二层传输。

优点：

DR模型下，LVS只需对请求的数据包进行处理，回包绕过LVS直接发给Client，大大降低了LVS的压力（请求包远少于数据包，并且只改二层mac信息）。

缺点：
注意DR模式也同样不支持指定RS的服务端口，因此LB和RS的端口也必须保持一致。
LVS和RS必须在一个VLAN中（修改mac后数据包只在二层网络中路由）；
RS需将VIP绑在lo，并对ARP进行特殊配置。
## 6、ARP in LVS

细心观察上面的DR模式，我们会发现：

LB把数据包发送给RS的时候只修改了MAC，尽管在交换机上会根据MAC直接把包发送给RS，但是RS在接受到数据包之后还是会检查数据包的目的IP和端口，此时数据包的目的IP依旧是VIP。所以这就是为什么需要在RS的网卡上面也绑定VIP的原因。（一般绑定在loopback接口）

那么当LB和RS都绑定了VIP的时候，问题又来了：

当客户端的请求数据包传到LVS集群所在的网关的时候，它是不知道LB的MAC地址的，因此需要通过ARP协议来进行查询，也就是在局域网中发送ARP请求，看谁会响应，响应的就是要发送的MAC地址。而这个时候，由于DR模式下的LB和RS都在同一个局域网中且都绑定了VIP，那么它们就都会响应这个ARP请求。这样一来客户端的数据包就不一定会发送到LB上面，也就不一定会触发整个负载均衡效果。

因此这种情况下一般都会对RS上面的网卡接口的ARP请求设置进行修改：
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

我们看一下kernel的文档中对这两个参数的相关描述

arp_ignore的意义

arp_ignore - INTEGER

Define different modes for sending replies in response to received ARP requests that resolve local target IP addresses:

0 - (default): reply for any local target IP address, configured on any interface

1 - reply only if the target IP address is local address configured on the incoming interface

2 - reply only if the target IP address is local address configured on the incoming interface and both with the sender’s IP address are part from same subnet on this interface

3 - do not reply for local addresses configured with scope host, only resolutions for global and link addresses are replied

4-7 - reserved

8 - do not reply for all local addresses The max value from conf/{all,interface}/arp_ignore is used when ARP request is received on the {interface}

arp_ignore设置为0时，无论收到的ARP请求的IP是否是eth上面的IP，只要在宿主机上有网卡有对应的IP，就会发送ARP应答。

arp_ignore设置为1即意味着对应的网卡在收到了目标IP不是自己的网卡的IP的数据包的ARP请求时不会进行回应，而在DR模式中，对应的VIP是绑定在lo接口上的，而lo接口并不是物理网卡，实际上数据包都是从物理网卡eth上进来，因此这时就不会对目标IP是VIP的数据包进行ARP回应。使得访问能够顺利地到达LB上面，再从LB上面进行负载均衡。

arp_annouce的意义

arp_announce - INTEGER

Define different restriction levels for announcing the local source IP address from IP packets in ARP requests sent on interface:

0 - (default) Use any local address, configured on any interface
1 - Try to avoid local addresses that are not in the target’s subnet for this interface. This mode is useful when target hosts reachable via this interface require the source IP address in ARP requests to be part of their logical network configured on the receiving interface. When we generate the request we will check all our subnets that include the target IP and will preserve the source address if it is from such subnet. If there is no such subnet we select source address according to the rules for level 2.
2 - Always use the best local address for this target. In this mode we ignore the source address in the IP packet and try to select local address that we prefer for talks with the target host. Such local address is selected by looking for primary IP addresses on all our subnets on the outgoing interface that include the target IP address. If no suitable local address is found we select the first local address we have on the outgoing interface or on all other interfaces, with the hope we will receive reply for our request and even sometimes no matter the source IP address we announce. The max value from conf/{all,interface}/arp_announce is used.
每个机器或者交换机中都有一张ARP表，ARP表的作用就是用于记录IP地址和MAC地址的对应关系。当收到一个ARP表中没有记录的IP地址的ARP请求，就会在本机的ARP表中新增对应的IP和MAC记录；当收到一个已知IP地址（arp表中已有记录的地址）的arp请求，则会根据arp请求中的源MAC刷新自己的arp表。

如果arp_announce参数配置为0，则网卡在发送arp请求时，可能选择的源IP地址并不是该网卡自身的IP地址，这时候收到该arp请求的其他节点或者交换机上的arp表中记录的该网卡IP和MAC的对应关系就不正确。

所以DR模式下要求arp_announce参数要求配置为2。

在这个模式下会忽略IP数据包中的源地址并且尝试选择能与目标地址主机通信的本机地址
首先就是查找本机所有的出口网卡上的IP地址所属的子网里面包含了目标的IP地址的IP
如果没有上述的合适的IP地址，那么就会选择出口网卡的第一个IP地址或者是在所有的网卡中最有可能能够接收到请求的IP地址
由于在DR模式中RS和LB的物理网卡是处于同一个局域网中的，所以会直接解析到对应的物理网卡的MAC地址。


## 工作模式总结

三种转发模式性能从高到低：DR > IP-TUN > NAT > FULLNAT。
　　虽然FULLNAT模式的性能比不上DR和NAT，但是FULLNAT模式没有组网要求，允许LB和RS部署在不同的子网中，这给运维带来了便利。并且 FULLNAT模式具有更好的可拓展性，可以通过增加更多的LB节点，提升系统整体的负载均衡能力。
https://images2017.cnblogs.com/blog/1218087/201708/1218087-20170812153457726-2027699454.png
|                | VS/NAT        | VS/TUN     | VS/DR          |
| -------------- | ------------- | ---------- | -------------- |
| server         | any           | tunneling  | non-arp device |
| server network | private       | LAN/WAN    | LAN            |
| server number  | low (10~20)   | high       | high           |
| server gateway | load balancer | own router | own router     |


| 模式与特点       | NAT 模式                                  | IPIP 模式                                                                        | DR 模式                                                               |
| ---------------- | ----------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| 对服务器的要求   | 服务节点可以使任何操作系统                | 必须支持 IP 隧道，目前只有 Linux 系统支持                                        | 服务器节点支持虚拟网卡设备，能够禁用设备的 ARP 响应                   |
| 网络要求         | 拥有私有 IP 地址的局域网络                | 拥有合法 IP 地址的局域，网或广域网                                               | 拥有合法 IP 地址的局域，服务器节点与负载均衡器必须在同一个网段        |
| 通常支持节点数量 | 10 到 20 个，根据负载均衡器的处理能力而定 | 较高，可以支持 100 个服务节点                                                    | 较高，可以支持 100 个服务节点                                         |
| 网关             | 负载均衡器为服务器节点网关                | 服务器的节点同自己的网关或者路由器连接，不经过负载均衡器                         | 服务节点同自己的网关或者路由器连接，不经过负载均衡器                  |
| 服务节点安全性   | 较好，采用内部 IP，服务节点隐蔽           | 较差，采用公用 IP 地址，节点安全暴露                                             | 较差，采用公用 IP 地址，节点安全暴露                                  |
| IP 要求          | 仅需要一个合法的 IP 地址作为 VIP 地址     | 除了 VIPO 地址外，每个服务器界定啊需要拥有合法的 IP 地址，可以直接从路由到客户端 | 除了 VIP 外，每个服务节点需拥有合法的 IP 地址，可以直接从路由到客户端 |
| 特点             | 地址转换                                  | 封装 IP                                                                          | 修改 MAC 地址                                                         |
| 配置复杂度       | 简单                                      | 复杂                                                                             | 复杂                                                                  |

:::info 什么是 NAT
net 类型和穿透
:::



## IPVS支持的调度算法

LB 根据负载均衡调度算法将流量调度到后端的RS集群。IPVS 常用的调度算法有：

- 轮询（Round Robin,RR）  
    将收到的访问请求按顺序轮流分配给群集中的各节点真实服务器中，不管服务器实际的连接数和系统负载。

- 加权轮询（Weighted Round Robin,WRR）  
　  LB会根据RS上配置的权重，将消息按权重比分发到不同的RS上。可以给性能更好的RS节点配置更高的权重，提升集群整体的性能。

- 最小连接数（Least Connections,LC）  
　   LB会根据和集群内每台RS的连接数统计情况，将消息调度到连接数最少的RS节点上。

    在长连接业务场景下，LC算法对于系统整体负载均衡的情况较好；但是在短连接业务场景下，由于连接会迅速释放，可能会导致消息每次都调度到同一个RS节点，造成严重的负载不均衡。
  
- 加权最小连接数（Weighted Least Connections,WLC）
    服务器节点的性能差异较大的情况下，可以为真实服务器自动调整权重，权重较高的节点将承担更大的活动连接负载。

- 基于局部性的最少链接（Locality-Based Least Connections,LBLC）  
    针对目标IP地址的负载均衡，目前主要用于Cache集群系统。该算法根据请求的目标IP地址找出该目标IP地址最近使用的服务器，若该服务器 是可用的且没有超载，将请求发送到该服务器；若服务器不存在，或者该服务器超载且有服务器处于一半的工作负载，则用"最少链接"的原则选出一个可用的服务 器，将请求发送到该服务器。

- 带复制的基于局部性最少链接（Locality-Based Least Connections with Replication,LBLCR）
    也是针对目标IP地址的负载均衡，目前主要用于Cache集群系统。它与LBLC算法的不同之处是它要维护从一个 目标IP地址到一组服务器的映射，而LBLC算法维护从一个目标IP地址到一台服务器的映射。该算法根据请求的目标IP地址找出该目标IP地址对应的服务 器组，按"最小连接"原则从服务器组中选出一台服务器，若服务器没有超载，将请求发送到该服务器，若服务器超载；则按"最小连接"原则从这个集群中选出一 台服务器，将该服务器加入到服务器组中，将请求发送到该服务器。同时，当该服务器组有一段时间没有被修改，将最忙的服务器从服务器组中删除，以降低复制的程度。

- 目标地址散列（Destination Hashing,DH）
  该算法是根据目标 IP 地址通过散列函数将目标 IP 与服务器建立映射关系，出现服务器不可用或负载过高的情况下，发往该目标 IP 的请求会固定发给该服务器。

- 源地址散列（Source Hashing,SH）
  与目标地址散列调度算法类似，但它是根据源地址散列算法进行静态分配固定的服务器资源。

参考文档
- https://wsgzao.github.io/post/lvs-keepalived/
- https://juejin.cn/post/6966411996589719583
- http://www.linuxvirtualserver.org/zh/lvs1.html
- http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html
- https://www.alibabacloud.com/blog/load-balancing---linux-virtual-server-lvs-and-its-forwarding-modes_595724
更多文章
https://github.com/lxcong/lvs-manager
https://xie.infoq.cn/article/89e58c81cd2b1f13a5a847445

