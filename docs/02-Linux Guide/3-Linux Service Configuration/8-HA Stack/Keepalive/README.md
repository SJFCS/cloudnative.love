---
title: Keepalive
tags: [Service Proxy & Ingress Gateway,Keepalive]
---

- https://www.keepalived.org/pdf/UserGuide.pdf
- https://github.com/tencentyun/qcloud-documents/blob/master/product/%E8%AE%A1%E7%AE%97%E4%B8%8E%E7%BD%91%E7%BB%9C/%E7%A7%81%E6%9C%89%E7%BD%91%E7%BB%9C2018-09-13/%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5/VPC%20%E5%86%85%E9%80%9A%E8%BF%87%20keepalived%20%E6%90%AD%E5%BB%BA%E9%AB%98%E5%8F%AF%E7%94%A8%E4%B8%BB%E5%A4%87%E9%9B%86%E7%BE%A4.md
- keepalived.org/pdf/sery-lvs-cluster.pdf
```
有些云厂商不支持arp 无法使用keepalived 




BGP（边界网关协议）是一种广泛用于互联网中的路由协议，它可以用于实现跨多个自治系统（AS）的网络间路由选择。BGP可以使得不同的自治系统之间互相了解路由信息，并通过选择最佳路径来进行路由选择。

在使用BGP实现高可用性时，可以使用BGP协议来在多个负载均衡器之间同步VIP地址，并且在一个负载均衡器故障时，可以使用BGP协议将VIP地址转移到备用负载均衡器上。

BGP协议的实现需要一定的技术和经验，并且需要与云厂商的网络架构相匹配，因此在实施BGP协议之前，需要仔细评估其可行性，并根据实际情况进行调整和修改。

宋
案例
以下是一个使用BGP实现高可用性的案例：

假设有两个位于不同地理位置的数据中心，每个数据中心都有一台负载均衡器用于管理应用程序的流量。这两个数据中心通过互联网相连，使用BGP协议进行路由选择。

为了实现高可用性，可以在两个数据中心之间同步VIP地址，并在一个数据中心的负载均衡器发生故障时，将VIP地址转移到另一个数据中心的备用负载均衡器上。

具体实现步骤如下：

在每个数据中心的负载均衡器上配置BGP，将VIP地址发布到BGP路由表中。

在两个数据中心之间建立BGP对等体，使得两个数据中心的BGP路由表可以互相同步。

在两个数据中心之间配置IP隧道（或VPN），以便将数据中心之间的网络流量安全地传输。

在每个数据中心的防火墙上配置规则，允许BGP流量和隧道流量通过。

在每个数据中心的VIP地址所在的子网中配置故障切换机制，以便在一个数据中心的负载均衡器发生故障时，将VIP地址转移到另一个数据中心的备用负载均衡器上。

测试高可用性方案，确保在一个数据中心的负载均衡器发生故障时，流量可以自动切换到另一个数据中心的备用负载均衡器上。

这是一个基本的BGP实现高可用性的案例，具体实现可能会因为不同的网络架构和技术选型而有所不同。
```
# [Keepalive](https://github.com/acassen/keepalived)
## keepalive 简介
Keepalive 是一个负载均衡与高可用组件，
它的负载均衡框架基于 LVS(IPVS) 实现，提供了第四层的负载均衡，另外它还实现了一组健康检查机制持续地检查各个 workload 的健康情况。
基于 VRRP 协议（Virtual Router Redundancy  Protocol，虚拟路由冗余协议 ）完成地址流动，从而实现服务的故障转移。

## HA配置

对比 keepalive 的 master 与 backup 配置的区别

| VIP 10.50.1.100 | Master            | Backup            |
| --------------- | ----------------- | ----------------- |
| route_id        | node1_10.50.1.101 | node2_10.50.1.103 |
| state           | MASTER            | BACKUP            |
| priority        | 150               | 100               |
| mcast_src_ip    | 10.50.1.101       | 10.50.1.103       |

**keepalive配置示例**

