---
title: RS-OSPF
date: '2021/2/25 10:45:48'
update: '2021/2/26 10:45:48'
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
tags:
  - 教程
  - posts
---

:::info
本文重点
了解OSPF协议的特点
掌握OSPF协议分层结构
掌握OSPF协议中的网络类型
掌握OSPF协议的报文封装
掌握OSPF协议状态迁移

交换机关于进出报文VLAN标记的处理方式
https://blog.csdn.net/carefree2005/article/details/109983515
华为：Access、Hybrid和Trunk三种模式的理解
https://blog.csdn.net/ixidof/article/details/7851774
:::

# OSPF理论

## RIP协议存在的问题

存在最大15跳的限制，不能适应大规模组网的需求
周期性发送全部路由信息，占用大量的带宽资源
路由收敛速度慢
以跳数作为度量值
存在路由环路可能性

## OSPF特点

没有路由跳数的限制
使用组播更新变化的路由和网络信息
路由收敛速度较快
以开销（Cost）作为度量值
采用的SPF算法可以有效的避免环路
在互联网上大量使用，是运用最广泛的路由协议

## 链路状态数据库同步过程  报文类型与封装

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/RS-OSPF/2021.03.09-16:43:43-5c4a51edf4d143e6b0beb3e4e6c51236.jpeg)

邻居邻接区别 为什么

| **OSPF**  **报文类型**             | **作用**                  |
| ------------------------------ | ----------------------- |
| Hello                          | 建立并维护邻居关系               |
| Database  Description（DD）      | 数据库内容的汇总（仅包含LSA摘要）      |
| Link  State Request（LSR）       | 请求自己没有的或者比自己更新的链路状态详细信息 |
| Link  State Update（LSU)        | 链路状态更新信息                |
| Link  State Acknowledge（LSAck） | 对LSU的确认                 |

OSPF报文直接封装在IP报文中，协议号为89。

|       |           |             |       |
| ----- | --------- | ----------- | ----- |
| 链路层帧头 | IP Header | OSPF Packet | 链路层帧尾 |

## 邻接建立过程

Down----Attempt（帧中继网络才有此状态）----Init----2-way----Exstart----Exchange-----Loading-----Ful-

down 关闭状态（稳定状态）
init 单边发现状态（收到对方的Hello报文，但没收到对方的Hello确认报文）
2-way 邻居状态（稳定状态，双方都收到了Hello确认报文--双方互相发现，并确认了DR/BDR角色--
当选举完毕，就算出现一台更高优先级的路由器，也不会替换成为新的DR/BDR
需要原DR/BDR失效，或者重置OSPF进程才会成为新的DR/BDR

- 2-way前提
  
  - Router-ID无冲突（两台不是邻居的路由器Router-ID冲突不会导致无法2-way，但会影响路由计算）
  
  - 掩码长度一致
  
  - 接口的区域Area-ID一致
  
  - 验证密码一致
  
  - helo-time一致（加快收敛速度可以改短计时器的时间，但要保持一致）
  
  - dead-time一致
    
    # DR 、dr-other之间 2way full 谁和谁建立
    
    > > 排错命令
    > > 华三：display ospf statistics error；
    > > 华为：https://forum.huawei.com/enterprise/zh/forum.php?mod=viewthread&tid=332149

exstart 交换开始状态
    -发送第一个DD报文  1、不传送LSDB摘要2、仅用于确定LSA传递的主从
    -DD报文位置符  //对某一位变量置位,就是将其设为“1”。 相反复位就是将其设为“0”。//
        I   Inint位  置位表示此报文是第一个DD报文
        M   MORE位   置位表示还有后续DD报文
        MS  master位 置位则表示本端为主

exchange 交换状态  发送后续DD报文，用于LSDB摘要
loading    读取状态  进行LSA的请求、加入和确认
    - 不匹配的MTU。
    - 损坏的链路状态请求分组。
full  邻接状态（稳定状态，两端LSDB同步）
**FULL前提**
    1.两端网络类型一致，否则邻居状态FULL，但无法学习路由
    2.连贯MTU一致   否则邻居状态卡在Exstart、Exchange

