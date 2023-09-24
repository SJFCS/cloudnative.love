所有的实验均结合keepalived


keepalived通过VRRP协议选举，按照权重大小挑选出一台MASTER机器，MASTER机器会被分配到一个指定的虚拟ip，外部程序可通过该ip访问这台服务器，如果这台服务器出现故障（断网，重启，或者本机器上的keepalived crash 有新的备份服务器加入且权重最大等），keepalived会从其他的备份机器上重选


## 全局定义
全局配置又包括两个子配置

- 全局定义(global definition)
- 静态路由配置(static ipaddress/routes)
```conf
# 全局定义(global definition) 
global_defs {                      
   notification_email {      
   acassen@firewall.loc     
   failover@firewall.loc
   sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc   
   smtp_server 192.168.200.1                         
   smtp_connect_timeout 30                                  
   router_id LVS_DEVEL     
}
notification_email: 表示keepalived在发生诸如切换操作时需要发送email通知以及email发送给哪些邮件地址邮件地址可以多个每行一个
notification_email_from admin@example.com: 表示发送通知邮件时邮件源地址是谁
smtp_server 127.0.0.1: 表示发送email时使用的smtp服务器地址这里可以用本地的sendmail来实现
smtp_connect_timeout 30: 连接smtp连接超时时间
router_id node1: 机器标识，通常配置主机名

# 静态地址和路由配置范例
static_ipaddress {
    192.168.1.1/24 brd + dev eth0 scope global
    192.168.1.2/24 brd + dev eth1 scope global
}
static_routes {
    src $SRC_IP to $DST_IP dev $SRC_DEVICE
    src $SRC_IP to $DST_IP via $GW dev $SRC_DEVICE
}
这里实际上和系统里面命令配置IP地址和路由一样例如
192.168.1.1/24 brd + dev eth0 scope global 相当于: ip addr add 192.168.1.1/24 brd + dev eth0 scope global
就是给eth0配置IP地址路由同理,一般这个区域不需要配置
这里实际上就是给服务器配置真实的IP地址和路由的在复杂的环境下可能需要配置一般不会用这个来配置我们可以直接用vi /etc/sysconfig/network-script/ifcfg-eth1来配置切记这里可不是VIP不要搞混淆了切记切记

```

## VRRPD配置

包括三个类:

- VRRP同步组(synchroization group)
- VRRP实例(VRRP Instance)
- VRRP脚本

```conf
# VRRP同步组(synchroization group)配置范例
vrrp_sync_group VG_1 {   //注意vrrp_sync_group  后面可自定义名称如lvs_httpd ,httpd
group {
http
mysql
}
notify_master /path/to/to_master.sh
notify_backup /path_to/to_backup.sh
notify_fault "/path/fault.sh VG_1"
notify /path/to/notify.sh
smtp_alert 
}
其中http和mysql是实例名和下面的实例名一致
notify_master /path/to/to_master.sh //表示当切换到master状态时要执行的脚本
notify_backup /path_to/to_backup.sh //表示当切换到backup状态时要执行的脚本
notify_fault "/path/fault.sh VG_1"  // keepalived出现故障时执行的脚本
notify /path/to/notify.sh  
smtp_alert           //表示切换时给global defs中定义的邮件地址发送邮件通知

# VRRP实例(instance)配置范例
vrrp_instance http {  //注意vrrp_instance 后面可自定义名称如lvs_httpd ,httpd
state MASTER
interface eth0
dont_track_primary
track_interface {
eth0
eth1
}
mcast_src_ip <IPADDR>
garp_master_delay 10
virtual_router_id 51
priority 100
advert_int 1
authentication {
auth_type PASS
autp_pass 1234
}
virtual_ipaddress {
#<IPADDR>/<MASK> brd <IPADDR> dev <STRING> scope <SCOPT> label <LABEL>
192.168.200.17/24 dev eth1
192.168.200.18/24 dev eth2 label eth2:1
}
virtual_routes {
# src <IPADDR> [to] <IPADDR>/<MASK> via|gw <IPADDR> dev <STRING> scope <SCOPE> tab
src 192.168.100.1 to 192.168.109.0/24 via 192.168.200.254 dev eth1
192.168.110.0/24 via 192.168.200.254 dev eth1
192.168.111.0/24 dev eth2
192.168.112.0/24 via 192.168.100.254
}
nopreempt
preemtp_delay 300
debug
}
```
state: state指定instance(Initial)的初始状态就是说在配置好后这台 服务器的初始状态就是这里指定的但这里指定的不算还是得要通过竞选通过优先级来确定里如果这里设置为master但如若他的优先级不及另外一台 那么这台在发送通告时会发送自己的优先级另外一台发现优先级不如自己的高那么他会就回抢占为master

