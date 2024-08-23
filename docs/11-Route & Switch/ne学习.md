---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
toc: true
title: h3cne学习
---

## ip路由

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592184845029-c3d5cb0a-ba85-41f1-9a67-e93647eacf46.png)

### 查看ip路由表摘要

[Router]display ip routing-table

### 查看符合指定目的地址的路由信息

[Router] display ip routing-table ip-address [ mask-length Imask]

### 查看路由表的统计信息

[Router] display ip routing-table statistics

## 单臂路由

```
[RTA]interface GigabitEthernet0/0
[RTA-GigabitEthernet0/0]ip address 10.1.1.1 255.255.255.0
[RTA-GigabitEthernet0/0]interface GigabitEthernet0/0.2
[RTA-GigabitEthernet0/0.2]vlan-type dotlq vid 2
[RTA-GigabitEthernet0/0.2]ip address 10.1.2.1 255.255.255.0
[RTA-GigabitEthernet0/0.2]interface GigabitEthernet0/0.3
[RTA-GigabitEthernet0/0.3]vlan-type dotlq vid 3
[RTA-GigabitEthernet0/0.3]ip address 10.1.3.1 255.255.255.0
```

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592185107870-4c926f99-7dd0-43f8-a4d9-87fc65f93800.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592185228027-948f74f6-ad0a-4170-aebe-fded638993d1.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592189295753-0c0ff7ae-be6d-490c-8749-91a64605c3d2.png)

## rip配置

### 创建RIP进程并进入RIP视图

[Router] rip[process-id]

### 在指定网段接口上使能RIP

[Router-rip-1] network network-address [ wildcard-mask]

## 配置接口工作在抑制状态

[Router-rip-1] silent-interface { interface-type

interface-number|all}

## 使能RIP水平分割功能

[Router-Ethernet1/0] rip split-horizon

## 使能RIP毒性逆转功能

[Router-Ethernet1/0] rip poison-reverse

# RIPV2配置

### 指定全局RIP版本

[Router-rip-1]version{1|2}

### 关闭RIPv2自动路由聚合功能

[Router-rip-1] undo summary

### 配置RIPv2报文的认证

[Router-Ethernet1/0] **rip authentication-mode**{**md5**{**rfc2082**{**cipher** cipher-string | **plain** plain-string}key-id | **rfc2453**{**cipher** cipher-string | **plain** plain-string}} | **simple**{**cipher** cipher-string **plain** plain-string}}

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592191468228-542d4313-3a98-437b-a499-734a751a3a27.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592191485890-9a9abf92-7090-40f2-b9b3-f00ce630cb20.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592191519390-aeca3fea-4d37-4866-851f-5c50c209bf0b.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592191508075-a6beefa2-2e82-42f8-848f-1207e4b4a508.png)

## rip宣告网段

```
[H3C]rip
[H3C-rip-1]ver 2
[H3C-rip-1]network 172.16.0.0
[H3C-rip-1]network 172.16.1.0
[H3C-rip-1]network 192.168.1.1
[H3C-rip-1]display  this
#
rip 1
 version 2
 network 172.16.0.0 //172.16.1.0不带子网掩码 rip认为是同网段
 network 192.168.1.0
#
return
```

## 链接业务网段接口 rip ospf静默接口

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592199865195-075c5daa-1bf9-44bb-8461-11ff786fdaa2.png)

## rip接口密码 ：R1、R2两接口相同密码

```
[H3C-rip-1]int g0/0
[H3C-GigabitEthernet0/0]rip a
[H3C-GigabitEthernet0/0]rip authentication-mode si
[H3C-GigabitEthernet0/0]rip authentication-mode simple 123
```

# 理论

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592189958754-5f8f7605-fce7-4f7c-be86-64b3eed5da7d.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592190019109-1ae270a2-768c-401f-82f8-3fe0210a97fb.png)

rip1路由计时器

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592190709768-2092e45a-9e19-4a2d-89fc-410fc39643c3.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592191202944-9c8f830a-cce9-4c1c-ac43-88884e118581.png)

## RIPV2组播地址

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592192628353-7374d032-f96a-4545-9503-799a0014e64e.png)

## ospf

https://www.bilibili.com/video/BV1SV411R77q?p=34 30min

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592229063909-ce689236-9886-4080-a57a-7ec9a2a814e1.png)

## acl

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592229739678-091b1427-36bf-4cab-bb5b-07446982d3d9.png)

undo rule ID

undo local-user asdadasdsdasda class manage

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592294416558-c687a230-62fb-478b-80b9-c5d1a9f9338a.png)

# acl2 39：00

# ftp

[H3C]ftp se e

[H3C]local-user wdy

New local user added.

[H3C-luser-manage-wdy]password simple 123

[H3C-luser-manage-wdy]service-type ftp

[H3C-luser-manage-wdy]authorization-attribute user-role level-15

[H3C-luser-manage-wdy]qu

# ppp2 17 实验 mp

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592545223523-66f7fd06-bdb6-47e9-b29d-14bbf0906fda.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ne%E5%AD%A6%E4%B9%A0.assets/2021.03.09-17:30:25-1592545454067-6890fa87-9d66-4270-b3a3-7f9be0bd4c77.png)引入默认路由到ospf