## 划分区域优势

减少了区域内LSDB中链路状态信息(LSA)的数量，降低了运行OSPF协议对路由器性能的要求
可以将相同功能性或者地理位置的路由器划分在一个区域内，以便于管理。
隔离拓扑变化，减少路由震荡对整个自治系统的影响。

## OSPF区域类型

**1、骨干区域只能有一个2、非骨干区域都要对接到骨干区域**
{.primary}

- 区域内路由器（Internal Router）//所有接口都在同一区域内
- 区域边界路由器（ABR，Area Border Router）**//连接骨干区域和非骨干区域**
- 骨干路由器（Backbone Router）//所有接口在骨干区域内
- 自治系统边界路由器（ASBR， Autonomous System Border Router ）**//连接外部自治系统，并引入了外部路由**

## DR 选举规则

///接口改pri优先级默认1大的优先、Router ID大的优先。已选的DR，后加入优先级更高不会被替代   reset ospf pro 重置重新选举   改完rid要重置才能生效
首先比较Hello报文中携带的优先级
优先级最高的被选举为DR，优先级次高的被选举为BDR
优先级为0的不参与选举
优先级一致的情况下，比较Router ID
Router ID越大越优先
保持稳定原则
当DR/BDR已经选举完毕，就算一台具有更高优先级的路由器变为有效，也不会替换该网段中已经选举的DR/BDR成为新的DR/BDR。
//RTE后来加入网络，虽然它的Router ID比原有的DR和BDR都高，但是出于稳定性的考虑，只能成为DRother路由器。
//当DR失效时，BDR立刻成为新的DR
//DRother路由器进行竞争，Router ID高的成为新的BDR

## Router ID

**配置全局Router-ID对所有协议生效
协议内指定的Router-ID优先级更高**
一台路由器如果要运行OSPF协议，则必须存在Router ID（RID）。
RID是一个32比特无符号整数，可以在一个自治系统中唯一的标识一台路由器。
RID可以手工配置，也可以自动生成。
如果没有通过命令指定RID，将按照如下顺序自动生成一个RID：
如果存在配置IP地址的Loopback接口，则选择Loopback接口地址中最大的作为Router ID；
如果没有配置IP地址的Loopback接口，则从其他接口的IP地址中选择最大的作为Router ID（不考虑接口的up/down状态）。

## OSPF网络类型

**对于不同**二层链路类型**的网段，ospf会生成不同网络类型
不同网络类型，DR/BDR选举，LSA细节，协议报文发送形式等会有所不同**
Broadcast（广播网络，以太网**默认**的网络类型）
    组播发送协议报文
        224.0.0.5所有运行OSPF的接口会监听
        225.0.0.6所有DR/BDR的接口会监听
    需要选举DR/BDR
    hello-time 10秒 每隔10秒发一次
    dead-time  40秒 40秒没收到就断掉
NBMA（Non-Broadcast Multi-Access，非广播多点可达网络，帧中继**默认**的网络类型---不支持组播和广播）
    单薄发送协议报文，需要手动指定
    需要选举DR/BDR
    hello-time 30
    dead-time  120
P2MP（Point-to-MultiPoint，点到多点，需由**其他**网络类型手动更改，一般会把帧中继默认网络类型NBMA改为P2MP）
    每个端口发单播，模拟组播发送协议报文，可以自动发现邻居
    不选举DR/BDR
    hello-time 30
    dead-time  120
P2P（Point-to-Point，点到点网络，PPP默认的网络类型）
    组播发送协议报文
    不选举DR/BDR
    hello-time 10秒
    dead-time  40秒

## NBMA与P2MP

NBMA网络是指那些全连通的、非广播、多点可达网络。而P2MP网络，则并不需要一定是全连通的。
NBMA是一种缺省的网络类型，而P2MP网络必须是由其它的网络强制更改的。
NBMA网络采用单播发送报文，需要手工配置邻居。P2MP网络采用组播方式发送报文。