interface: 实例绑定的网卡因为在配置虚拟VIP的时候必须是在已有的网卡上添加的

dont track primary: 忽略VRRP的interface错误

track interface: 跟踪接口设置额外的监控里面任意一块网卡出现问题都会进入故障(FAULT)状态例如用nginx做均衡器的时候内网必须正常工作如果内网出问题了这个均衡器也就无法运作了所以必须对内外网同时做健康检查

mcast src ip: 发送多播数据包时的源IP地址这里注意了这里实际上就是在那个地址上发送VRRP通告这个非常重要一定要选择稳定的网卡端口来发送这里相当于heartbeat的心跳端口如果没有设置那么就用默认的绑定的网卡的IP也就是interface指定的IP地址

garp master delay: 在切换到master状态后延迟进行免费的ARP(gratuitous ARP)请求，默认5s

virtual router id: 这里设置VRID这里非常重要相同的VRID为一个组他将决定多播的MAC地址

priority 100: 设置本节点的优先级优先级高的为master

advert int: 设置MASTER与BACKUP负载均衡之间同步即主备间通告时间检查的时间间隔,单位为秒，默认1s

virtual ipaddress: 这里设置的就是VIP也就是虚拟IP地址他随着state的变化而增加删除当state为master的时候就添加当state为backup的时候删除这里主要是有优先级来决定的和state设置的值没有多大关系这里可以设置多个IP地址

virtual routes: 原理和virtual ipaddress一样只不过这里是增加和删除路由

lvs sync daemon interface: lvs syncd绑定的网卡，类似HA中的心跳检测绑定的网卡

authentication: 这里设置认证

auth type: 认证方式可以是PASS或AH两种认证方式

auth pass: 认证密码

nopreempt: 设置不抢占master，这里只能设置在state为backup的节点上而且这个节点的优先级必须别另外的高，比如master因为异常将调度圈交给了备份serve，master serve检修后没问题，如果不设置nopreempt就会将调度权重新夺回来，这样就容易造成业务中断问题

preempt delay: 抢占延迟多少秒，即延迟多少秒后竞选master

debug：debug级别

notify master：和sync group这里设置的含义一样可以单独设置例如不同的实例通知不同的管理人员http实例发给网站管理员mysql的就发邮件给DBA

```
# VRRP脚本
# 如下所示为相关配置示例
vrrp_script check_running {
   script "/usr/local/bin/check_running"
   interval 10
   weight 10
}

vrrp_instance http {
   state BACKUP
   smtp_alert
   interface eth0
   virtual_router_id 101
   priority 90
   advert_int 3
   authentication {
   auth_type PASS
   auth_pass whatever
   }
   virtual_ipaddress {
   1.1.1.1
   }
   track_script {
   check_running 
   }
}
# 首先在vrrp_script区域定义脚本名字和脚本执行的间隔和脚本执行的优先级变更,如下所示:
vrrp_script check_running {
            script "/usr/local/bin/check_running"
            interval 10     #脚本执行间隔
            weight 10       #脚本结果导致的优先级变更10表示优先级+10-10则表示优先级-10
            }
# 然后在实例(vrrp_instance)里面引用有点类似脚本里面的函数引用一样先定义后引用函数名
track_script {
      check_running 
}
```


注意:
VRRP脚本(vrrp_script)和VRRP实例(vrrp_instance)属于同一个级别
keepalived会定时执行脚本并对脚本执行的结果进行分析，动态调整vrrp_instance的优先级。一般脚本检测返回的值为0，说明脚本检测成功，如果为非0数值，则说明检测失败
如果脚本执行结果为0，并且weight配置的值大于0，则优先级相应的增加, 如果weight为非0，则优先级不变
如果脚本执行结果非0，并且weight配置的值小于0，则优先级相应的减少, 如果weight为0，则优先级不变
其他情况，维持原本配置的优先级，即配置文件中priority对应的值。
这里需要注意的是：
1） 优先级不会不断的提高或者降低
2） 可以编写多个检测脚本并为每个检测脚本设置不同的weight
3） 不管提高优先级还是降低优先级，最终优先级的范围是在[1,254]，不会出现优先级小于等于0或者优先级大于等于255的情况
这样可以做到利用脚本检测业务进程的状态，并动态调整优先级从而实现主备切换。



