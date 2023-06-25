---
title: 02.Iptables管理命令
---

iptables 增删改查 常用语句

iptables -t 表名 -[ A | I | D] 链名 (规则编号) 匹配规则 -j 动作

iptables [-t 表名] 选项 [链名] [匹配条件] [-j 控制类型]



## 查询表链规则

首先我们来回顾一下表链关系

| 表      | 表中的规则可以被哪些链使用：                                            |
| ------ | --------------------------------------------------------- |
| raw    | PREROUTING，OUTPUT                                         |
| mangle | PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING               |
| nat    | PREROUTING，OUTPUT，POSTROUTING（centos7中还有INPUT，centos6中没有） |
| filter | INPUT，FORWARD，OUTPUT                                      |

### 命令

```bash
iptables ( --line-numbers ) -t {表名} ( -n | -v| -x ) -L {链名}

实际使用中，为了方便，往往会将短选项进行合并
iptables --line-numbers -t 表名 -nvxL 链名

-t 指定表名，当没有使用-t选项指定表时，默认为操作filter表
-L 列出规则，后可跟指定表所在链名
-v 显示详细参数
--line-numbers 显示规则的编号，centos中可缩写成–line
-n 禁止地址反解析
    iptables默认为我们进行了名称解析0.0.0.0的源地址与目标地址会反解为anywhere，但是在规则非常多的情况下如果进行名称解析，效率会比较低，我们可以使用-n选项，不对IP地址进行名称反解，直接显示IP地址。
-x 显示精确的计数值
    当被匹配到的包达到一定数量时，计数器会自动将匹配到的包的大小转换为可读性较高的单位（Kb Mb）
如果你想要查看精确的计数值，而不是经过可读性优化过的计数值，那么你可以使用-x选项，表示显示精确的计数值单位是byte，
```

场景：我们需要禁止某个IP地址访问我们的主机，我们则需要在INPUT链上定义规则。因为，我们在理论总结中已经提到过，报文发往本机时，会经过PREROUTING链与INPUT链（如果你没有明白，请回顾前文），所以，如果我们想要禁止某些报文发往本机，我们只能在PREROUTING链和INPUT链中定义规则，但是PREROUTING链并不存在于filter表中，换句话说就是，PREROUTING天生就没有过滤的能力，所以，我们只能在INPUT链中定义。

### 字段解释

![image-20210926224436531](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(2)%E5%9F%BA%E7%A1%80%E7%AE%A1%E7%90%86%E5%91%BD%E4%BB%A4/2021.09.26-22:44:39-image-20210926224436531.png)

其实，这些字段就是规则对应的属性，说白了就是规则的各种信息，那么我们来总结一下这些字段的含义。

> **字段含义**
> 
> pkts:对应规则匹配到的报文的个数。
> bytes:对应匹配到的报文包的大小总和。
> target:规则对应的target，往往表示规则对应的”动作”，即规则匹配成功后需要采取的措施。
> prot:表示规则对应的协议，是否只针对某些协议应用此规则。
> opt:表示规则对应的选项。
> in:表示数据包由哪个接口(网卡)流入，我们可以设置通过哪块网卡流入的报文需要匹配当前规则。
> out:表示数据包由哪个接口(网卡)流出，我们可以设置通过哪块网卡流出的报文需要匹配当前规则。
> source:表示规则对应的源头地址，可以是一个IP，也可以是一个网段。
> destination:表示规则对应的目标地址。可以是一个IP，也可以是一个网段。
> 
> **链后面的括号中包含policy ACCEPT ，0 packets，0bytes 三部分**
> 
> policy:表示当前链的默认策略
>    在配置IPTABLES白名单时，往往会将链的默认策略设置为ACCEPT，通过在链的最后设置REJECT规则实现白名单机制，而不是将链的默认策略设置为DROP，如果将链的默认策略设置为DROP，当链中的规则被清空时，管理员的请求也将会被DROP掉。
> 
>    我们可以把packets与bytes称作”计数器”
> packets:表示当前链默认策略匹配到的包的数量，0 packets表示默认策略匹配到0个包。
> bytes:表示当前链默认策略匹配到的所有包的大小总和。

## 添加

```
iptables -t 表名 -[A,I] 链名 [规则编号] -s源地址 -j 动作
-t指定表，缺省默认操作filter表。
-A表示在链的尾部追加规则+链名
-I表示在链的首部插入规则+链名，链名后面加上空格数字，表示新增规则按编号插入
-s为source之意，表示源地址。
-j选项，指明当”匹配条件”被满足时，所对应的动作
```

如下命令在filter表的INPUT链中追加一条规则，这条规则表示接受所有来自192.168.1.146的发往本机的报文。

~~~
iptables -A INPUT -s 10.0.0.10 -j ACCEPT
~~~

在filter表的INPUT链的前端添加新规则。

~~~
iptables -I INPUT -s 10.0.0.10 -j ACCEPT
~~~

我们也可以在添加规则时，指定新增规则的编号，这样我们就能在任意位置插入规则了，我们只要把刚才的命令稍作修改即可，如下。

