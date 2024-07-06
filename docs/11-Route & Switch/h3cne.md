---
toc: true
title: h3cne
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
---

dis cu | p  ospf

ping / tracert
添加注释信息“waiwang chu kou” 
description waiwang chu kou 
5、配置交换机网关地址 
[H3C]ip route-static 0.0.0.0 0.0.0.0 192.168.0.1 
7、配置SNMP 
[H3C]snmp-agent
[H3C]snmp-agent community read 123456  #设置snmp团体名称 ，权限为只读 
[H3C]snmp-agent sys-info version v1 v2c  #设置snmp版本v1 和v2 
8、Qos端口限速 
[H3C] interface gigabitethernet 1/0/1
配置限速参数，端口进/出速率限制为5120kbps。
 [H3C-GigabitEthernet1/0/1] qos lr inbound cir 5120
[H3C-GigabitEthernet1/0/1] qos lr outbound cir 5120 
12、查看端口状态 
[H3C]display interface GigabitEthernet 1/0/24 
16、查看MAC地址列表
 [H3C]display mac-address 
17、查看arp信息
 [H3C]display arp 
==交换机==

## vlan

```
vlan ID
name XX
int vlan ID
ip address IP MASK
port g1/0/1
批量添加
port GigabitEthernet 1/0/1 to GigabitEthernet 1/0/10

int g1/0/2 
port  link-type trunk
port access vlan ID
port trunk permit vlan all

设置trunk/hybrid口省缺vlan
port trunk/hybrid pvid vlan ID

show vlan brief
show vlan ID
```

## STP

*默认优先级都为32768，4096的倍数，小的为根桥。*
*修改SW4的优先级为4096*

```
[SW4]stp priority 4096
```

*H3C交换机千兆口的cost默认是20*
*修改stp cost为1000*

```
[SW2]interface g1/0/2
[SW2-GigabitEthernet1/0/2]stp cost 1000
```

*优先级相同Mac地址应该是最小的，会成为根网桥*

```
[SW1]display stp
-------[CIST Global Info][Mode MSTP]-------
Bridge ID           : 32768.7aef-e4ea-0100
Bridge times        : Hello 2s MaxAge 20s FwdDelay 15s MaxHops 20
Root ID/ERPC        : 32768.7aef-e4ea-0100, 0
RegRoot ID/IRPC     : 32768.7aef-e4ea-0100, 0
RootPort ID         : 0.0
BPDU-Protection     : Disabled
Bridge Config-
Digest-Snooping     : Disabled
TC or TCN received  : 7
Time since last TC  : 0 days 0h:0m:40s
```

*根据STP计算机制，所有链路开销一致，在**SW4**上查看端口状态，确认SW4的g1/0/2被闭塞*

```
[SW4]display stp brief 
MST ID   Port                                Role  STP State   Protection
0        GigabitEthernet1/0/1                ROOT  FORWARDING  NONE
0        GigabitEthernet1/0/2                ALTE  DISCARDING  NONE
```

把SW1连接PC的所有接口配置为边缘接口

```
[SW4]interface g1/0/3
[SW4-GigabitEthernet1/0/3]stp edged-port
```

## 安全

**在SW1上开启802.1X身份验证**

　　*分析：开启802.1X验证需要首先在系统视图下开启全局`802.1X`，再到接口视图下开启·`802.1X`*

*步骤1：在SW1的系统视图下开启全局`802.1X`*

```
[SW1]dot1x
```

*步骤2：分别在连接PC的接口上开启802.1X*

```
[SW1]interface g1/0/1
[SW1-GigabitEthernet1/0/1]dot1x
```

**创建一个用户身份验证的用户。用户名为`wangdaye`，密码为`123456`**

　　*分析：用于802.1X验证的用户类型必须是`network`，且服务类型为`lan-access`，否则将无法用于802.1X验证。用于身份验证的用户无需配置身份权限*

```
[SW1]local-user wangdaye class network 
New local user added.
[SW1-luser-network-wangdaye]password simple 123456
[SW1-luser-network-wangdaye]service-type lan-access
```