```bash
! Configuration File for keepalived

global_defs {
   router_id node1_10.50.1.101
   
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
#  vrrp_iptables
#  script_user root
#  enable_script_security
}

vrrp_script chk_service {
    script "/etc/keepalived/check_script.sh nginx"
    interval 5
#    weight -25
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 50
    priority 150
    advert_int 1
    mcast_src_ip 10.50.1.101
    nopreempt

#    unicast_src_ip XX.XX.XX.XX
#    unicast_peer {
#        XX.XX.XX.XX
#    }

    authentication {
        auth_type PASS
        auth_pass 11111111
    }
    track_script {
         chk_service
    }
    virtual_ipaddress {
        10.50.1.100
    }
}


```

## vrrp组播单播

如果两节点的上联交换机允许组播，采用组播模式（默认）

```bash
vrrp_instance VI_1 {
mcast_src_ip  xx.xx.xx.xx  # 发送多播包的地址，如果不设置默认使用绑定网卡的primary ip
}
```

如果两节点的上联交换机禁用了组播，则只能采用vrrp单播通告的方式

```bash
global_defs {
#  vrrp_strict # 严格模式不支持单播
}

vrrp_instance VI_1 {
    unicast_src_ip XX.XX.XX.XX  ## souce ip
    unicast_peer {
        XX.XX.XX.XX             ## dest ip
    }
}
```

## 抢占模式 

keepalived中的健康检查脚本，抢占式，仅需在master配置。非抢占式，master，backup都需要配置。

默认为抢占式，配置非抢占式加入如下参数：

```bash
vrrp_instance VI_1 {
nopreempt
    }
```

## 健康检查配置

>检测脚本要写在vrrp_instance的前面，trace_script要定在vip的后面

通常keepalive搭配Nginx等服务结合使用，一旦Nginx等服务宕机，会导致用户请求失败，但keepalive并不会切换，所以需要使用健康检查来检测Nginx等服务的状态。此处选用脚本健康检查的方式，配置如下

**健康检查脚本**

```bash
#使用方法：
#在keepalived的配置文件中
#vrrp_script check_port {#创建一个vrrp_script脚本,检查配置
#script "/etc/keepalived/check_port.sh 6379" #配置监听的端口
#interval 2 #检查脚本的频率,单位（秒）注意：脚本执行时间不能超过此参数，否则会被中断再次运行脚本
#}


# 服务/端口检测

#!/bin/bash
# ps aux | grep nginx | grep -v grep | wc -l
# ps -C nginx --no-header|wc -l

#判断Nginx是否存活，如果不存活尝试启动nginx
CHK=$1
if [ `ss -lntp| grep $CHK  -wc ` -eq 0 ];then
	systemctl start nginx
	sleep 3
	#等待3秒后再次检测nginx状态，如果nginx还不存活则停止keepalived，让VIP就行漂移
	if [ `ss -lntp| grep $CHK  -wc ` -eq 0 ]; then
		systemctl stop keepalived
	fi
fi
	

# 端口检测
CHK_PORT=$1
if [ -n "$CHK_PORT" ];then
        PORT_PROCESS=`ss -lnt|grep $CHK_PORT|wc -l`
        if [ $PORT_PROCESS -eq 0 ];then
                echo "Port $CHK_PORT Is Not Used,End."
                exit 1
        fi
else
        echo "Check Port Cant Be Empty!"
fi

# URL检测
    CHECK_URL=$1
    CMD=`/usr/bin/curl -I ${CHECK_URL} 2>/dev/null | grep "200 OK" | wc -l`
    if [ ${CMD} -eq 1 ]; then
            echo "Succ: Check proxy ${CHECK_URL} is succeed."
        exit 0
    else
        echo "Fail: check proxy ${CHECK_URL} is failed."
        exit 1
    fi
```

## 邮件配置

一个高可用服务，应该具备当服务发生故障，能够第一时间做故障转移，从而保证服务的可用性，同时还应该第一时间通知管理员，以便管理员能够知道服务发生了转移，这样一来管理员也能第一时间去排查故障，让故障的节点在很短的时间重新上线，避免下次故障导致服务不可用；keepalived的故障通知邮件机制，是通过判断当前节点keepalived的角色来触发邮件通知；