## virtual_server 虚拟主机配置
关于keeplived的虚拟主机配置有三种如下所示
virtual server IP port
virtual server fwmark int
virtual server group string

以常用的第一种为例
virtual_server 192.168.1.2 80
含义:设置一个virtual server: VIP:Vport

delay_loop 3
含义:设置service polling的delay时间即服务轮询的时间间隔

lb_algo rr|wrr|lc|wlc|lblc|sh|dh
含义:设置LVS调度算法

lb_kind NAT|DR|TUN
含义:设置LVS集群模式

persistence_timeout 120
含义:设置会话保持时间秒为单位即以用户在120秒内被分配到同一个后端realserver,超过此时间就重新分配

persistence_granularity
含义:设置LVS会话保持粒度ipvsadm中的-M参数默认是0xffffffff即每个客户端都做会话保持

protocol TCP
含义:设置健康检查用的是TCP还是UDP

ha_suspend
含义:suspendhealthchecker’s activity

virtualhost
含义:HTTP_GET做健康检查时检查的web服务器的虚拟主机即host头

sorry_server
含义:设置backupserver就是当所有后端realserver节点都不可用时就用这里设置的也就是临时把所有的请求都发送到这里

real_server
含义:设置后端真实节点主机的权重等设置主要后端有几台这里就要设置几个

weight 1
含义:设置给每台的权重0表示失效(不知给他转发请求知道他恢复正常)默认是1

inhibit_on_failure
含义:表示在节点失败后把他权重设置成0而不是冲IPVS中删除

notify_up |
含义:设置检查服务器正常(UP)后要执行的脚本
notify_down |
含义:设置检查服务器失败(down)后要执行的脚本

注:keepalived检查机制说明
keepalived健康检查方式有:HTTP_GET|SSL_GET|TCP_CHECK|SMTP_CHECK|MISC_CHECK几种如下所示
```conf
#HTTP/HTTPS方式 
HTTP_GET|SSL_GET {      #设置健康检查方式

url {                   #设置要检查的URL可以有多个
path /                  #设置URL具体路径
digest <STRING>         #检查后的摘要信息这些摘要信息可以通过genhash命令工具获取                                   
status_code 200         #设置返回状态码
}
connect_port 80         #设置监控检查的端口
bindto  <IPADD>         #设置健康检查的IP地址
connect_timeout   3     #设置连接超时时间
nb_get_retry  3         #设置重连次数
delay_before_retry  2   #设置重连间隔
} 

#TCP方式  
TCP_CHECK     {
connect_port 80         #设置监控检查的端口
bindto  <IPADD>         #设置健康检查的IP地址
connect_timeout   3     #设置连接超时时间
nb_get_retry  3         #设置重连次数
delay_before_retry  2   #设置重连间隔
}
#SMTP方式 (这个可以用来给邮件服务器做集群)
SMTP_CHECK {
host {
connect_ip <IP ADDRESS>
connect_port <PORT>     #默认检查25端口
14 KEEPALIVED
bindto <IP ADDRESS>
}
connect_timeout <INTEGER>
retry <INTEGER>
delay_before_retry <INTEGER>
helo_name <STRING>|<QUOTED-STRING>
} 

#MISC方式 这个可以用来检查很多服务器只需要自己会些脚本即可
MISC_CHECK {
misc_path <STRING>|<QUOTED-STRING>  #外部程序或脚本
misc_timeout <INT>                  #脚本或程序执行超时时间
misc_dynamic                                              
#这个就很好用了可以非常精确的来调整权重是后端每天服务器的压力都能均衡调配这个主要是通过执行的程序或脚本返回的状态代码来动态调整weight值使权重根据真实的后端压力来适当调整不过这需要有过硬的脚本功夫才行哦
#返回0健康检查没问题不修改权重
#返回1健康检查失败权重设置为0
#返回2-255健康检查没问题但是权重却要根据返回代码修改为返回码-2例如如果程序或脚本执行后返回的代码为200#那么权重这回被修改为 200-2
}
```


以上就是keepalived的配置项说明虽然配置项很多但很多时候很多配置项保持默认即可