*分析：端口隔离组用于同vlan内部的端口隔离，属于同一个隔离组的接口无法互相访问，不同隔离组的接口才可以互相访问，所以需要把SW1的三个接口都加入到同一个隔离组*
*步骤1：在SW1上创建编号为`1`号的隔离组*

```
[SW1]port-isolate group 1
```

*步骤2：把g1/0/1、g1/0/2、g1/0/3接口都加入到该隔离组*

```
[SW1]interface g1/0/1
[SW1-GigabitEthernet1/0/1]port-isolate enable group 1
```

## 链路聚合

**在SW1和SW2的直连链路上配置链路聚合**
　　*分析：SW1和SW2之间通过g1/0/1和g1/0/2接口直连，需要在两台交换机上分别创建聚合接口，并把g1/0/1和g1/0/2接口加入到聚合接口，形成链路聚合。被聚合的物理接口的vlan配置和接口类型要保持一致，所以在配置链路聚合前，物理端口不要做任何其他配置，保持默认状态即可*
*步骤1：在SW1上创建`Bridge-Aggregation 1`号聚合接口*

```
[SW1]interface Bridge-Aggregation 1
```

*步骤2：进入g1/0/1和g1/0/2接口的接口视图，分别把两个接口加入到聚合接口*

```
[SW1]interface g1/0/1
[SW1-GigabitEthernet1/0/1]port link-aggregation group 1
[SW1]interface g1/0/2
[SW1-GigabitEthernet1/0/2]port link-aggregation group 1
```

*步骤3：查看链路聚合状态，发现已经成功运行*

```
[SW1]display link-aggregation verbose
  ……
  Port             Status  Priority Oper-Key
GE1/0/1          S       32768    1         
GE1/0/2          S       32768    1
```

*进入聚合接口，配置为动态模式*

```
[SW1]interface Bridge-Aggregation 1
[SW1-Bridge-Aggregation1]link-aggregation mode dynamic 
```

**要求 SW1 和 SW2 之间的最大传输带宽为 2G**

　　*分析：SW1 和 SW2 之间的链路聚合为 3 个千兆口组成，最大传输带宽有 3G，这里要求最大为 2G，也就是同时只允许选中 2 个聚合成员端口*
　　
*步骤 1：在 SW1 和 SW2 的聚合接口中，配置最大可用端口为 2 个*

```
[SW1-Bridge-Aggregation1]link-aggregation selected-port maximum 2   
[SW2-Bridge-Aggregation1]link-aggregation selected-port maximum 2
```

*效果测试：在 SW1 和 SW2 上查看链路聚合信息，发现被 G1/0/1 和 G1/0/2 口被选中，G1/0/3 未选中*

```scala
[SW1]dis link-aggregation verbose 

Port                Status  Priority Oper-Key  Flag
    --------------------------------------------------------------------------------
GE1/0/1             S       32768    1         {ACDEF}
GE1/0/2             S       32768    1         {ACDEF}
GE1/0/3             U       32768    1         {ACD}
```

*手动关闭 G1/0/1 口，链路聚合自动开启 G1/0/3 口*

```
[SW1-GigabitEthernet1/0/1]shutdown 
[SW1]display link-aggregation verbose 

Port                Status  Priority Oper-Key  Flag
    --------------------------------------------------------------------------------
GE1/0/1             U       32768    1         {AC}
GE1/0/2             S       32768    1         {ACDEF}
GE1/0/3             S       32768    1         {ACDEF}
```

**SW1和SW2之间的直连链路要配置为Trunk类型，允许所有vlan通过**

　　*分析：物理接口加入到聚合接口后，会自动继承聚合接口的vlan相关配置，所以不需要在物理接口上分别配置Trunk，只需要在聚合接口下配置Trunk即可*

*步骤1：在SW1的`Bridge-Aggregation 1`接口的接口视图下，把该聚合接口配置为Trunk，并允许所有vlan通过。命令执行完毕后，会显示配置已经在g1/0/1和g1/0/2接口上自动完成*

```
[SW1]interface Bridge-Aggregation 1
[SW1-Bridge-Aggregation1]port link-type trunk
Configuring GigabitEthernet1/0/1 done.
Configuring GigabitEthernet1/0/2 done.
[SW1-Bridge-Aggregation1]port trunk permit vlan all
Configuring GigabitEthernet1/0/1 done.
Configuring GigabitEthernet1/0/2 done.
```