```
　keepalived的邮件通知配置

    notification_email {...}：该指令用于应用一段邮件接收者的一个配置段，用大括号括起来，里面可以配置多个邮件接收者；

    notification_email_from：该指令用于指定邮件发出者的邮箱；

    smtp_server：该指令用于指定邮件服务器地址；

    smtp_connect_timeout：该指令用于指定连接邮件服务器的超时时长，默认30秒；

    notify_master：配置节点成为master角色的触发的动作；通常为执行一个脚本；

    notify_backup：配置节点角色转换为backup触发的动作；

    notify_fault：配置节点为失败状态触发的动作；
```

**部署 mailx**

```bash
yum install mailx -y
# 配置
vim /etc/mail.rc
set from=0000000@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=0000000@qq.com
set smtp-auth-password=jrztcrdgmomnbddd
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/

# 测试
echo "邮件正文" | mail -s "邮件主题" xxx@qq.com
发送文件的另外几种格式
其他邮件发送格式
cat file.txt | mail -s "邮件主题" xxx@163.com
mail -s "邮件主题" xxx@163.com < file.txt

```

**邮件脚本**

```bash
vim /etc/keepalived/mail_notify.sh

#!/bin/bash
contact=xxx@qq.com
notify() {
    mailsubject="$(hostname) to be $1, vip转移"
    mailbody="$(date +'%F %T'): vrrp transition, $(hostname) changed to be $1"
    echo "$mailbody" | mail -s "$mailsubject" $contact
}
case $1 in
master)
    notify master
    ;;
backup)
    notify backup
    ;;
fault)
    notify fault
    ;;
*)
    echo "Usage: $(basename $0) {master|backup|fault}"
    exit 1
    ;;
esac


chmod 777 /etc/keepalived/mail_notify.sh
```

keepalive配置

```bash
vim /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface enp0s3
    virtual_router_id 51
    priority 100
    advert_int 1
    #Keepalived进入MASTER状态执行脚本
    notify_master "/etc/keepalived/mail_notify.sh master"
    #Keepalived进入BACKUP状态执行脚本
    notify_backup "/etc/keepalived/mail_notify.sh backup"
    #Keepalived进入FAULT状态执行脚本
    notify_fault "/etc/keepalived/mail_notify.sh fault"
    authentication {
        auth_type PASS
        auth_pass 1111
    }
   track_script {
        chk_http_port
   }
    virtual_ipaddress {
        192.168.200.203
    }
}

```

## keepalived高可用故障脑裂

由于某些原因,导致两台 keepalived高可用服务器在指定的间内,无法检测到方的心跳消息,各自驭得资
源及服务的所有权,而此的的两台高可用服务器又都还活着

> 服务器网线松动等网络故障
> 服务器硬件故障发生损坏现象而崩溃
> 主备都开启 firewa1ld防火墙
> Nginx服务死掉等

(抢占模式)在BUCKUP上编写检测脚本试如果能ping通主并且备节点还有VIP的活则认为产生了列脑

```bash
cat check_split_brain.sh
#!/bin/bash

lb01_vip=10.50.1.100
lb01_ip=10.50.1.101
while true;do
ping -c 2 -W 3 $lb01_ip &>/dev/null
  if [ $? -eq 0 -a `ip add|grep "$lb01_vip"|wc -l` -eq 1 ];then
      echo "ha is split brain.warning."
  else
      echo "ha is ok"
  fi
sleep 5
done
```

## 配置参数

~~~
router_id                     #命名，比如填写:hd205_MySQL_1/2
nopreempt                     #非抢占模式，主填从不填  
interface                     #实际网卡名称
priority                      #表示优先级，数值越大者优先
auth_type                     #鉴权模式，一般填写PASS
auth_pass                     #根据实际填写密码
virtual_ipaddress             #虚拟的IP地址(VIP)，比如192.1.1.103
delay_loop                    ##每个2秒检查一次real_server状态
notify_down                   ##检测到服务down后执行的脚本 
connect_timeout               ##连接超时时间
nb_get_retry                  ##重连次数
delay_before_retry            ##重连间隔时间
connect_port                  ##健康检查端口 
notify_master /path/to/to_master.sh：#表示当切换到master状态时，要执行的脚本 
notify_backup /path_to/to_backup.sh：#表示当切换到backup状态时，要执行的脚本
notify_stop /path_to/to_stop.sh：#表示当切换到stop状态时，要执行的脚本
~~~