仍然使用-I选项进行插入规则操作，-I INPUT 2表示在INPUT链中新增规则，新增的规则的编号为2

~~~
iptables -A INPUT 2 -s 10.0.0.10 -j ACCEPT
~~~

## 删除

```
按编号删除:
iptables -t 表名 -D 链名 [规则编号]
按规则匹配删除:
iptables -t 表名 -D 规则 动作

-F选项为flush之意，即冲刷指定的链，即删除指定链中的所有规则，
    注意，此操作相当于删除操作，在没有保存iptables规则的情况下，请慎用。
删除指定表中某条链中的所有规则    
iptables -t 表名 -F 链名
不指定链名，只指定表名即可删除表中所有链上的所有规则，命令如下
iptables -t 表名 -F
```

**方法一：根据规则的编号去删除规则**

先查看一下filter表中INPUT链中的规则

~~~
iptables --line 0vnl INPUT
~~~

假如我们想要删除上图中的第3条规则，则可以使用如下命令。

~~~
iptables -t filter -D INPUT 3 
~~~

上例中，使用了-t选项指定了要操作的表（没错，省略-t默认表示操作filter表），使用-D选项表示删除指定链中的某条规则，-D INPUT 3表示删除INPUT链中的第3条规则。

 **方法二：根据具体的匹配条件与动作删除规则**

当然，我们也可以根据具体的匹配条件与动作去删除规则，比如，删除下图中源地址为192.168.1.146，动作为ACCEPT的规则，于是，删除规则的命令如下。

![image-20210926224729295](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(2)%E5%9F%BA%E7%A1%80%E7%AE%A1%E7%90%86%E5%91%BD%E4%BB%A4/2021.09.26-22:47:30-image-20210926224729295.png)

## 修改

那么，我们怎样修改某条规则中的动作呢？比如，我想把如下规则中的动作从DROP改为REJECT，改怎么办呢？

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/2.iptables%E7%AE%A1%E7%90%86/2021.04.19-11:20:53-D-assets-2.iptables%E7%AE%A1%E7%90%86-041517_1436_16.png)

我们可以使用-R选项修改指定的链中的规则，在修改规则时指定规则对应的编号即可，示例命令如下

![image-20210926224816976](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(2)%E5%9F%BA%E7%A1%80%E7%AE%A1%E7%90%86%E5%91%BD%E4%BB%A4/2021.09.26-22:48:18-image-20210926224816976.png)

> 注意：上例中， -s选项以及对应的源地址不可省略，即使我们已经指定了规则对应的编号，但是在使用-R选项修改某个规则时，**必须指定规则对应的原本的匹配条件**（如果有多个匹配条件，都需要指定）。
> 
> 如果上例中的命令没有使用-s指定对应规则中原本的源地址，会采用缺省值0.0.0.0/0匹配所有网段的IP地址
> 而此时，-j对应的动作又为REJECT，所以在执行上述命令时如果没有指明规则原本的源地址，那么所有IP的请求都被拒绝了

## 默认策略

当链中没有任何规则时，防火墙会按照默认动作处理报文，我们可以修改指定链的默认策略，使用如下命令即可。

![image-20210926224802359](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(2)%E5%9F%BA%E7%A1%80%E7%AE%A1%E7%90%86%E5%91%BD%E4%BB%A4/2021.09.26-22:48:04-image-20210926224802359.png)

使用-t指定要操作的表，使用-P选项指定要修改的链，上例中，-P FORWARD DROP表示将表中FORWRD链的默认策略改为DROP。

## 保存

**centos6中**，使用`service iptables save`命令即可保存规则，规则默认保存在`/etc/sysconfig/iptables`文件中

![image-20210926224750958](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Iptables%E8%AF%A6%E8%A7%A3(2)%E5%9F%BA%E7%A1%80%E7%AE%A1%E7%90%86%E5%91%BD%E4%BB%A4/2021.09.26-22:47:52-image-20210926224750958.png)

当我们对规则进行了修改以后，如果想要修改永久生效，必须使用service iptables save保存规则，当然，如果你误操作了规则，但是并没有保存，那么使用service iptables restart命令重启iptables以后，规则会再次回到上次保存/etc/sysconfig/iptables文件时的模样。

**centos7中**，已经不再使用init风格的脚本启动服务，而是使用unit文件，所以，在centos7中已经不能再使用类似service iptables start这样的命令了，所以service iptables save也无法执行，同时，在centos7中，使用firewall替代了原来的iptables service，不过不用担心，我们只要通过yum源安装iptables与iptables-services即可（iptables一般会被默认安装，但是iptables-services在centos7中一般不会被默认安装），在centos7中安装完iptables-services后，即可像centos6中一样，通过service iptables save命令保存规则了，规则同样保存在/etc/sysconfig/iptables文件中。

**方法一**

此处给出centos7中配置iptables-service的步骤