中断SW1和SW2之间的一条直连链路，测试PC3和PC4是否仍然能够继续访问
　　*分析：链路聚合会自动把SW1和SW2之间的流量进行负载均衡，某一条链路中断连接后，也仍然还有另外一条链路可以继续通讯，所以PC3和PC4可以继续访问*
*步骤1：进入SW1的g1/0/1接口的接口视图，使用`shutdown`命令关闭接口*

```
[SW1]interface g1/0/1
[SW1-GigabitEthernet1/0/1]shutdown
```

## DHCP

**配置R1为DHCP服务器，能够跨网段为`192.168.2.0/24`网段自动分配IP地址**

　　*分析：默认情况下，DHCP只能为和本机处于同一网段的客户端分配IP地址。现在要求跨网段分配IP地址，就需要配置DHCP中继来实现
　　在R1上创建的地址池必须要宣告`192.168.2.0/24`网段。DHCP分配的网关地址应该是`192.168.2.0/24`网段的真实网关，根据拓扑得知，网关就是R2的g0/1接口，IP地址为`192.168.2.254`
　　DHCP的IP地址请求和应答报文都是广播形式发送，默认情况下，是无法穿越路由器的，所以需要在R2上开启DHCP中继功能，使DHCP报文能够跨网段转发
　　另外，`192.168.2.0/24`网段对R1来说，是非直连网段，要使R1和PC3连通，R1上必须具有到达`192.168.2.0/24`网段的路由信息*

*步骤1：在R1上开启DHCP功能，并创建`1`号DHCP地址池，宣告网段`192.168.2.0/24`，网关为`192.168.2.254`，DNS为`202.103.24.68`和`202.103.0.117`*

```
[R1]dhcp enable
[R1]dhcp server ip-pool 1
[R1-dhcp-pool-1]network 192.168.2.0 mask 255.255.255.0
[R1-dhcp-pool-1]gateway-list 192.168.2.254
[R1-dhcp-pool-1]dns-list 202.103.24.68 202.103.0.117
```

*步骤2:在R2上开启DHCP功能，并在连接客户端的接口（g0/1）上开启DHCP中继功能，并指定DHCP服务器的IP地址*

```
[R2]dhcp enable
[R2]interface g0/1
[R2-GigabitEthernet0/1]dhcp select relay
[R2-GigabitEthernet0/1]dhcp relay server-address 192.168.1.1
```

*步骤3：在R1上配置默认路由，使R1的DHCP协议报文能够到达PC3*

```
[R1]ip route-static 0.0.0.0 0 192.168.1.2
```

*分析：被配置为排除的IP地址段，DHCP服务器将不会进行分配。配置排除的命令需要退出到系统视图配置*

*步骤1：配置IP地址排除段，为`192.168.1.10-192.168.1.20`*

```
[R1]dhcp server forbidden-ip 192.168.1.10 192.168.1.20
```

## 单臂路由

```
[R1]interface g0/0.1
[R1-GigabitEthernet0/0.1]vlan-type dot1q vid 10
[R1-GigabitEthernet0/0.1]ip address 192.168.1.254 24
```

## 三层交换机

```
[SW1]interface Vlan-interface 10
[SW1-Vlan-interface10]ip address 192.168.1.254 24
```

进入接口
开启该接口的三层路由功能
port link-mode route
关闭该接口的三层路由功能
daoport link-mode bridge
ip add
ip route-static 192.168.40.0 255.255.255.0 192.168.1.2
ip route prefix mask {address| interfacce}  [distance] [tag tag] [permanent]

Prefix :所要到达的目的网络
mask  :子网掩码
address :下一个跳的IP地址，即相邻路由器的端口地址。
interface  :本地网络接口
distance :管理距离（可选）
tag tag :tag值（可选）
permanent :指定此路由即使该端口关掉也不被移掉

## 静态路由

```
[R1]ip route-static 192.168.2.0 24 10.2.2.2
```

## RIP

