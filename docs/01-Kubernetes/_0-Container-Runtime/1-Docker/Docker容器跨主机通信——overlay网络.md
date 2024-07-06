---
title: Docker Overlay跨主机通信
tags:
  - posts
categories:
  - Docker
series: 
  - 
lastmod: '2020-02-07'

featuredImage: 
authors: zhuanzai
draft: false
toc: true
---

## 一、Docker主机间容器通信的解决方案

<!--more-->

　　**Docker网络驱动**

1. Overlay: 基于VXLAN封装实现Docker原生Overlay网络

2. Macvlan: Docker主机网卡接口逻辑上分为多个子接口，每个子接口标识一个VLAN。容器接口直接连接<u>Docker</u>主机

3. 网卡接口: 通过路由策略转发到另一台Docker主机
   
   　**第三方网络项目**

　　   隧道方案

　　　　-- Flannel: 支持UDP和VLAN封装传输方式

        -- Weave: 支持UDP（sleeve模式）和 VXLAN（优先fastdb模式）

        -- OpenvSwitch: 支持VXLAN和GRE协议

       路由方案

        Calico: 支持BGP协议和IPIP隧道。每台宿主机作为虚拟路由，通过BGP协议实现不同主机容器间通信　

## 二、Docker Overlay Network

　　Overlay网络是指在不改变现有网络基础设施的前提下，通过某种约定通信协议，把二层报文封装在IP报文之上的新的数据格式。这样不但能够充分利用成熟的IP路由协议进程数据分发；而且在Overlay技术中采用扩展的隔离标识位数，能够突破VLAN的4000数量限制支持高达16M的用户，并在必要时可将广播流量转化为组播流量，避免广播数据泛滥。

　　因此，Overlay网络实际上是目前最主流的容器跨节点数据传输和路由方案。

　　**要想使用Docker原生Overlay网络，需要满足下列任意条件**

- Docker 运行在Swarm
- 使用键值存储的Docker主机集群

## 三、使用键值存储搭建Docker主机集群

　　需满足下列条件：

- 集群中主机连接到键值存储，Docker支持 Consul、Etcd和Zookeeper
- 集群中主机运行一个Docker守护进程
- 集群中主机必须具有唯一的主机名，因为键值存储使用主机名来标识集群成员
- 集群中linux主机内核版本在3.12+,支持VXLAN数据包处理，否则可能无法通行

## 四、部署

　　**4.1 系统环境**

　　![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled.assets/2021.03.09-17:31:40-1594534003607-9359406c-c31b-43e4-9187-dd99561009d8.png)

　　**4.2 安装Consul**

```
# wget https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_386.zip

# unzip consul_1.0.6_linux_amd64.zip

# mv consul /usr/bin/ && chmod a+x /usr/bin/consul

# 启动
nohup consul agent -server -bootstrap -ui -data-dir /data/docker/consul \
> -client=172.16.200.208 -bind=172.16.200.208 &> /var/log/consul.log &

#-ui : consul 的管理界面
#-data-dir : 数据存储
```

　　**4.3 节点配置Dockre守护进程连接Consul**

　　在两台机器上都要修改

    docker2

```
# vim /lib/systemd/system/docker.service

ExecStart=/usr/bin/dockerd  -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://172.16.200.208:8500 --cluster-advertise 172.16.200.208:2375

# systemctl daemon-reload

# systemctl restart docker
```

　　docker3

```
# vim /lib/systemd/system/docker.service

ExecStart=/usr/bin/dockerd  -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://172.16.200.208:8500 --cluster-advertise 172.16.200.223:2375

# systemctl daemon-reload

# systemctl restart docker
```

　　**4.4 查看consul 中的节点信息**　　![image](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled.assets/2021.03.09-17:31:40-1594534003534-ed86257f-af32-4fde-a4c2-8bbc857ea15c.png)

　　**4.5 创建overlay网络**　　

```
# docker network create -d overlay multi_host
53b042104f366cde2cc887e7cc27cde52222a846c1141690c93e1e17d96120c5

# docker network ls


NETWORK ID          NAME                  DRIVER              SCOPE
3f5ff55c93e6        bridge                bridge              local
1e3aff32ba48        composelnmp_default   bridge              local
0d60b988fe59        composetest_default   bridge              local
b4cf6d623265        host                  host                local
53b042104f36        multi_host
```

　　-d : 指定创建网络的类型

　　另一台机器会自动同步新建的网络

　　详细信息

```
# docker network inspect multi_host
[
    {
        "Name": "multi_host",
        "Id": "53b042104f366cde2cc887e7cc27cde52222a846c1141690c93e1e17d96120c5",
        "Created": "2018-03-07T16:23:38.682906025+08:00",
        "Scope": "global",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.0.0.0/24",
                    "Gateway": "10.0.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

　　**4.6 使用overlay网络启动容器**

　　分别在两台机器上使用overlay网络启动一个容器

\# docker run -it --net=multi_host busybox

　　这两个节点上的容器的ip分别为：　

```
[root@docker2 ~]``# docker run -it --net=multi_host busybox``/` `# ifconfig``eth0   Link encap:Ethernet HWaddr ``02``:``42``:``0A``:``00``:``00``:``02``     ``inet addr:``10.0``.``0.2`  `Bcast:``10.0``.``0.255`  `Mask:``255.255``.``255.0``     ``UP BROADCAST RUNNING MULTICAST MTU:``1450`  `Metric:``1``     ``RX packets:``0` `errors:``0` `dropped:``0` `overruns:``0` `frame:``0``     ``TX packets:``0` `errors:``0` `dropped:``0` `overruns:``0` `carrier:``0``     ``collisions:``0` `txqueuelen:``0``     ``RX bytes:``0` `(``0.0` `B) TX bytes:``0` `(``0.0` `B)
```

```
/` `# ifconfig``eth0   Link encap:Ethernet HWaddr ``02``:``42``:``0A``:``00``:``00``:``03``     ``inet addr:``10.0``.``0.3`  `Bcast:``10.0``.``0.255`  `Mask:``255.255``.``255.0``     ``UP BROADCAST RUNNING MULTICAST MTU:``1450`  `Metric:``1``     ``RX packets:``0` `errors:``0` `dropped:``0` `overruns:``0` `frame:``0``     ``TX packets:``0` `errors:``0` `dropped:``0` `overruns:``0` `carrier:``0``     ``collisions:``0` `txqueuelen:``0``     ``RX bytes:``0` `(``0.0` `B) TX bytes:``0` `(``0.0` `B)
```

　　它们之间是可以相互ping 通的

```
# ping 10.0.0.2``PING ``10.0``.``0.2` `(``10.0``.``0.2``): ``56` `data bytes``64` `bytes ``from` `10.0``.``0.2``: seq``=``0` `ttl``=``64` `time``=``11.137` `ms``64` `bytes ``from` `10.0``.``0.2``: seq``=``1` `ttl``=``64` `time``=``0.251` `ms``64` `bytes ``from` `10.0``.``0.2``: seq``=``2` `ttl``=``64` `time``=``0.280` `ms
```