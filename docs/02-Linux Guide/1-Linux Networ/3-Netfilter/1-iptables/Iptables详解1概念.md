---
title: 01.Iptables概念
---

iptables/netfilter的关系，五链四表的关系，数据转发流程。



## iptables/netfilter

iptables处于用户态记录规则，netfilter处于内核态通过hook网络函数按规则对报文进行过滤

iptables 通过表来组织规则，相同功能的规则放在同一个表中。

- filter：负责包的过滤 
- nat：网络地址转换 
- mangle：修改报文 
- raw：关闭 nat 表上启动的连接追踪 
- security:  用于 [强制访问控制](https://wiki.archlinux.org/index.php/Security#Mandatory_access_control) 网络规则

iptables 的执行顺序则是按照 chain 来决定，chain 可以放各种表，执行顺序如下图

![FW-IDS-iptables-Flowchart-v2019-04-30-1](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/zjj2wry.github.io/images/2021.09.26-22:43:40-iptables.png)

## “链”的概念



根据实际情况的不同，报文经过“链”可能不同。每个“链”可匹配多条规则。如果报文需要转发，那么报文则不会经过input链发往用户空间，而是直接在内核空间中经过forward链和postrouting链转发出去的。

所以，根据上图，我们能够想象出某些常用场景中，报文的流向：

- 经过本机的包：prerouting ->input
- 从本机转发出去的包：prerouting->forward->postrouting
- 从本机出去的包：output->postrouting

## “表”的概念

“链”上都放置了一串规则，但是这些规则有些很相似，比如，A类规则都是对IP或者端口的过滤，B类规则是修改报文，那么这个时候，我们把具有相同功能的规则的集合叫做”表”，所以说，不同功能的规则，我们可以放置在不同的表中进行管理，而iptables已经为我们定义了4种表，每种表对应了不同的功能，而我们定义的规则也都逃脱不了这4种功能的范围，所以，学习iptables之前，我们必须先搞明白每种表 的作用。

表的执行顺序 raw > mangle > filter > security > nat

另外不同的 chain 中的表也不同，比如想做 filter 只能在 input、forward、output 中做，想做 nat 只能在不是 forward 的 chain 中做。

iptables为我们提供了如下”表”

| 表       | 功能     | 内核模块       |
| -------- | --------| ------------- |
| filter | 负责过滤功能                    | iptables_filter |
| nat    | net地址转换（端口映射，地址映射等） |   iptable_nat     |
| mangle | 拆解报文，做出修改，并重新封装 的功能； |   iptable_mangle  |
| raw    | 关闭nat表上启用的连接追踪机制（优先级最高，设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能）       | iptable_raw     |

## 表链关系

**不是所有链都可以用所有表，每个”链”上的规则都存在于哪些”表”**

|链|链规则可以存在于那些表：|
|-|-|
|PREROUTING  |raw表，mangle表，nat表。|
|INPUT      |mangle表，filter表，（centos7中还有nat表，centos6中没有）。|
|FORWARD  |  mangle表，filter表。|
|OUTPUT  | raw表，mangle表，nat表，filter表。 |
|POSTROUTING | mangle表，nat表。|

**我们在实际的使用过程中，往往是通过”表”作为操作入口，对规则进行定义的**

|表|表中的规则可以被哪些链使用：|
|-|-|
|raw  | PREROUTING，OUTPUT|
|mangle|  PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING|
|nat |  PREROUTING，OUTPUT，POSTROUTING（centos7中还有INPUT，centos6中没有）|
|filter | INPUT，FORWARD，OUTPUT|

> 某些链天生就不能使用某些表中的规则，目前4张表中的规则处于同一条链的只有output链。

## 表优先级

iptables为我们定义了4张”表”,当他们处于同一条”链”时，执行的优先级如下。

优先级次序（由高而低）：

raw –> mangle –> nat –> filter

> 为了更方便的管理，我们还可以在某个表里面创建自定义链，将针对某个应用程序所设置的规则放置在这个自定义链中，但是自定义链接不能直接使用，只能被某个默认的链当做“动作”去调用才能起作用。

## 规则

规则由匹配条件和处理动作组成。根据指定的匹配条件来尝试匹配每个流经此处的报文，一旦匹配成功则不会匹配后面的规则（注意accept和drop reject区别），由该规则后面指定的处理动作进行处理；所以添加规则时，规则的顺序非常重要。

首先我们要明确最最最基础的一点，当规则中同时存在多个匹配条件时，多个条件之间默认存在”与”的关系，即报文必须同时满足所有条件，才能被规则匹配。

匹配规则参数大多数可用“！”取反

比如-s 192.168.1.1 表示匹配此源地址，！-s 192.168.1.1 表示匹配除此地址之外的地址，并不代表此地址一定与当前定义的动作相反，只是不匹配当前规则不执行对应的动作而已，还会继续匹配后续表链中的规则动作。



**1.匹配条件**

匹配条件分为基本匹配条件与扩展匹配条件

**2.基本匹配条件：**

源地址Source IP，目标地址 Destination IP

源端口Source Port, 目标端口Destination Port

**3.扩展匹配条件：**

除了上述的条件可以用于匹配，还有很多其他的条件可以用于匹配，这些条件泛称为扩展条件，这些扩展条件其实也是netfilter中的一部分，只是以模块的形式存在，如果想要使用这些条件，则需要依赖对应的扩展模块。

**4.处理动作**

在iptables中target译为目标，表示数据包匹配后将交由target 后面的动作或自定义链来处理，其中动作也可以分为基本动作和扩展动作。自定义链后面文章会提到。

此处列出一些常用的动作，之后的文章会对它们进行详细的示例与总结：

**ACCEPT**：将封包放行，进行完此处理动作后，将不再匹配当前链中其他规则或同一表中其他规则，直接跳往下一个规则链（natostrouting）。

**DROP**：直接丢弃数据包，不给任何回应信息，如果在子链中被Drop，那它在主链中也不会继续前进，不管是在当前表还是其他表里。客户端常提示超时time out

**REJECT**： 拦阻该封包，并返回错误信息。只能用在INPUT\FORWARD\OUTPUT和它的子链里，包含REJECT的链只能被他们调用，否则不发挥作用。可以传送错误消息的封包有几个选择：ICMP port-unreachable、ICMP echo-reply 或是 tcp-reset（这个封包会要求对方关闭联机），进行完此处理动作后，将不再比对其它规则，直接中断过滤程序。 例如：iptables -A FORWARD -p TCP --dport 22 -j REJECT --reject-with tcp-reset

>DROP与REJECT有什么不同呢? 
>
>火墙内的策略动作有DROP和REJECT两种，区别如下：
>
>1、DROP动作只是简单的直接丢弃数据，并不反馈任何回应。
>	客户端提示：time out 超时
>	DROP比REJECT好在节省资源，而且延缓黑客攻击的进度；坏在容易让企业的网络问题难以排查，而且在DDoS攻击的情况容易耗尽所有的带宽。
>
>2、REJECT会返回一个拒绝数据包(TCP FIN或UDP-ICMP-PORT-UNREACHABLE)，明确的拒绝对方的连接动作。连接马上断开，Client会认为访问的主机不存在。REJECT在IPTABLES里面有一些返回参数，参数如下：ICMP port-unreachable、ICMP echo-reply 或是 tcp-reset（这个封包会要求对方关闭联机），进行完此处理动作后，将不再比对其它规则，直接中断过滤程序。
>	客户端提示： Destnation Port Unreachable 目标不可达之类的错误信息
>	REJECT比DROP的好处在于容易诊断和调试网络设备或防火墙造成的问题；

**SNAT**：源地址转换，解决内网用户用同一个公网地址上网的问题。

**MASQUERADE**：是SNAT的一种特殊形式，适用于动态的、临时会变的ip上。

**DNAT**：目标地址转换。

**REDIRECT**：在本机做端口映射。

**LOG**：在/var/log/messages文件中记录日志信息，然后将数据包传递给下一条规则，也就是说除了记录以外不对数据包做任何其他操作，仍然让下一条规则去匹配。