*分析：实现全网互通，意味着每台路由器都要宣告本地的所有直连网段。RIP 只能做主类宣告，以 R1 为例，连接的两个业务网段属于同一个 B 类主类网段划分出的子网，所以只用宣告一次；而且为了不造成路由环路，需要开启 RIP v2 版本，以支持 VLSM；R3 同理*

*步骤 1：在 R1，R2，R3 上分别配置 RIP v2，关闭自动聚合，并宣告所有直连网段*

```
[R1]rip 1
[R1-rip-1]version 2
[R1-rip-1]undo summary
[R1-rip-1]network 172.16.0.0
[R1-rip-1]network 192.168.1.0
```

 *分析：上一步中的 RIP 已经配置完成，但路由器学习到的都是各网段的明细路由。在网络结构庞大的拓扑中，明细路由太多会导致路由器查表效率降低，所以需要配置路由聚合来减少路由数量
　RIP 的聚合方式分为自动聚合和手动聚合。自动聚合是聚合为主类网段，在本拓扑中会造成路由环路，所以只能使用手动聚合*

```
[R1-GigabitEthernet0/0]rip summary-address 172.16.0.0 23
```

```
[R2]display ip routing-table 

Destinations : 20       Routes : 20

Destination/Mask   Proto   Pre Cost        NextHop         Interface
……
172.16.0.0/23      RIP     100 1           192.168.1.1     GE0/0
172.16.2.0/23      RIP     100 1           192.168.2.3     GE0/1
```

**业务网段不允许出现协议报文**

*配置*静默接口*

**这是加粗的文字**
*这是倾斜的文字*
***这是斜体加粗的文字***
~~这是加删除线的文字~~

```
[R1-rip-1]silent-interface g0/1
```

**R1 和 R2 之间需要开启接口身份验证来保证协议安全性，密钥为 `runtime`**

*步骤 1：在 R1 的 g0/0 接口配置接口验证，密钥 `runtime`*

```
[R1-GigabitEthernet0/0]rip authentication-mode simple plain runtime
```

*步骤 2：在 R2 的 g0/0 接口配置接口验证，密钥必须和 R1 一致*

```
[R2-GigabitEthernet0/0]rip authentication-mode simple plain runtime
```

　　*说明：通过重置 RIP 进程观察是否能够学习到路由来判断接口验证是否通过*

## OSPF

　　*分析：实现全网互通，意味着每台路由器都要宣告本地的所有直连网段，包括环回口所在的网段。要求 ABR 的环回口宣告进骨干区域，即区域 0，
　　同时，每台路由器手动配置各自环回口的 IP 地址作为 Router-id*

*步骤 1：在路由器上分别配置 OSPF，按区域宣告所有直连网段和环回口*

```
[R1]ospf 1 router-id 1.1.1.1
[R1-ospf-1]area 0
[R1-ospf-1-area-0.0.0.0]network 1.1.1.1 0.0.0.0
[R1-ospf-1-area-0.0.0.0]network 100.1.1.0 0.0.0.255
[R1-ospf-1-area-0.0.0.0]area 1
[R1-ospf-1-area-0.0.0.1]network 100.3.3.0 0.0.0.255
```

**检查是否全网互通**

　　*分析：检查 OSPF 是否全网互通，一个是检查邻居关系表，看邻居关系是否正常；另一个是检查路由表，看是否学习到全网路由
　　这里只展示 R1 的检查结果*

*步骤 1：检查 R1 的邻居关系表*

```
[R1]display ospf peer 

     OSPF Process 1 with Router ID 1.1.1.1
           Neighbor Brief Information

 Area: 0.0.0.0        
 Router ID       Address         Pri Dead-Time  State             Interface
 2.2.2.2         100.1.1.2       1   36         Full/BDR          GE0/0

 Area: 0.0.0.1        
 Router ID       Address         Pri Dead-Time  State             Interface
 4.4.4.4         100.3.3.4       1   36         Full/DR           GE0/1
```

　　*说明：可以看到，R1 分别和 R2 和 R4 建立了邻接关系，状态为 FULL，邻居关系正常*

*步骤 2：检查 R1 的路由表*

