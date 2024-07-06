---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
---
## STP/RSTP/MSTP的区别：

 1、STP：不能快速迁移。即使是在点对点链路或边缘端口，也必须等待2倍的daoforward delay的时间延迟，网络才能收敛。

 2、RSTP：可以快速收敛，局域网内所有网桥共享一棵生成树，不能按vlan阻塞冗余链路。

 3、MSTP：允许不同vlan的流量沿各自的路径分发，从而为冗余链路提供了更好的负载分担机制。

## STP基本概念介绍

根桥（Root Bridge）：是整个生成树的根节点，所有网桥中优先级最高的桥。

指定桥（Designate Bridge）：负责一个物理段（相对于两个网桥而言是一个物理段）上数据转发任务的桥。

根端口（Root Port）：指一个网桥上距离跟桥最近的端口。根桥上没有根端口，只有非根桥上有且仅有一个根端口。

指定端口（Designate Port）：指定桥上的端口，就是用于转发生成树信息报文的端口。根桥上全是指定端口。

候补端口（Alternate Port）：用来为根端口或指定端口做备份的端口，即为最终需要阻塞的端口。

桥ID（Bridge ID）：每一个运行STP协议的网桥都会有一个桥ID，用于在网络中唯一标识一个桥，由桥优先级和桥MAC地址组成，桥优先级占2字节，桥MAC地址占6个字节。桥优先级只能是4096的整数倍，最大为61440，默认为32768。

路径开销（Path Cost）：STP中每条链路都具有开销值，默认的开销值取决于链路的带宽，带宽越大，开销越小。例如IEEE标准的开销，链路速度为10Gbps开销为2，速度为100Mbps时开销为19，速度为10Mbps时候开销为100。

BPDU（Bridge Protocol  Data Unit，桥协议数据单元）：用于网桥之间传递BPDU来交互协议信息。BPDU分为配置BPDU和TCN BPDU。配置BPDU用来进行生成树的计算和维护生成树拓扑的报文。TCN BPDU是当拓扑结构改变时候，用来通知相关桥设备网络拓扑结构发生变化的报文。



![20181220214934716.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880555414-07a58b41-5828-43d9-bfe3-93ef6b9b4784.png)



## STP BPDU报文分析

![2018122021511435.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880562337-93a91507-bc1e-41a1-a869-2ac41de78cec.png)



Protocol Identifier：固定为0x0000，表示是生成树协议

Protocol Version Identifier：协议版本号，STP版本号为0x00

BPDU Type：配置BPDU类型为0x00，TCN BPDU类型为0x80

Flags：由8位组成，最低位为TC标志位，最高位为TCA标志位，其他6位保留。当拓扑结构变化时候，下游网桥将会从根端口发送TCN BPDU报文，TC标志位置为1，上游网桥收到后进行相应处理，回复配置BPDU报文，TCA标志位置为1.

Root Identifier：根桥ID，包含优先级和MAC地址，标识网络中的根桥。

Root Path Cost：根路径开销，指从发送该配置BPDU的网桥到根网桥的最小路径开销，是所有链路开销的代数和。

Bridge Identifier：发送该配置BPDU的网桥ID，即该指定桥的ID。

Port Identifier：发送该配置BPDU的网桥的发送端口ID。

Message Age：从根桥生成配置BPDU开始，到当前时间为止配置BPDU的存活时间。

Max Age：配置BPDU存活的最大时间。

Hello Time：根桥生成并发送配置BPDU的周期，默认为2s

Forward Delay：配置BPDU传播到全网的最大时延，默认为15s

## STP端口存在的五种状态：

①关闭（disable）：端口处于管理关闭状态

不收发任何报文

②阻塞（blocking）: 不能转发用户数据

不接收或转发数据，接收但不发送BPDU，不进行地址学习

③监听（listening）: 接口开始启动

不接收或转发数据，接收并发送BPDU，不进行地址学习

④学习（learning) : 学习MAC地址, 构建MAC表进程项

不接收或转发数据，接收并发送BPDU，开始地址学习

⑤转发（forwarding）: 可以转发用户数据

接收或转发数据，接收并发送BPDU，开始地址学习

## STP端口可以转换的状态：

· 从初始化(交换机启动)到阻塞状态(blocking)

· 从阻塞状态(blocking)到监听(listening)或失效状态(disabled)

· 从监听状态(listening)到学习(learning)或失效状态(disabled)

· 从学习状态(listening)到转发(forwarding)或失效状态(disabled)

· 从转发状态(forwarding到失效状态(disabled)

· 从失效状态(disabled)到阻塞状态(blocking)

## RSTP端口状态：3种：

丢弃状态，学习状态，转发状态

因为STP前面三个状态都是无法转发的。因此同一规划到丢弃状态下！

STP端口角色： 4种：

根端口，指定端口，阻塞端口，禁用端口

RSTP端口角色： 4种：

根端口，指定端口，替代端口，备份端口

![20181220215858112.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880639570-61b41957-ed36-41ad-bbdc-fb1812ebf452.png)

## RSTP BPDU报文

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880670931-3d287e2d-1e1d-46f6-bf60-1dfd74a2481d.png)