# lvs+keepalived配置实践
```bash
# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld

# 禁用selinux
setenforce 0
vi /etc/selinux/config

SELINUX=disabled

# 安装keepalived,ipvsadm
yum install keepalived ipvsadm -y

# 开启LVS服务器的IP路由转发功能
echo "1" > /proc/sys/net/ipv4/ip_forward
# 添加路由转发至sysctl.conf
vi /etc/sysctl.conf
net.ipv4.ip_forward = 1

sysctl -p

```
最简单的keepalived做HA
```bash
# 如果开启防火墙，请添加VRRP白名单
# For keepalived
# allow vrrp
-A INPUT -p vrrp -j ACCEPT
-A INPUT -p igmp -j ACCEPT
# allow multicast
-A INPUT -d 224.0.0.18 -j ACCEPT

# 编辑keepalived配置文件
vi /etc/keepalived/keepalived.conf

vrrp_sync_group VI_GOP_NC1_HA {
    group {
        VI_GOP_NC1_HA_PRI
    }
}

vrrp_instance VI_GOP_NC1_HA_PRI {
    state BACKUP
    interface bond0
    virtual_router_id 139
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.65.33.139/23 dev bond0
    }
}
```

## 配置LVS-NAT
DS
```bash
# Install keepalived
# Ubuntu
apt-get install keepalived ipvsadm
# CentOS
yum install keepalived ipvsadm

# update iptables
vim /etc/sysconfig/iptables

# For keepalived:
# allow vrrp 
-A INPUT -p vrrp -j ACCEPT
-A INPUT -p igmp -j ACCEPT
# allow multicast
-A INPUT -d 224.0.0.18 -j ACCEPT

# reload iptables
service iptables reload

# open ip_forward
echo "1" > /proc/sys/net/ipv4/ip_forward
# edit sysctl.conf
vi /etc/sysctl.conf
net.ipv4.ip_forward = 1

sysctl -p

# keepalived for lvs-nat
vim /etc/keepalived/keepalived.conf

vrrp_sync_group NC-MAIN-API {
    group {
        NC-MAIN-API-PUB
    }
}

vrrp_instance NC-MAIN-API-PUB {
    state BACKUP
    interface bond1
    virtual_router_id 222
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        xx.xx.xx.xx/25 dev bond1
    }
}

virtual_server xx.xx.xx.xx 15000 {
    delay_loop 6
    lb_algo rr
    lb_kind NAT
    protocol TCP

    real_server 10.71.12.69 15000 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 15000
        }
    }
    real_server 10.71.12.76 15000 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 15000
        }
    }
}

```

RS
修改默认网关指向NAT的VIP地址

配置LVS-DR
DS
```bash
# Install keepalived
# Ubuntu
apt-get install keepalived ipvsadm
# CentOS
yum install keepalived ipvsadm

# update iptables
vim /etc/sysconfig/iptables

# For keepalived:
# allow vrrp 
-A INPUT -p vrrp -j ACCEPT
-A INPUT -p igmp -j ACCEPT
# allow multicast
-A INPUT -d 224.0.0.18 -j ACCEPT

# reload iptables
service iptables reload

# open ip_forward
echo "1" > /proc/sys/net/ipv4/ip_forward
# edit sysctl.conf
vi /etc/sysctl.conf
net.ipv4.ip_forward = 1

sysctl -p

# keepalived for lvs-dr
vim /etc/keepalived/keepalived.conf

vrrp_sync_group GOP {
    group {
        VI_PRI_CONNECT
        VI_PRI_AUTH
    }
}

vrrp_instance VI_PRI_CONNECT {
    state BACKUP
    interface bond0
    virtual_router_id 128
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.65.32.28/23 dev bond0
    }
}

virtual_server 10.65.32.28 80 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 10.65.32.13 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
    real_server 10.65.32.14 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}

virtual_server 10.65.32.28 443 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 10.65.32.13 443 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 443
        }
    }
    real_server 10.65.32.14 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 443
        }
    }
}

vrrp_instance VI_PRI_AUTH {
    state BACKUP
    interface bond0
    virtual_router_id 129
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.65.32.29/23 dev bond0
    }
}

virtual_server 10.65.32.29 80 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 10.65.32.22 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
    real_server 110.65.32.23 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}

virtual_server 10.65.32.29 443 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 10.65.32.22 443 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 443
        }
    }
    real_server 110.65.32.23 443 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 443
        }
    }
}


# enable and start keepalived
systemctl start keepalived
systemctl enable keepalived
watch ipvsadm -L -n --stats

```