```
 [R1]display ip routing-table 

Destination/Mask   Proto   Pre Cost        NextHop         Interface
1.1.1.1/32         Direct  0   0           127.0.0.1       InLoop0
2.2.2.2/32         O_INTRA 10  1           100.1.1.2       GE0/0
3.3.3.3/32         O_INTRA 10  2           100.1.1.2       GE0/0
4.4.4.4/32         O_INTRA 10  1           100.3.3.4       GE0/1
5.5.5.5/32         O_INTER 10  3           100.1.1.2       GE0/0
100.1.1.0/24       Direct  0   0           100.1.1.1       GE0/0
100.1.1.0/32       Direct  0   0           100.1.1.1       GE0/0
100.1.1.1/32       Direct  0   0           127.0.0.1       InLoop0
100.1.1.255/32     Direct  0   0           100.1.1.1       GE0/0
100.2.2.0/24       O_INTRA 10  2           100.1.1.2       GE0/0
100.3.3.0/24       Direct  0   0           100.3.3.1       GE0/1
100.3.3.0/32       Direct  0   0           100.3.3.1       GE0/1
100.3.3.1/32       Direct  0   0           127.0.0.1       InLoop0
100.3.3.255/32     Direct  0   0           100.3.3.1       GE0/1
100.4.4.0/24       O_INTER 10  3           100.1.1.2       GE0/0
```

　　*说明：可以看到，R1 已经学习到了全网所有网段的路由信息*

## ACL

*步骤 1：创建基本 ACL，使 `192.168.1.0/24` 网段不能访问 `192.168.2.0/24` 网段，并在 R2 的 g0/2 接口的出方向配置包过滤*

```
[R2]acl basic 2000
[R2-acl-ipv4-basic-2000]rule deny source 192.168.1.0 0.0.0.255
[R2]interface g0/2
[R2-GigabitEthernet0/2]packet-filter 2000 outbound 
```

*步骤 2：创建高级 ACL，使 PC1 可以访问 SERVER1 的 TELNET 服务，但不能访问 FTP 服务；PC2 可以访问 SERVER1 的 FTP 服务，但不能访问 TELNET 服务，并在 R1 的 g0/1 接口的入方向配置包过滤*

```
[R1]acl advanced 3000
[R1-acl-ipv4-adv-3000]rule deny tcp source 192.168.1.1 0 destination 192.168.3.1 0 destination-port range 20 21
[R1-acl-ipv4-adv-3000]rule deny tcp source 192.168.1.2 0 destination 192.168.3.1 0 destination-port eq 23
[R1]interface g0/1
[R1-GigabitEthernet0/1]packet-filter 3000 inbound
```

*步骤 3：创建高级 ACL，使PC3 不能访问 SERVER1，并在 R2 的 g0/2 接口的入方向配置包过滤*

```
[R2]acl advanced 3000
[R2-acl-ipv4-adv-3000]rule deny ip source 192.168.2.0 0.0.0.255 destination 192.168.3.1 0
[R2]interface g0/2
[R2-GigabitEthernet0/2]packet-filter 3000 inbound 
```

## NET

**私网 A 通过 NAPT 使 Vlan10 和 Vlan20 都能够使用 R1 的公网地址访问互联网**

*步骤 1：R1 上创建基本 ACL，允许 `192.168.1.0/24` 和 `192.168.2.0/24` 网段*

```
[R1]acl basic 2000
[R1-acl-ipv4-basic-2000]rule permit source 192.168.1.0 0.0.0.255
[R1-acl-ipv4-basic-2000]rule permit source 192.168.2.0 0.0.0.255
```

*步骤 2：R1 上创建 NAT 地址池，设置公网地址*

```
[R1]nat address-group 1
[R1-address-group-1]address 100.1.1.1 100.1.1.1
```

*步骤 3：在 R1 的公网接口上配置 NAPT*

```
[R1]interface g0/1
[R1-GigabitEthernet0/1]nat outbound 2000 address-group 1 
```

**私网 B 通过在 R3 上配置 EASY IP 访问互联网**

　　*分析：根据需求得知，ACL 需要配置允许 `192.168.1.0/24` 网段；使用 EASY IP，就无需配置 NAT 地址池，直接在公网接口上配置即可，EASY IP 会自动识别公网接口的 IP 地址*

*步骤 1：R3 上创建基本 ACL，允许 `192.168.1.0/24` 网段*