与STP BPDU相比较

Protocol Version Identifier为2

BPDU Type为0x02，表示为RST BPDU

BPDU flags使用全部的8位

在报文的最后增加了Versionl Length字段，值为0，表示本BPDU中不包含Versionl内容。

最高位和最低位TCA和TC与STP相同。Agreement（同意）及Proposal（提议）用于RSTP的P/A机制，会大大提高RSTP的收敛速度。Port Role（接口角色）两个bit位，01表示根接口，10表示替代接口，11表示指定接口，00保留。Forwarding（转发）和Learning（学习）用于表示该RST BPDU发送接口的接口状态。



RSTP与STP不同，在网络稳定后，STP的非根桥之会转发根桥发来的BPDU报文，而RSTP无论是非根桥还是根桥都会周期性的发送BPDU。

在STP中只有在指定端口收到低优先级的配置BPDU时才会立即回应（发送自己计算的配置BPDU报文），阻塞状态端口不会对低优先级的配置BPDU做出回应。

在RSTP中，指定端口或阻塞状态的端口收到低优先级的RST BPDU，也可以立即对其做出回应。

## MSTP 基本概念解释

MST域是一个具有相同域名、修订级别和摘要信息的网桥或交换机构成的集合，一个域可以包含多个实例。

域名，本域的名称，MSTP中每一个域都有一个独一无二的名称，配置不同域名会被认为属于不同的域。

修订级别，目前保留，默认为0。

配置摘要，由网桥的vlan和实例映射关系生成的长度为16字节的HMAC-MD5签名。

IST是MST域内的一颗生成树，每颗生成树对应一个实例。实例号为0，一定存在的

MSTI是多生成树实例，实例号从1开始，为0的实例号是IST

MSTI域根，是每一个MSTI实例上优先级最高的网桥

CST（公共生成树）是网络内所有MST域通过计算得到的一棵树。

CIST（公共和内部生成树）是整个网络所有设备经过生成树计算得到的一棵树。由IST和CST共同构成。

CIST总根，是整个网络中优先级最高的桥，是CIST的根桥。

CIST域根，IST的根桥即为CIST的域根，是MST域内距离总根最近的桥，也称为Master桥。

## MSTP端口角色

相较RSTP，桥的角色上，MSTP增加了Master桥。端口角色上，增加了域边界端口以及Master端口。根端口、指定端口、Alternate端口、Backup端口定义和RSTP一样。

IST（实例号为0网络）中距离总根最近的桥为Master桥，该桥为IST的根，Master桥指向总根（整个网络中优先级最高的桥）的端口为Master端口。

MST域内网桥和其他MST域或STP/RSTP网桥相连的端口称为域边界端口，Master端口也是域边界端口。



![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880746918-8c215fca-ee0b-4f90-8dca-4cbf83c4fb4e.png)

## MSTP ***\*BPDU报文\****

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/STP%20RSTP%20MSTP.assets/2021.03.09-17:31:09-1593880773226-34349cb1-3e7e-44d9-8d62-7f58ac282565.png)

BPDU Type：0x02

BPDU flags:CIST标志字段

Root Identifier：CIST总根交换机ID

Root Path Cost：CIST外部路径开销，指从本交换机所属的MST域到CIST根交换机的累计路径开销。

Bridge Identifier：CIST的域根交换机ID（每个域距离根桥最近的交换机，域根并不是只有一个，每个域都有一个域根，很多资料上也称为CIST域根，我理解一半天），即IST Master的ID。如果总根在这个域内，那么域根交换机ID就是总根交换机ID。

Port Identifier：CIST的指定端口ID（当前报文的上游交换机发送端口）

Version 3 Length：表示MST专有字段的长度，用于接收到BPDU后进行校验。

MST Config ID：格式选择字符固定为0x00。

MST Config name：域名

MST Config revision：修订级别，为0

MST Config digest：配置摘要

CIST Internal Root Path Cost：CIST内部路径开销，表示发送此BPDU的网桥到达CIST域根的路径开销。

CIST Bridge Identifier：发送此BPDU的网桥ID

CIST Remaining hops：CIST剩余跳数，限制MST域的规模，从域根开始，BPDU每经过一个网桥，跳数就减一，网桥会丢弃收到的跳数为0的BPDU，从而限制MST域的规模。默认为20

MSTI配置信息中的内容只在各自实例中有效，且每个实例中这些字段值是独立的

MSTI flag：一个字节，从第一位到第七位的定义和RSTP相同，第八位为Master标志位

Region Root：表示该实例的域根ID

Internal root path cost：表示发送此BPDU的网桥到达MSTI域根的路径开销

Bridge Identifier priority：表示发送此BPDU的网桥，即指定桥的优先级，其中高4位为优先级位，第四位固定为0

Port Identifier priority：表示发送此BPDU的端口的优先级，其中高4位为优先级位，第四位固定为0

Remaining hops：表示BPDU在该MST实例中的剩余跳数。