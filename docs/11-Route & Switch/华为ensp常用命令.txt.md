---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
title: 华为常用命令
---

<!--more-->

DIS MAC -ADDRESS

language-mode  chinese  提示语言该为中文

undo info-center enable                免打扰

port link-type access         设置access口
port default vlan 10           绑定vlan 10
port link-type trunk           设置端口为trunk口
port trunk allow-pass vlan all          端口允许所有vlan通过
dhcp select global              设置端口为全局模式

中继
dhcp select relay                              
dhcp relay server-select                    要从中继到达的名称
dhcp relay server-ip 10.1.1.2            要从中继到达的ip地址

dhcp enable                       开启dhcp功能
ip pool pcy1                      设置dhcp地址池名称为“pcy1”
network 192.168.10.0 mask 24      设置地址池ip地址及网段
gateway-list 192.168.10.254          设置地址池网关
dns-list 8.8.8.8                                设置dns服务器地址       

(1) 配置地址池（转换后的）
[R1]nat address-group 1 220.173.141.1 220.173.141.3 

(2) 配置ACL（列出允许进行NAT转换的内部IP地址） 
[R1]acl 2001     //建立一个标准ACL,序号应在2000至2009之间
[R1-acl-basic-2001]rule 10 permit source 192.168.2.0 0.0.0.255 
[R1-acl-basic-2001]rule 20 permit source 192.168.3.0 0.0.0.255 
[R1-acl-basic-2001]rule 30 deny source any     //此命令可以省略 

 (3) 在出接口进行NAT转换 
[R1]int g0/0/1 
[R1-GigabitEthernet0/0/1]nat outbound 2001 address-group 1 

VRRP 命令
dis vrrp brief                                                                                                      查看VRRP备份组

[RouterA] interface gigabitethernet 2/0/0                                                         进入数据入口
[RouterA-GigabitEthernet2/0/0] vrrp vrid 1 virtual-ip 10.1.1.111                       设备VRRP备份组1 设置网关地址
[RouterA-GigabitEthernet2/0/0] vrrp vrid 1 priority 120                                    置优先级 默认100
[RouterA-GigabitEthernet2/0/0] vrrp vrid 1 preempt-mode timer delay 20      并配置抢占时间20秒
[RouterA-GigabitEthernet2/0/0] quit

链路聚合命令
int Eth-Trunk 1  创建eth-trunk 
trunkport GigabitEthernet 0/0/1 to 0/0/3  将端口放入eth-trunk
[SwitchA-Eth-Trunk1] port link-type trunk          
[SwitchA-Eth-Trunk1] port trunk allow-pass vlan 10 20   配置Eth-Trunk1接口允许VLAN10和VLAN20通过。  二边设备都要配置
[SwitchA-Eth-Trunk1] load-balance src-dst-mac             配置Eth-Trunk1的负载分担方式。             二边都要配置

PPP点对点协议
[Huawei]int Serial 0/0/1  一定要用串行端口
[Huawei-Serial0/0/0]link-protocol     ppp  当前接口的链路层配置为PPP
[Huawei-Serial0/0/0]ip add 10.1.1.1   30
[Huawei-Serial0/0/0]remote address 10.0.0.2   指定分配给对端接口的IP地址
[Huawei-Serial0/0/0]ip add ppp-negotiate     希望对端对端接口分配一个IP地址给自己

rip
[RouterA] rip
[RouterA-rip-1] network 192.168.1.0（路由器所包含的网段）
[RouterA-rip-1] version 2
rip input命令用来控制允许指定接口接收RIP报文。
undo rip input命令用来禁止指定接口接收RIP报文。
缺省情况下，接口可以接收RIP报文。

ospf命令
display ospf abr-asbr   查看RouterC的ABR/ASBR信息
display ospf routing      查看RouterC的OSPF路由表
router id 2.2.2.2            创建router id
ospf                              开启ospf
[RouterB-ospf-1] area 0    创建域
network 192.168.1.0 0.0.0.255  宣明所有网段
