---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
toc: true
title: 链路聚合
---

<!--more-->

# EVPN

在VXLAN分布式网关部署的场景下，数据包封装过程如下：

根据报文的入接口找到对应的二层广播域，然后找到绑定该广播域VBDIF接口的L3VPN实例。

根据报文的目的IP地址，查找该L3VPN实例下的路由表，获取该路由对应的三层VNI，以及下一跳地址。

根据出接口是VXLAN隧道，判断需要进行VXLAN封装：

- 根据VXLAN隧道的目的IP和源IP地址，获取对应的MAC地址，并将内层目的MAC和源MAC替换。
- 将三层VNI封装到报文中。
- 外层封装VXLAN隧道的目的IP和源IP地址，源MAC地址为Leaf1的NVE1接口MAC地址，目的MAC地址为网络下一跳的MAC地址。

传统大二层协议：![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595169836696-d7a337e9-63f0-448d-bf48-0059bc19e57b.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595170877333-9007b086-c83c-4f68-a9e6-2ffb82827c8b.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595171027755-9326b6b4-dbdf-4032-a50c-f93b8afad27d.png)查看邻居

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595171055179-2bd87bc4-bd16-4500-be7d-dcacfea4d5a6.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595171090829-0e4950f0-8471-477f-befa-a971fac466ca.png)查看隧道状态

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595171177719-437c74c9-61ca-43b4-8c5e-9ed56e59f1e7.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595172237435-af563a07-bae1-4a40-8565-05a4133dec17.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595172248353-d5efee92-a7c6-43ae-92b0-3658e4bff1d7.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595172256072-a0d6c713-df39-4e39-a64e-069efbe8f68f.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595172262686-1e3f461a-c8bf-4d2d-b242-8308d6c01db0.png)

![image.png](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/EVPN.assets/2021.03.09-17:30:41-1595172294403-76dc0cb3-9dbe-41f2-8180-990211ef513d.png)