```
##配置好yum源以后安装iptables-service
## yum install -y iptables-services
##停止firewalld
## systemctl stop firewalld
##禁止firewalld自动启动
## systemctl disable firewalld
##启动iptables
## systemctl start iptables
##将iptables设置为开机自动启动，以后即可通过iptables-service控制iptables服务
## systemctl enable iptables
```

**方法二**

还可以使用另一种方法保存iptables规则，就是使用iptables-save命令

使用iptables-save并不能保存当前的iptables规则，但是可以将当前的iptables规则以”保存后的格式”输出到屏幕上。

所以，我们可以使用iptables-save命令，再配合重定向，将规则重定向到/etc/sysconfig/iptables文件中即可。

iptables-save > /etc/sysconfig/iptables

我们也可以将/etc/sysconfig/iptables中的规则重新载入为当前的iptables规则，但是注意，未保存入/etc/sysconfig/iptables文件中的修改将会丢失或者被覆盖。

使用iptables-restore命令可以从指定文件中重载规则，示例如下

iptables-restore < /etc/sysconfig/iptables

再次提醒：重载规则时，现有规则将会被覆盖。

## 命令小结

为方便复习将常用命令做了总结

### 添加规则

在指定表的指定链的尾部添加一条规则，-A选项表示在对应链的末尾添加规则，省略-t选项时，表示默认操作filter表中的规则

```bash
命令语法：iptables -t 表名 -A 链名 匹配条件 -j 动作

示例：iptables -t filter -A INPUT -s 192.168.1.146 -j DROP
```

在指定表的指定链的首部添加一条规则，-I选型表示在对应链的开头添加规则

```
命令语法：iptables -t 表名 -I 链名 匹配条件 -j 动作

示例：iptables -t filter -I INPUT -s 192.168.1.146 -j ACCEPT
```

在指定表的指定链的指定位置添加一条规则

```bash
命令语法：iptables -t 表名 -I 链名 规则序号 匹配条件 -j 动作

示例：iptables -t filter -I INPUT 5 -s 192.168.1.146 -j REJECT
```

设置指定表的指定链的默认策略（默认动作），并非添加规则。

```
命令语法：iptables -t 表名 -P 链名 动作

示例：iptables -t filter -P FORWARD ACCEPT
```

上例表示将filter表中FORWARD链的默认策略设置为ACCEPT

### 删除规则

注意点：如果没有保存规则，删除规则时请慎重

按照规则序号删除规则，删除指定表的指定链的指定规则，-D选项表示删除对应链中的规则。

```
命令语法：iptables -t 表名 -D 链名 规则序号

示例：iptables -t filter -D INPUT 3
```

上述示例表示删除filter表中INPUT链中序号为3的规则。

按照具体的匹配条件与动作删除规则，删除指定表的指定链的指定规则。

```
命令语法：iptables -t 表名 -D 链名 匹配条件 -j 动作

示例：iptables -t filter -D INPUT -s 192.168.1.146 -j DROP
```

上述示例表示删除filter表中INPUT链中源地址为192.168.1.146并且动作为DROP的规则。

删除指定表的指定链中的所有规则，-F选项表示清空对应链中的规则，执行时需三思。

```
命令语法：iptables -t 表名 -F 链名

示例：iptables -t filter -F INPUT
```

删除指定表中的所有规则，执行时需三思。

```
命令语法：iptables -t 表名 -F

示例：iptables -t filter -F
```

### 修改规则

注意点：如果使用-R选项修改规则中的动作，那么必须指明原规则中的原匹配条件，例如源IP，目标IP等。

修改指定表中指定链的指定规则，-R选项表示修改对应链中的规则，使用-R选项时要同时指定对应的链以及规则对应的序号，并且规则中原本的匹配条件不可省略。

```
命令语法：iptables -t 表名 -R 链名 规则序号 规则原本的匹配条件 -j 动作

示例：iptables -t filter -R INPUT 3 -s 192.168.1.146 -j ACCEPT
```

上述示例表示修改filter表中INPUT链的第3条规则，将这条规则的动作修改为ACCEPT， -s 192.168.1.146为这条规则中原本的匹配条件，如果省略此匹配条件，修改后的规则中的源地址可能会变为0.0.0.0/0。

其他修改规则的方法：先通过编号删除规则，再在原编号位置添加一条规则。

修改指定表的指定链的默认策略（默认动作），并非修改规则，可以使用如下命令。

```
命令语法：iptables -t 表名 -P 链名 动作

示例：iptables -t filter -P FORWARD ACCEPT
```

上例表示将filter表中FORWARD链的默认策略修改为ACCEPT

### 保存规则

保存规则命令如下，表示将iptables规则保存至/etc/sysconfig/iptables文件中，如果对应的操作没有保存，那么当重启iptables服务以后

```
service iptables save
```

注意点：centos7中使用默认使用firewalld，如果想要使用上述命令保存规则，需要安装iptables-services，具体配置过程请回顾上文。

或者使用如下方法保存规则

```
iptables-save > /etc/sysconfig/iptables
```

可以使用如下命令从指定的文件载入规则，注意：重载规则时，文件中的规则将会覆盖现有规则。

```
iptables-restore < /etc/sysconfig/iptables
```