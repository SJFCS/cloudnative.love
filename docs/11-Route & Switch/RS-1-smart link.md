---
title: RS-Smart-link
date: '2020/08/13 20:45:48'
update: 2020/09/27
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
H3C华为私有

定义：针对`双上行`组网的解决方案，实现高可靠链路冗余和故障切换

优势：故障切换厘秒级

运行机制：双上行端两个口组成一个Smart-link组，配置主备端口。故障时自动切换，恢复后仍保持不重新抢占主备，默认不角色抢占和自动回切

:::

### 交换机收到SmartLink的flush报文后是如何处理的

交换机收到SmartLink的flush报文后，会对报文中的密码进行检查，若与端口下配置的控制VLAN以及密码相同，则清除设备上的MAC表项，否则将flush报文丢弃。

如果接口下配置了**smart-link flush receive**命令，且该命令中的控制VLAN与接收flush报文中的控制VLAN相同，则清除该接口下的MAC表项。