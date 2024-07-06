---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
---

[TOC]

## 1 背景

服务器虚拟化技术的广泛部署，极大地增加了数据中心的计算密度；同时，为了实现业务的灵活变更，虚拟机VM（Virtual Machine）需要能够在网络中不受限迁移（如图1-1所示）。实际上，对于数据中心而言，虚拟机迁移已经成为了一个常态性业务。

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595163922265-18fd8623-90fe-48b8-8a5a-8526923d720e.jpeg)

## 2 VXLAN网络模型

VXLAN网络模型

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595163959466-984b10b2-1ef5-443e-b920-d8aa3c74e594.jpeg)

VTEP（VXLAN Tunnel Endpoints，VXLAN隧道端点）

VXLAN网络的边缘设备，是VXLAN隧道的起点和终点，VXLAN报文的相关处理均在这上面进行。总之，它是VXLAN网络中绝对的主角。VTEP既可以是一***立的网络设备（比如华为的CE系列交换机），也可以是虚拟机所在的服务器。那它究竟是如何发挥作用的呢？答案稍候揭晓。

- VNI（VXLAN Network Identifier，VXLAN 网络标识符）

前文提到，以太网数据帧中VLAN只占了12比特的空间，这使得VLAN的隔离能力在数据中心网络中力不从心。而VNI的出现，就是专门解决这个问题的。VNI是一种类似于VLAN ID的用户标示，一个VNI代表了一个租户，属于不同VNI的虚拟机之间不能直接进行二层通信。VXLAN报文封装时，给VNI分配了足够的空间使其可以支持海量租户的隔离。详细的实现，我们将在后文中介绍。

- VXLAN隧道

“隧道”是一个逻辑上的概念，它并不新鲜，比如大家熟悉的GRE。说白了就是将原始报文“变身”下，加以“包装”，好让它可以在承载网络（比如IP网络）上传输。从主机的角度看，就好像原始报文的起点和终点之间，有一条直通的链路一样。而这个看起来直通的链路，就是“隧道”。顾名思义，“VXLAN隧道”便是用来传输经过VXLAN封装的报文的，它是建立在两个VTEP之间的一条虚拟通道。

## 3. VXLAN报文格式

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164043523-82d7b5c0-85bd-4c1d-9cc4-d8ef6fa9a632.jpeg)

VTEP对VM发送的原始以太帧（Original L2 Frame）进行了以下“包装”：

- VXLAN Header

增加VXLAN头（8字节），其中包含24比特的VNI字段，用来定义VXLAN网络中不同的租户。此外，还包含VXLAN Flags（8比特，取值为00001000）和两个保留字段（分别为24比特和8比特）。

- UDP Header

VXLAN头和原始以太帧一起作为UDP的数据。UDP头中，目的端口号（VXLAN Port）固定为4789，源端口号（UDP Src. Port）是原始以太帧通过哈希算法计算后的值。

- Outer IP Header

封装外层IP头。其中，源IP地址（Outer Src. IP）为源VM所属VTEP的IP地址，目的IP地址（Outer Dst. IP）为目的VM所属VTEP的IP地址。

- Outer MAC Header

封装外层以太头。其中，源MAC地址（Src. MAC Addr.）为源VM所属VTEP的MAC地址，目的MAC地址（Dst. MAC Addr.）为到达目的VTEP的路径上下一跳设备的MAC地址。

## 4.1 VXLAN网络的子网互通

### 4.1.1 相同子网互通

**部署方案**

如图4-1所示，Leaf1和Leaf2作为VXLAN网络的VTEP，两个Leaf之间搭建VXLAN隧道，并在每个Leaf上部署VXLAN二层网关，即可实现同一部门VM之间的相互通信。此时Spine只作为VXLAN报文的转发节点，不感知VXLAN隧道的存在，可以是任意的三层网络设备。

图4-1 相同子网互通

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164231039-eba11836-f808-4e37-9674-44a6ba3b523a.jpeg)

### 4.1.2 不同子网互通（集中式网关）

**部署方案**

如图4-2所示，Leaf1、Leaf2和Spine作为VXLAN网络的VTEP，Leaf1和Spine之间、Leaf2和Spine之间分别搭建VXLAN隧道，并在Spine上部署VXLAN三层网关，即可实现不同部门VM之间的相互通信。

图4-2 不同子网互通（集中式网关）

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235472-7ff6bf4e-37cd-4be4-adb3-b1e385ae0533.jpeg)

### 4.1.3 不同子网互通（分布式网关）

**出现背景**

细心的读者可能已经发现，在不同子网互通（集中式网关）中，同一Leaf（Leaf1）下挂的不同网段VM（VM1和VM2）之间的通信，都需要在Spine上进行绕行，这样就导致Leaf与Spine之间的链路上，存在冗余的报文，额外占用了大量的带宽。同时，Spine作为VXLAN三层网关时，所有通过三层转发的终端租户的表项都需要在该设备上生成。但是，Spine的表项规格有限，当终端租户的数量越来越多时，容易成为网络瓶颈。

分布式网关的出现，很好的解决了这两个问题。

**部署方案**

- 同Leaf节点下不同部门VM之间的通信

如图4-3所示，Leaf1作为VXLAN网络的VTEP，在Leaf1上部署VXLAN三层网关，即可实现同Leaf下不同部门VM之间的相互通信。此时，VM1和VM2互访时，流量只需要在Leaf1节点进行转发，不再需要经过Spine节点，从而节约了大量的带宽资源。

- 跨Leaf节点不同部门VM之间的通信

