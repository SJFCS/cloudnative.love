brctl 用来管理以太网桥，在内核中建立，维护，检查网桥配置。一个网桥一般用来连接多个不同的网络，这样这些不同的网络就可以像一个网络那样进行通讯。

网桥是一种在链路层实现中继，对帧进行转发的技术，根据 MAC 分区块，可隔离碰撞，将网络的多个网段在数据链路层连接起来的网络设备。网桥工作在数据链路层，将两个 LAN 连起来，根据 MAC 地址来转发帧，可以看作一个 “底层的路由器”
      
在网桥上每个以太网连接可以对应到一个物理接口，这些以太网借口组合成一个大的逻辑的接口，这个逻辑接口对应于桥接网络。
```bash
brctl addbr <name>  创建一个名为 name 的桥接网络接口
brctl delbr <name>  删除一个名为 name 的桥接网络接口，桥接网络接口必须先 down 掉后才能删除。
brctl show          显示目前所有的桥接接口

brctl addif <brname> <ifname>  把一个物理接口 ifname 加入桥接接口 brname 中，所有从 ifname 收到的帧都将被处理，就像网桥处理的一样。所有发往 brname 的帧，ifname 就像输出接口一样。当物理以太网加入网桥后，据处于混杂模式了，所以不需要配置 IP。

brctl delif <brname> <ifname>  从 brname 中脱离一个 ifname 接口
brctl show <brname>   显示一些网桥的信息
```
STP 多个以太网桥可以工作在一起组成一个更大的网络，利用 802.1d 协议在两个网络之间寻找最短路径，STP 的作用是防止以太网桥之间形成回路，如果确定只有一个网桥，则可以关闭 STP。
```bash
brctl stp <bridge> <state>  控制网桥是否加入 STP 树中，<state > 可以是 'on' 或者 'yes' 表示加入 stp 树中，这样当 lan 中有多个网桥时可以防止回环，'off' 表示关闭 stp。

     brctl setbridgeprio <bridge> <priority>
     设置网桥的优先级，<priority> 的值为 0-65535，值小的优先级高，优先级最高的是根网桥。

     brctl setfd <bridge> <time> 
     设置网桥的 'bridge forward delay' 转发延迟时间，时间以秒为单位

     brctl sethello <bridge> <time> 
     设置网桥的 'bridge hello time' 存活检测时间

     brctl setmaxage <bridge> <time>
     设置网桥的 'maximum message age' 时间

     brctl setpathcost <bridge> <port> <cost>
    设置网桥中某个端口的链路花费值

     brctl  setportprio  <bridge>  <port> <priority>
     设置网桥中某个端口的优先级
```

实例 1：简单网桥
```bash
eth0 eth1 组合成一个网桥 br0
brctl addbr br0   创建一个网桥 br0 实例
brctl addif br0 eth0   把 eth0 加入网桥 br0 中
brctl addif br0 eth1   把 eth1 加入网桥 br0 中
ifconfig eth0 0.0.0.0  物理网卡处于混杂模式，不用配置 IP
ifconfig eth1 0.0.0.0
ifconfig br0 10.1.1.2  只需要给网桥配置一个 IP 即可
```
实例 2：创建多网桥通讯
创建多网桥通过 filtering/NATting 进行通讯，在有四个网卡的机器上，把两个网卡划入一个 lan 中，IP 是 10.16.0.254，另外两个网卡划入一个 lan 中，IP 是 192.168.10.1。
```bash
brctl addbr br_10
brctl addif br_10 eth0
brctl addif br_10 eth1
ifconfig br_10 10.16.0.254

brctl addbr br_192
brctl addif br_192 eth2
brctl addif br_192 eth3
ifconfig br_192 192.168.10.1
```
现在就有了两个本地的网卡 br_10 br_192，打开 ipforwd，假如 192.168.10.2 是在 192.* 网段被允许访问访问 10.* 网段：
```bash
ipchains -P forward REJECT
ipchains -A forward -s 192.168.10.2/32 -d 10.0.0.0/8 -i br_10 -j ACCEPT
```