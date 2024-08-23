---
categories:
  - blog
  - posts
  - RS路由交换
  - 未发布
---

## ospf引入外部静态路由](https://www.cnblogs.com/liujunjun/p/12976910.html)

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/ospf%E5%BC%95%E5%85%A5%E5%A4%96%E9%83%A8%E8%B7%AF%E7%94%B1/2021.03.09-16:44:05-1580705-20200527213819729-1110964306.png)

AR1配置

```
ospf 1 router-id 1.1.1.1 
 area 0.0.0.1 
  network 10.1.12.0 0.0.0.255 
```

AR2配置

```
ospf 1 router-id 2.2.2.2 
 area 0.0.0.0 
  network 10.1.23.0 0.0.0.255 
 area 0.0.0.1 
  network 10.1.12.0 0.0.0.255 
```

AR3配置

```
ospf 1 router-id 3.3.3.3 
 import-route static
 area 0.0.0.0 
  network 10.1.23.0 0.0.0.255 
#
ip route-static 10.4.1.0 255.255.255.0 10.1.34.4
```

AR4配置

```
ip route-static 0.0.0.0 0.0.0.0 10.1.34.3
```

测试

```
<AR1>ping 10.4.1.1
  PING 10.4.1.1: 56  data bytes, press CTRL_C to break
    Reply from 10.4.1.1: bytes=56 Sequence=1 ttl=253 time=30 ms
    Reply from 10.4.1.1: bytes=56 Sequence=2 ttl=253 time=40 ms
    Reply from 10.4.1.1: bytes=56 Sequence=3 ttl=253 time=30 ms
    Reply from 10.4.1.1: bytes=56 Sequence=4 ttl=253 time=30 ms
    Reply from 10.4.1.1: bytes=56 Sequence=5 ttl=253 time=20 ms

  --- 10.4.1.1 ping statistics ---
    5 packet(s) transmitted
    5 packet(s) received
    0.00% packet loss
    round-trip min/avg/max = 20/30/40 ms

<AR1>
```

```
<AR3>dis ospf lsdb ase self-originate

     OSPF Process 1 with Router ID 3.3.3.3
         Link State Database


  Type      : External
  Ls id     : 10.4.1.0
  Adv rtr   : 3.3.3.3  
  Ls age    : 1475 
  Len       : 36 
  Options   :  E  
  seq#      : 80000001 
  chksum    : 0xe6ce
  Net mask  : 255.255.255.0 
  TOS 0  Metric: 1 
  E type    : 2
  Forwarding Address : 0.0.0.0 
  Tag       : 1 
  Priority  : Low
```