```
[R3]acl basic 2000
[R3-acl-ipv4-basic-2000]rule permit source 192.168.1.0 0.0.0.255
```

*步骤 2：在 R3 的公网接口上配置 EASY IP*

```
[R3]interface g0/0
[R3-GigabitEthernet0/1]nat outbound 2000
```

**私网 A 配置 NAT SERVER 把 FTPA 的 FTP 服务发布到公网，使 PCB 可以访问**

　　*分析：根据需求得知，需要发布 FTPA 的 FTP 服务，也就是把 R1 的公网地址的 20 和 21 端口映射到 FTPA 的私网地址
　　配置 FTP 服务步骤略*
　　
*步骤 1：在 R1 的公网接口上配置 NAT SERVER，映射端口 20 和 21*

```
[R1-GigabitEthernet0/1]nat server protocol tcp global current-interface 20 21 inside 192.168.1.10 20 21
```

## PPP

配置 PPP MP**

*步骤 1：在 R2 上创建 MP-GROUP 口*

```
[R2]int MP-group 1
```

*步骤 2：把 S1/0 和 S2/0 加入到上一步创建的 MP-GROUP口*

```
[R2]interface s1/0
[R2-Serial1/0]ppp mp MP-group 1
[R2]interface s2/0
[R2-Serial2/0]ppp mp MP-group 1
```

*分析：如果 PPP 链路上配置了 PPP-MP，那么链路的 IP 地址就必须配置在 MP-GROUP 口上，而不是物理口上*
*步骤 3：*MP-GROUP 口上配置 IP 地址*

```
[R2]interface MP-group 1
[R2-MP-group1]ip address 192.168.2.2 24
```

**R2 对 R1 的 PPP 进行单向 chap 验证**

　　*分析：R2 对 R1 进行单向验证，表示 R2 是主验证方，R1 是被验证方。所以需要在 R2 上创建用于验证的用户*

*步骤 1：在 R2 上创建用于验证 R1 的用户*

```
[R2]local-user user1 class network 
 New local user added.
[R2-luser-network-user1]password simple 123
[R2-luser-network-user1]service-type ppp
```

*步骤 2：在 R2 连接 R1 的接口上配置需要进行 PPP 验证，验证方式为 chap*

```
[R2-Serial3/0]ppp authentication-mode chap  
```

*步骤 3：在 R1 连接 R2 的接口上配置用于验证的用户名和密码*

```
[R1-Serial1/0]ppp chap user user1
[R1-Serial1/0]ppp chap password simple 123
```

*步骤 4：关闭在开启 R1 和 R2 的 PPP 链路，检查验证是否能够通过（步骤略）*

**R2 和 R3 的 PPP 进行双向 chap 验证**

*分析：双向验证意味着 R2 和 R3 双方都需要创建用于验证的用户，且需要在各自接口上配置对端的用户名
　　另外，虽然R2 和 R3 之间的 PPP 链路配置了 PPP-MP，但是身份验证仍然需要配置在物理接口上，所以 R2 和 R3 相连的所有 PPP 接口上都需要配置验证*

*步骤 1：在 R2 和 R3上创建用户验证 R3 的用户*

```
[R2]local-user user2 class network 
 New local user added.
[R2-luser-network-user2]password simple 123
[R2-luser-network-user2]service-type ppp
[R3]local-user user2 class network 
 New local user added.
[R3-luser-network-user2]password simple 123
[R3-luser-network-user2]service-type ppp
```

*步骤 2：在 R2 和 R3 相连的接口上配置需要进行 PPP 验证，验证方式为 chap，并配置对端验证本端的用户名*

```
[R2-Serial1/0]ppp authentication-mode chap
[R2-Serial1/0]ppp chap user user2
[R2-Serial2/0]ppp authentication-mode chap
[R2-Serial2/0]ppp chap user user2
[R3-Serial1/0]ppp authentication-mode chap
[R3-Serial1/0]ppp chap user user2
[R3-Serial2/0]ppp authentication-mode chap
[R3-Serial2/0]ppp chap user user2
```

*步骤 4：关闭在开启 R2 和 R3 的 PPP 链路，检查验证是否能够通过（步骤略）*