RS
Edit “/etc/sysconfig/network-scripts/ifcfg-lo” to patch bug in Centos 7 (if using Centos 7). Add TYPE=Loopback to the file.
Add loopback for each Virtual IP on each worker. E.g. first virtual IP create file “/etc/sysconfig/network-scripts/ifcfg-lo:0”.
Start adapters if not yet started
```bash
# add TYPE=Loopback
echo "TYPE=Loopback" >> /etc/sysconfig/network-scripts/ifcfg-lo
# add ifcfg-lo:0
cat > /etc/sysconfig/network-scripts/ifcfg-lo:0 << EOF
DEVICE=lo:0
IPADDR=10.65.32.28
NETMASK=255.255.255.255
ONBOOT=yes
EOF

# ifup lo:0
ifup lo:0

# add real_start
cat > /root/real_start.sh << EOF
#!/bin/bash
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
EOF

# chmod 755
chmod 755 /root/real_start.sh

# add real.service
cat > /usr/lib/systemd/system/real.service << EOF
[Unit]
Description=autostart lvs real
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/root/real_start.sh

[Install]
WantedBy=multi-user.target
EOF

# enable service
systemctl enable real.service


# lvs real server example
vim /root/lvs_real.sh

#!/bin/bash
### BEGIN INIT INFO
# Provides:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start realserver
# Description:       Start realserver
### END INIT INFO

# change the VIP to proper value
VIP=10.65.32.28

case "$1" in
    start)

    echo "Start REAL Server"
    /sbin/ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

    ;;

    stop)

    /sbin/ifconfig lo:0 down
    echo "Stop REAL Server"
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce

    ;;

    restart)

    $0 stop
    $0 start

    ;;

    *)

    echo "Usage: $0 {start|stop}"
    exit 1

    ;;
esac

exit 0
```
配置LVS-TUN
DS
```bash
# Install keepalived
# Ubuntu
apt-get install keepalived ipvsadm
# CentOS
yum install keepalived ipvsadm

# update iptables
vim /etc/sysconfig/iptables

# For keepalived:
# allow vrrp 
-A INPUT -p vrrp -j ACCEPT
-A INPUT -p igmp -j ACCEPT
# allow multicast
-A INPUT -d 224.0.0.18 -j ACCEPT

# reload iptables
service iptables reload

# open ip_forward
echo "1" > /proc/sys/net/ipv4/ip_forward
# edit sysctl.conf
vi /etc/sysctl.conf
net.ipv4.ip_forward = 1

sysctl -p

# keepalived for lvs-tun
vim /etc/keepalived/keepalived.conf

vrrp_sync_group GOP {
    group {
        VI_PRI_AUTH
    }
}

vrrp_instance VI_PRI_AUTH {
    state BACKUP
    interface em1
    virtual_router_id 11
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.10.36.11/23 dev em1
    }
}

virtual_server 10.10.36.11 80 {
    delay_loop 6
    lb_algo rr
    lb_kind TUN
    protocol TCP

    real_server 10.10.36.4 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
    real_server 10.10.36.7 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}

# enable and start keepalived
systemctl start keepalived
systemctl enable keepalived
watch ipvsadm -L -n --stats


# 编写DS脚本，推荐用keepalived配置文件
#!/bin/sh
# Startup script handle the initialisation of LVS
# chkconfig: - 28 72
# description: Initialise the Linux Virtual Server for TUN
#
### BEGIN INIT INFO
# Provides: ipvsadm
# Required-Start: $local_fs $network $named
# Required-Stop: $local_fs $remote_fs $network
# Short-Description: Initialise the Linux Virtual Server
# Description: The Linux Virtual Server is a highly scalable and highly
#   available server built on a cluster of real servers, with the load
#   balancer running on Linux.
# description: start LVS of TUN
LOCK=/var/lock/lvs-tun.lock
VIP=10.10.36.11
RIP1=10.10.36.4
RIP2=10.10.36.7
. /etc/rc.d/init.d/functions

start()    {
     PID=`ipvsadm -Ln | grep ${VIP} | wc -l`
     if    [ $PID -gt 0 ];

     then
           echo "The LVS-TUN Server is already running !"
     else
           #Load the tun mod
           /sbin/modprobe tun
           /sbin/modprobe ipip
           #Set the tun Virtual IP Address
           /sbin/ifconfig tunl0 $VIP broadcast $VIP netmask 255.255.255.255 up
           /sbin/route add -host $VIP dev tunl0
           #Clear IPVS Table
           /sbin/ipvsadm -C
           #The icmp recruit setting
           echo "0" >/proc/sys/net/ipv4/ip_forward
           echo "0" >/proc/sys/net/ipv4/conf/all/send_redirects
           echo "0" >/proc/sys/net/ipv4/conf/default/send_redirects
           #Set Lvs
           /sbin/ipvsadm -At $VIP:80 -s rr
           /sbin/ipvsadm -at $VIP:80 -r $RIP1:80 -i  -w 1
           /sbin/ipvsadm -at $VIP:80 -r $RIP2:80 -i  -w 1
           /bin/touch $LOCK
           #Run Lvs
           echo "starting LVS-TUN-DIR Server is ok !"
     fi
}

stop()    {
           #stop  Lvs server
           /sbin/ipvsadm -C
           /sbin/ifconfig tunl0 down >/dev/null
           #Remove the tun mod
           /sbin/modprobe -r tun
           /sbin/modprobe -r ipip
           rm -rf $LOCK
           echo "stopping LVS-TUN-DIR server is ok !"
}

status()  {
     if [ -e $LOCK ];
     then
         echo "The LVS-TUN Server is already running !"
     else
         echo "The LVS-TUN Server is not running !"
     fi
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        sleep 1
        start
        ;;
  status)
        status
        ;;
  *)
        echo "Usage: $1 {start|stop|restart|status}"
        exit 1
esac
exit 0
```
RS
```bash
# 在加载好ipip模块后就会有默认的tunl0隧道
modprobe ipip

# 添加VIP
# ifconfig tunl0 down
ifconfig tunl0 10.10.36.11 broadcast 10.10.36.11 netmask 255.255.255.255 up

# 添加路由
route add -host 10.10.36.11 tunl0

# 手动关闭ARP转发
echo '1' > /proc/sys/net/ipv4/conf/tunl0/arp_ignore 
echo '2' > /proc/sys/net/ipv4/conf/tunl0/arp_announce
echo '1' > /proc/sys/net/ipv4/conf/all/arp_ignore
echo '2' > /proc/sys/net/ipv4/conf/all/arp_announce 
echo '0' > /proc/sys/net/ipv4/conf/tunl0/rp_filter
echo '0' > /proc/sys/net/ipv4/conf/all/rp_filter 

# iptables允许ipip协议
iptables -I INPUT 1 -p 4 -j ACCEPT
vim /etc/sysconfig/iptables
-A INPUT -p ipv4 -j ACCEPT

# 编写RS启停脚本
vim /etc/init.d/lvs-tun

#!/bin/sh
#
# Startup script handle the initialisation of LVS
# chkconfig: - 28 72
# description: Initialise the Linux Virtual Server for TUN
#
### BEGIN INIT INFO
# Provides: ipvsadm
# Required-Start: $local_fs $network $named
# Required-Stop: $local_fs $remote_fs $network
# Short-Description: Initialise the Linux Virtual Server
# Description: The Linux Virtual Server is a highly scalable and highly
#   available server built on a cluster of real servers, with the load
#   balancer running on Linux.
# description: start LVS of TUN-RIP
LOCK=/var/lock/ipvsadm.lock
VIP=10.10.36.11
. /etc/rc.d/init.d/functions
start() {
     PID=`ifconfig | grep tunl0 | wc -l`
     if [ $PID -ne 0 ];
     then
         echo "The LVS-TUN-RIP Server is already running !"
     else
         #Load the tun mod
         /sbin/modprobe tun
         /sbin/modprobe ipip
         #Set the tun Virtual IP Address
         /sbin/ifconfig tunl0 $VIP netmask 255.255.255.255 broadcast $VIP up
         /sbin/route add -host $VIP dev tunl0
         echo "1" >/proc/sys/net/ipv4/conf/tunl0/arp_ignore
         echo "2" >/proc/sys/net/ipv4/conf/tunl0/arp_announce
         echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
         echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
         echo "0" > /proc/sys/net/ipv4/conf/tunl0/rp_filter
         echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
         /bin/touch $LOCK
         echo "starting LVS-TUN-RIP server is ok !"
     fi
}

stop() {
         /sbin/ifconfig tunl0 down
         echo "0" >/proc/sys/net/ipv4/conf/tunl0/arp_ignore
         echo "0" >/proc/sys/net/ipv4/conf/tunl0/arp_announce
         echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
         echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
         #Remove the tun mod
         /sbin/modprobe -r tun
         /sbin/modprobe -r ipip
         rm -rf $LOCK
         echo "stopping LVS-TUN-RIP server is ok !"
}

status() {
     if [ -e $LOCK ];
     then
        echo "The LVS-TUN-RIP Server is already running !"
     else
        echo "The LVS-TUN-RIP Server is not running !"
     fi
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        start
        ;;
  status)
        status
        ;;
  *)
        echo "Usage: $1 {start|stop|restart|status}"
        exit 1
esac
exit 0

# start lvs-tun
chmod 755 /etc/init.d/lvs-tun
service lvs-tun start
chkconfig lvs-tun on

# Nginx test
echo "rs1" > /usr/share/nginx/html/index.html
echo "rs2" > /usr/share/nginx/html/index.html

for i in {1..100}; do curl 10.10.36.11; sleep 0.5; done
```

