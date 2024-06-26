---
title: Keepalivedp高可用部署方式
tags:
  - posts
categories:
  - 负载均衡
series: 
  - Keepalived
lastmod: '2021-07-07'
featuredImage: 
authors: songjinfeng
draft: false
toc: true
---

<!--more-->

## keepalive简介

　　keepalived相对corosync+pacemaker这种高可用集群，它要轻量很多；它的工作原理就是vrrp的实现；vrrp（Virtual Router Redundancy  Protocol，虚拟路由冗余协议 ），设计之初它主要用于对LVS集群的高可用，同时它也能够对LVS后端real  server做健康状态检测；它主要功能有基于vrrp协议完成地址流动，从而实现服务的故障转移；为VIP地址所在的节点生成ipvs规则；为ipvs集群的各RS做健康状态检测；基于脚本调用接口通过执行脚本完成脚本中定义的功能，进而影响集群事务；

## HA配置

对比keepalive的master与backup配置的区别

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
set from=839646120@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=839646120@qq.com
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









