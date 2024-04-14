---
title: Linux网卡配置

categories:
  - Linux网络管理
series: 
  -
lastmod: '2020-01-10'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---


[nmtui  图形配置](https://www.cnblogs.com/xuefy/p/11286822.html)


https://segmentfault.com/a/1190000015476963

https://segmentfault.com/a/1190000011954814

bond mode为0,1,2,3,4时，bond口的MAC地址和成员口MAC地址相同；bond mode为5和6时，bond口的MAC地址不同于成员口的MAC地址。

## 网卡配置详解

### 默认网卡配置

`/etc/sysconfig/network-scripts/ifcfg-*`

```bash
TYPE=Ethernet            # 网络类型（通常是Ethemet）   
PROXY_METHOD=none
BROWSR_ONLY=no
BOOTPROTO=dhcp            # IP的配置方法[none|static|bootp|dhcp]（引导时不使用协议|静态分配IP|BOOTP协议|DHCP协议）
DEFROUTE=yes             
IPV4_FAILURE_FATAL=no
IPV6INIT=yes            # IPV6是否有效（yes/no） 
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=ac9b66bf-74fb-4bda-b89f-c66ff84c9571
# 获取新的UUID        # uuidgen ens33 将获取的UUID填入配置文件后重启网卡服务
# 验证UUID       # nmcli con | sed -n '1,2p' 
DEVICE=ens33             # 接口名（设备,网卡）
ONBOOT=yes       #ONBOOT是指明在系统启动时是否激活网卡，只有在激活状态的网卡才能去连接网络，进行网络通讯
```

>给服务器重装系统（centos）后发现对外访问是通的，但是从其他点却怎么也ping不通，ssh连接不上，把防火墙试试关了之后发现也没有用。最后发现是网卡配置问题，系统默认路由选择的是eth0网卡，而实际使用的eth1网卡，所以需要在eth1的配置文件内加上DEFROUTE=yes
>
>DPEERDNS=yes - 使用 DNS 选项的值替代 /etc/resolv.conf 中的配置
>注意：在5.0时代DNS服务器写在 /etc/resolv.conf 文件中，但到了6.0时代DNS可以写在/etc/resolv.conf但是此时需要在 /etc/sysconfig/network-scripts/ifcfg-eth0 文件中添加 PEERDNS=no 配置，不然每次重启网卡就会重写/etc/resolv.conf文件的内容，当然了也可以直接写在 /etc/sysconfig/network-scripts/ifcfg-eth0 文件中。
>
>**IPV4_FAILURE_FATAL|IPV6_FAILURE_FATAL=answer**: Where answer is one of the following:
>
>- **yes**: This interface is disabled if IPv4 or IPv6 configuration fails.
>- **no**: This interface is not disabled if configuration fails.

### 其他参数

```bash
USERCTL    [yes|no]（非root用户是否可以控制该设备）
HWADDR     MAC地址   
BROADCAST   广播地址
NETWORK    网络地址
NM_CONTROLLED=no 
# NM_CONTROLLED 设置 yes 表示网卡允许用 NetworkManager 程序管理。它可以降低网络配置使用难度，便于管理无线网络、虚拟专用网等网络连接，适合普通台式机和笔记本电脑使用。
# NM_CONTROLLED 设为 yes 或没有此行参数时，并有安装运行 NetworkManager 服务(必须具有HWADDR = \ <MAC-Address>行)。若编辑了网卡配置文件，需要先重启 NetworkManager 再重启 network 服务。
# NM_CONTROLLED 设置 no 表示网卡使用传统方式管理而不用 NetworkManager。好处是修改网卡配置文件后直接重启 network 就生效，不受 NetworkManager 干扰。适合用以太网连接的服务器使用。
# 要快速查询哪些网卡使用 NetworkManager 管理，可用 nmcli device status命令查询（不支持 CentOS 6），STATE 状态下非 unmanaged 值的网卡都由 NetworkManager 管理。
# 参考链接：https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-networkmanager/amp/
# 参考链接：https://access.redhat.com/solutions/44839
```

> 当新添加网卡后linux没自动生成网卡配置文件时，可以将默认配置复制一份，其中 HWADDR 和 UUID 删除或重新获取不能与其他网卡重复，通过`ip a`查看新网卡设备名字，把 DEVICE 和 NAME 设置为新网卡名。
>
> 获取新的UUID        # uuidgen ens33 
>
> 验证UUID       # nmcli con | sed -n '1,2p'
>
> 查看网卡MAC  cat /sys/class/net/eth0/address
>
> 查看网卡UUID：
> nmcli con show  或  nmcli con list
>
> 查看网卡mac地址：
> nmcli dev show  或  nmcli dev list
>
> 注：show用于7版本；list用于6版本；

### 永久配置网络地址

上述默认配置文件修改加入如下配置，配置完成后`systemctl restart network`重启网卡服务生效

```bash
BOOTPROTO=static #静态IP
IPADDR= #本机地址
NETMASK= #子网掩码
GATEWAY= #默认网关
# DNS1=
# DNS2=
```

永久别名

```
vi ifcfg-eth0:0 

DEVICE=eth0:0                 //虚拟网络接口                                 
ONBOOT=yes                    //系统启动时激活
BOOTPROTO=static             //使用静态ip地址                
IPADDR=192.168.6.100          //该虚拟网络接口的ip别名，随意
NETMASK=255.255.255.0         //子网掩码，对应ip别名
GATEWAY=192.168.6.1           //网关，对应ip别名
HWADDR=00:10:5A:5E:B1:E4      //网卡MAC地址，无需更改                   
USERCTL=no                    //是否给予非root用户设备管理权限
```

### 临时修改网络地址

可以通过 ip、nmlic、ifconfig管理命令进行配置

配置IP

```bash

ip a                               # 显示所有网络地址，同 ip address
ip a show eth1                     # 显示网卡 IP 地址
ip a add 172.16.1.23/24 dev eth1   # 添加网卡 IP 地址（可添加多个IP）
ip addr add 192.168.2.2/24 dev eth0 label eth0:0 # 添加网卡别名并指定 IP 地址

ip a del 172.16.1.23/24 dev eth1   # 删除网卡某个 IP 地址
ip addr flush eth1                 # 删除网卡的所有 IP 地址
ip addr flush dev eth0 label eth0:0# 删除网卡别名的所有 IP 地址

ip link show dev eth0              # 显示网卡设备属性
ip link set eth1 up                # 激活网卡
ip link set eth1 down              # 关闭网卡
ip link set eth1 address {mac}     # 修改 MAC 地址
ip neighbour                       # 查看 ARP 缓存
ip route                           # 查看路由表
ip route add 10.1.0.0/24 via 10.0.0.253 dev eth0    # 添加静态路由
ip route del 10.1.0.0/24           # 删除静态路由

ifconfig                           # 显示所有网卡和接口信息
ifconfig -a                        # 显示所有网卡（包括开机没启动的）信息
ifconfig eth0                      # 指定设备显示信息
ifconfig eth0 up                   # 激活网卡
ifconfig eth0 down                 # 关闭网卡
ifconfig eth0 192.168.120.56       # 给网卡配置 IP 地址（只能配置一个，重复执行会替换当前IP）
ifconfig eth0 10.0.0.8 netmask 255.255.255.0 up     # 配置 IP 并启动
ifconfig eth0:0 192.168.0.100/24 up                 # 添加网卡别名并指定 IP 地址，
ifconfig eth0:1 del 192.168.0.100                   # 删除 IP 地址
ifconfig eth0 hw ether 00:aa:bb:cc:dd:ee            # 修改 MAC 地址


# 2、命令添加网卡
nmcli  connection  add  con-name  eth1  ifname  eth1  type  ethernet
# 3、网卡配置ip
nmcli  conn  modify  eth1  ipv4.method  manual  ipv4.addr  10.1.1.18/24  connection.autoconnect  yes
# 4、启动网卡
nmcli  conn  up  eth1
# 5、关闭网卡
nmcli  conn  down  eth1
# 6、添加网关
nmcli  connection  modify  eth1  ipv4.gateway  10.1.1.2
# 设备展示 您可以使用-p（pretty）选项使该输出更易于阅读，如下所示：
nmcli -p

```

![img](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/https/img2018.cnblogs.com/blog/1482552/201809/2021.08.31-08:12:57-1482552-20180930195218267-1123602572.png)

配置DNS

```bash
vi /etc/resolv.conf 加入 nameserver 8.8.8.8 
```

配置网关

```bash
route add default gw 192.168.0.1 dev eth0 
```

## 更改网卡名

### 1、临时生效-非Udev

*注意：对于远程联网的机器，要确保你有两个网卡：例如一个内网一个外网，否则你在关闭网卡时，会失去与主机的连接*

```bash
ip link set peth0 name eth0   //改名之前把网卡关闭  重启失效

ifup {interface}      //会读取配置文件配上网卡  速度比ip link set eth0 up慢，同时会配置默认路由。
ifdown {interface}    //网卡down不显示之前配置的任何配置信息IP

ip link set eth0 down  //关闭eth0 网络接口，删除路由
ip link set eth0 up   //打开eth0 网络接口,仅仅启用网卡，但是不会配置路由；

nmcli device connect eth0    ###启用eth0接口
nmcli device disconnect eth0  ###关闭eth0接口

ifconfig peth0 down
ifconfig eth0 up
```

自定义脚本处理

```bash
#!/bin/bash
#如将网口ens33改为eth0
ip link set ens33 down
ip link set ens33 name eth0
ip link set eth0 up

mv /etc/sysconfig/network-scripts/ifcfg-{ens33,eth0}

sed -ire "s/NAME=\"ens33\"/NAME=\"eth0\"/" /etc/sysconfig/network-scripts/ifcfg-eth0

sed -ire "s/DEVICE=\"ens33\"/NAME=\"eth0\"/" /etc/sysconfig/network-scripts/ifcfg-eth0

MAC=$(cat /sys/class/net/eth0/address)

echo -n 'HWADDR="'$MAC\" >> /etc/sysconfig/network-scripts/ifcfg-eth0
```

### 2、自定义网卡名，修改Udev需重启，永久生效

参考链接：https://blog.51cto.com/bella41981/2361482

参考链接：https://blog.csdn.net/u010039418/article/details/79260553

参考链接：https://unix.stackexchange.com/questions/205010/centos-7-rename-network-interface-without-rebooting

> centos7.3 和7.4不同  本章只讨论7.4

CentOS6中可以通过修改/etc/udev/rules.d/70-persistent-net.rules中mac与NAME的映射关系来重命名网卡名称，

CentOS7.4新版本系统引入了systemd组件，由该组件管理生成udev规则，文件目录变为  /usr/lib/udev/rules.d/60-net.rules。

如果将“ net.ifnames = 0 biosdevname = 0”添加到内核引导字符串中，以返回到网卡的旧命名方案（eth*），则可以删除

```
ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{type}=="1", PROGRAM="/lib/udev/rename_device", RESULT=="?*", NAME="$result"
```

取而代之的

```
ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{address}=="00:50:56:8e:3f:a7", NAME="eth123"s.
```

每个网卡需要一个条目。确保使用正确的 MAC 地址并更新 NAME 字段。如果您没有使用“ net.ifnames = 0 biosdevname = 0”，请小心，因为这里可能有意外后果。

==**centos6**==

1.修改 /etc/udev/rules.d/70-persistent-net.rules 文件中网卡名
2.ethtool -i eth2 查看网卡驱动模块名
            ethtool -i eth2 || dmesg | grep –i eth0 查看驱动模块信息(两个命令都可以使用)
            dmesg //显示开机加载的网卡信息 grep –i eth0 过滤信息 (没有太大用)
            ethtool eth2 //这个命令是查看网卡更详细的信息的比如工作模式是否为双工模式
3.modprobe -r e1000 卸载网卡模块
            modprobe -r e1000 || rmmod e1000 卸载模块(两个命令都可以使用 )

4.modprobe e1000 重新加载网卡模块
5.修改/etc/sysconfig/network-scripts中网卡的配置文件(使其格式为ifcfg-网卡名)
6.重启网卡服务/etc/inint.d/network restart 、service NetworkManager restart

![CentOS6修改网卡名](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Linux%E7%BD%91%E5%8D%A1%E7%BB%91%E5%AE%9A/2021.03.30-11:33:08-D-assets-Linux%E7%BD%91%E5%8D%A1%E7%BB%91%E5%AE%9A-93585e5fc0aa86ca4cf05415e0cac962.png)

1、dmesg |grep -i eth

ethtool -i eth1

卸载网卡驱动：modprobe -r e1000

装载网卡驱动：modprobe e1000 

2、编辑 /etc/udev/rules.d/70-persistent-net.rules #注意mac 地址

```

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:25:24:c8", ATTR{type}=="1", KERNEL=="eth*", NAME="eth1"

修改网卡配置文件、重启

```

脚本

```bash
[root@centos6 network-scripts]# cat f1.sh 
VERSION=`egrep -o "[0-9]+" /etc/centos-release | head -1`

dev_list() {
    echo -e "\033[31mthe device list as following:\033[0m\n==========="
    ip a | grep mtu | awk -F "[ :]+" '{print $2}' | grep -v lo
    echo "==========="
}

change_name() {
    if [ ${VERSION} != "6" ];then
        echo "only support centos6";exit 
    fi

    dev_list

    read -p "please select a device:" OLD_NAME
    read -p "please input a new device name:" NEW_NAME

    /sbin/ifconfig ${OLD_NAME} &> /dev/null
    if [ $? -ne 0 ];then
        echo -e "\033[31mdevice [${OLD_NAME}] do not found\033[0m";exit
    fi

    DRIVER=`ethtool -i ${OLD_NAME} | awk -F "[: ]+" '/driver/{print $2}'`
    cd /etc/sysconfig/network-scripts/ && \
    sed -i "/DEVICE=/s/${OLD_NAME}/${NEW_NAME}/" ifcfg-${OLD_NAME}
    sed -i "/NAME=/s/${OLD_NAME}/${NEW_NAME}/" ifcfg-${OLD_NAME}
    sed -i "/${OLD_NAME}/s/${OLD_NAME}/${NEW_NAME}/" /etc/udev/rules.d/70-persistent-net.rules
    mv ifcfg-${OLD_NAME} ifcfg-${NEW_NAME}
    modprobe -r $DRIVER
    modprobe $DRIVER
    /etc/init.d/network restart
}

change_name
```

### 3、禁用预测命名规则

禁用该可预测命名规则，是网卡名变为ethX。你可以在启动时传递“net.ifnames=0 biosdevname=0 ”的内核参数。

1. 安装系统引导界面按Tab键
   空格，输入net.ifnames=0 biosdevname=0，回车即可

![12.png](D:%5Cassets%5CLinux%E7%BD%91%E5%8D%A1%E7%BB%91%E5%AE%9A%5C1597728193823079.png)

2. 装系统后，修改网卡

```bash
vi /etc/default/grub
# GRUB_CMDLINE_LINUX下添加参数：net.ifnames=0 biosdevname=0,如下
GRUB_CMDLINE_LINUX="crashkernel=auto net.ifnames=0 biosdevname=0 后面默认配置保留不动"
#重新生成配置
grub2-mkconfig -o /boot/grub2/grub.cfg
#重命名原网卡配置文件,如cp -p /etc/sysconfig/network-scripts/ifcfg-ens192 /etc/sysconfig/network-scripts/ifcfg-eth0
cp -p /etc/sysconfig/network-scripts/ifcfg-<ifname> /etc/sysconfig/network-scripts/ifcfg-<new-ifname>
#修改原配置文件中的NAME及DEVICE属性,改为新值
vi /etc/sysconfig/network-scripts/ifcfg-eth0
NAME=eth0
DEVICE=eth0

reboot
```