如图4-3所示，Leaf1和Leaf2作为VXLAN网络的VTEP，在Leaf1和Leaf2上部署VXLAN三层网关。两个VXLAN三层网关之间通过BGP动态建立VXLAN隧道，并通过BGP的remote-nexthop属性发布本网关下挂的主机路由信息给其他BGP邻居，从而实现跨Leaf节点不同部门VM之间的相互通信。

图4-3 不同子网互通（分布式网关）

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235487-9c67f541-0e11-41e7-8993-4817831e040b.jpeg)

## 4.2 VXLAN网络的可靠性

随着网络的快速普及和应用的日益深入，基础网络的可靠性日益成为用户关注的焦点，如何能够保证网络传输不中断对于终端用户而言非常重要。

在VXLAN网络的子网互通中，VM与Leaf之间，Leaf与Spine之间都是通过单归方式接入的。这种组网接入方式，显然已经不能满足用户对VXLAN网络可靠性的需求。

这时，可以按照如下图所示方式，提升VXLAN网络的可靠性。

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235481-d5180f5b-935a-486c-b34c-4568b1366d6c.jpeg)

### 4.2.1 接入层的可靠性

通常采用堆叠（CSS）方式提升接入层的可靠性。这是因为，接入层的设备数量繁多，堆叠方式可以将多台交换机设备组合在一起，虚拟化成一台交换设备，所有配置均在这一台虚拟交换机上进行，从而简化了接入层设备的运维复杂度。此外，堆叠系统内成员交换机之间在进行冗余备份的同时，能够利用跨设备的Eth-Trunk实现设备间链路的负载分担。

图4-4 接入层的可靠性

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235474-85beb3c4-8212-479d-a989-e386c054b778.jpeg)

如图4-4所示，Leaf1和Leaf2组建为堆叠系统CSS-1，Leaf3和Leaf4组建为堆叠系统CSS-2，VM1~VM4均通过双归的方式接入到各自的CSS系统中。CSS-1和CSS-2作为VXLAN网络的VTEP，两个CSS之间搭建VXLAN隧道，并在每个CSS上部署VXLAN二层网关，从而实现同一部门VM之间的相互通信。

- 当CSS系统正常时，VM1与VM3之间互访的流量，通过CSS-1堆叠系统中的Leaf1和Leaf2进行负载分担转发。
- 当CSS系统故障时（Leaf1故障），VM1与VM3之间互访的流量，全部切换到CSS-1堆叠系统中的Leaf2进行转发，从而实现了流量的不间断，提升了接入层的可靠性。

### 4.2.2 核心层的可靠性

通常采用多活网关方式提升核心层的可靠性。这是因为，核心层设备物理位置较为分散，传统的设备级备份无法满足要求，必须通过协议级备份来实现。

在多活网关组网中，通过给多台Spine设备部署相同的网关信息，将它们对外模拟成VXLAN网络中的一个虚拟VTEP，然后在所有Spine设备上配置三层网关，使得无论流量发到哪一个Spine，该设备都可以提供服务，将报文正确转发给下一跳设备。此外，多活网关中的多台Spine之间形成负载分担关系，共同进行流量转发。

图4-5 核心层的可靠性

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235478-7cdb1768-9fba-425d-be99-40d22d3afe87.jpeg)

如图4-5所示，Spine1、Spine2分别与接入层的堆叠系统CSS-1和CSS-2之间建立VXLAN隧道，在Spine1、Spine2上配置VXLAN三层网关功能，Spine1、Spine2上部署相同的网关MAC地址、网关IP地址以及源VTEP地址，以便对外模拟成一个虚拟的VTEP，从而实现了不同网段VM之间、VM与外网之间的互通。

l 当多活网关系统正常时，VM1与VM4之间互访的流量、VM1与Internet之间互访的流量，通过Spine1和Spine2进行负载分担转发。

l 当多活网关系统故障时（Spine1故障），VM1与VM4之间互访的流量、VM1与Internet之间互访的流量，全部切换到Spine2进行转发，从而实现了流量的不间断，提升了核心层的可靠性。

## 4.3 VXLAN网络的部署方案

CE系列交换机支持通过**单机方式**和**控制器方式**来部署VXLAN网络。这两种方式中VXLAN网络的子网互通以及VXLAN网络的可靠性的实现均与前面一致，不同点在于VXLAN的配置下发方式不同：单机方式是通过CLI手动在设备上进行配置，控制器方式是通过控制器向设备下发配置或流表，设备仅作为转发器。

下面小编以图4-6所示组网为例，简单介绍一下当前CE系列交换机支持的VXLAN控制器部署方式：SNC控制器方式和AC控制器方式。

图4-6 控制器部署方案

![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/VXLAN.assets/2021.03.09-17:31:50-1595164235523-6fb816a1-44d8-43f0-b043-83fdb087abae.jpeg)

- SNC控制器方式

SNC控制器方式是指通过SNC控制器动态建立VXLAN隧道。

此方式下，CE系列交换机作为转发器，无需进行VXLAN配置。VXLAN隧道的创建以及指导报文转发的表项，均由SNC控制器通过OpenFlow协议向转发器下发。

- AC控制器方式

AC控制器方式是指通过AC控制器动态建立VXLAN隧道。

此方式下，CE系列交换机作为转发器，需要预先完成部分基础配置（具体配置内容请参考产品配置指南），AC控制器通过NETCONF协议向转发器下发建立VXLAN隧道的配置，通过OpenFlow协议控制报文在隧道中的转发。