这一步的主要目的是让 RS 禁言，在相对较新的版本中新增了两个内核参数 (kernel parameter)

第一个是 arp_ignore 定义接受到 ARP 请求时的相应级别
第二个是 arp_announce 定义将自己地址向外通告是的通告级别
第三个是 rp_filter 定义系统是否开启对数据包源地址的校验
总结: LVS/TUN 是所有模式中最最适用于跨网络跨地域地理位置的一种模式，需要注意的是:

若 DIR 和 RIP 在不同 lan 网络中，比如不同的网段，不同的 IDC 机房，就不需要设置 arp 仰制，不同网段中，arp 会被屏蔽掉，所以只需设置 ip tunne 以及报文反向验证即可；
若 DIR 和 RIP 在同一广播域中，需要和 LVS/DR 模式一样在所有的 RIP 上仰制 arp，防止 arp 响应导致 arp 表混乱，这样 lvs 就不能正常工作！
配置时除了配置 DIR，还需要需要配置后端 RS server，即在 tunl 上口配置 vip 地址（需要系统支持 tunl 才行），广播为为自己，此模式下无需开启路由转发功能！

配置LVS/DR和LVS/TUN混合模式
DS
```bash
# 关于3中模式的参数
[packet-forwarding-method]
       -g, --gatewaying  Use gatewaying (direct routing). This is the default.
       -i, --ipip  Use ipip encapsulation (tunneling).
       -m, --masquerading  Use masquerading (network access translation, or NAT).
       Note:  Regardless of the packet-forwarding mechanism specified, real servers for addresses for which there are interfaces on the local node will  be  use  the
       local  forwarding  method, then packets for the servers will be passed to upper layer on the local node. This cannot be specified by ipvsadm, rather it set by
       the kernel as real servers are added or modified.

# ipvsadm命令行混配
/sbin/ifconfig tunl0 10.10.36.11 broadcast 10.10.36.11 netmask 255.255.255.255 up
/sbin/route add -host 10.10.36.11 dev tunl0
/sbin/ipvsadm -At 10.10.36.11:80 -s rr
/sbin/ipvsadm -at 10.10.36.11:80 -r 10.10.36.4:80 -g -w 1
/sbin/ipvsadm -at 10.10.36.11:80 -r 10.10.36.7:80 -i -w 1

# keepalived混配
vrrp_sync_group GOP {
    group {
        VI_PRI_AUTH
    }
}

vrrp_instance VI_PRI_AUTH {
    state BACKUP
    interface em1
    virtual_router_id 11
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.10.36.11/23 dev em1
    }
}

virtual_server 10.10.36.11 80 {
    delay_loop 6
    lb_algo rr
    lb_kind DR
    protocol TCP

    real_server 10.10.36.4 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}

virtual_server 10.10.36.11 80 {
    delay_loop 6
    lb_algo rr
    lb_kind TUN
    protocol TCP

    real_server 10.10.36.7 80 {
        weight 100
        TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
        }
    }
}

# 检查结果可用
[root@d126027 wangao]# for i in {1..100}; do curl 10.10.36.11; sleep 0.5; done
rs2
rs1
rs2
rs1
rs2

[root@d126009 keepalived]# ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  10.10.36.11:80                    100      700        0    36700        0
  -> 10.10.36.4:80                      50      350        0    18350        0
  -> 10.10.36.7:80                      50      350        0    18350        0
```

RS
DR和TUN的模式基本不用做改动



