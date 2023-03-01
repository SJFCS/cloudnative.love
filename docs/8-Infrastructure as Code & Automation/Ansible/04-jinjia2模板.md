---
title: jinjia2
sidebar_position: 4
---





## 根据不同内存生成不同mancache配置文件

memcached配置模板文件如下 memcached.j2

```
PORT="11211"
USER="memcached"
MAXCONN="1024"
#根据内存状态生成不同配置（支持+—*/运算）
CACHESIZE="{{ ANSIBLE_MEMTOTAL_MB //2 }}"
OPTIIONS=""
```













## Jinjia2

![image-20210823102911563](D:\ac\08-实践案例\image-20210823102911563.png)

![image-20210823103842950](D:\ac\08-实践案例\image-20210823103842950.png)

**渲染nginx**

![image-20210823103948088](D:\ac\08-实践案例\image-20210823103948088.png)

![image-20210823104038296](D:\ac\08-实践案例\image-20210823104038296.png)

**渲染keepalive**

![image-20210823105227657](D:\ac\08-实践案例\image-20210823105227657.png)

![image-20210823105717827](D:\ac\08-实践案例\image-20210823105717827.png)

![image-20210823105746117](D:\ac\08-实践案例\image-20210823105746117.png)

![image-20210823105854384](D:\ac\08-实践案例\image-20210823105854384.png)

第二种两个配置文件

![image-20210823105933930](D:\ac\08-实践案例\image-20210823105933930.png)

jinjia2

 ![image-20210823110634559](D:\ac\08-实践案例\image-20210823110634559.png)