---
title: ethtool

categories:
  - Linux网络管理
series: 
  - 
lastmod: '2020-04-17'

featuredImage: 
authors: songjinfeng
draft: false
toc: true
---




http://www.voidcn.com/article/p-reuwslap-brm.html

## **命令描述：**
ethtool 是用于查询及设置网卡参数的命令。

## **使用概要：**

```
ethtool -p ethx    //点灯
ethtool ethx       //查询ethx网口基本设置，其中 x 是对应网卡的编号，如eth0、eth1等等
ethtool –h         //显示ethtool的命令帮助(help)
ethtool –i ethX    //查询ethX网口的相关信息 
ethtool –d ethX    //查询ethX网口注册性信息
ethtool –r ethX    //重置ethX网口到自适应模式
ethtool –S ethX    //查询ethX网口收发包统计
ethtool –s ethX [speed 10|100|1000] [duplex half|full]  [autoneg on|off]        //设置网口速率10/100/1000M、设置网口半/全双工、设置网口是否自协商
```

## **使用举例：**

### **1）查询eth0网口基本设置（网卡速率是百兆还是千兆等）:**

```
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Full 
        Supported pause frame use: No               //是否支持热插拔
        Supports auto-negotiation: Yes               //是否支持自动协商
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Full 
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s                     //速率
        Duplex: Full                               //全双工
        Port: Twisted Pair                      //电口
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: Unknown
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes
```

### **2）查看网卡的驱动信息：**

```
# ethtool -i eth0 //查看网卡的驱动版本
driver: e1000
version: 7.3.21-k8-NAPI
firmware-version: 
bus-info: 0000:02:01.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
```

### **3）查看网卡的输入流量，输出流量，输入包，输出包，输入的广播，输出的广播，输入的网络错包，输出的网络错包等：**

```
# ethtool -S eth1 
   NIC statistics:
     rx_packets: 58068300
     tx_packets: 87124083
     rx_bytes: 1589713008
     tx_bytes: 2165825901
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
```

### **解决相关问题：**

最近碰到的一个问题: 将eth1挂到ovs dpdk网桥上，将网桥删除以后，再使用 ifconfig -a ，发现eth3不见了。

解决过程：

首先使用如下两条命令，可以找出eth1的bus-info: 0000:03:00.1

```
# lspci|grep Eth // 列出机器中的PCI设备信息,如声卡，显卡，Modem，网卡等信息
02:00.1 Ethernet controller: Advanced Micro Devices, Inc. [AMD] 79c970 [PCnet32 LANCE] (rev 10)
03:00.1 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI Fast Ethernet (rev 91)

# ethtool -i eth0 //查看网卡的驱动版本
driver: ixgbe
version: 7.3.21-k8-NAPI
firmware-version: 
bus-info: 0000:02:00.1           // 对应bus-info
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
```

接下来做两件事：

```
# 解绑设备驱动
echo "0000:03:00.1" > /sys/bus/pci/devices/0000\:03:00.1/driver/unbind

# 重新绑定驱动
echo "0000:03:00.1" > /sys/bus/pci/driver/ixgbe/bind
```

OK！ ifconfig -a 又可以看见eth1了！

## **相关知识点：**

/sys/bus/pci/devices/目录下列出了系统中所有pci设备的名称（不管有没有安装对应的驱动程序），pci设备的名称就是相应的pci地址（即“域：pci总线号：槽位号：功能号”）。

/sys/bus/pci/drivers目录下则列出了所有pci设备的驱动。

相关目录下会有一些别的文件，像bind用来指定某个pci设备由此驱动接管，unbind则起相反的作用。通常，一个驱动都有自己支持的设备型号的列表。