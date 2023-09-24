[LVS 部署之细枝末节](https://www.jianshu.com/p/76645e76f975)


## 开启 Linux 的路由转发功能
LVS 在 VS/NAT 方式下需要开启数据包转发 (ip_forward) 功能。因为在 LVS 的 VS/NAT 模式下，对 IP 数据进行负载均衡时，需要把多台真实服务器节点中的专网 IP 映射到同一个虚拟服务器的公网 IP 上；这就需要通过 NAT 技术对 IP 数据包进行转发，从而将 IP 数据包发送到真实服务器上进行处理。LVS 在 VS/DR 模式下，因为 director 的 DIP 与真实服务器节点的 RIP 在同一网段，所以不需要开启路由转发功能。LVS 在 VS/TUN 模式下，IP 数据包是通过 IP 隧道技术进行封包后再分发的方式到达真实服务器节点的，也不需要开启路由转发功能。

开启 Linux 的路由转发功能的方法很多，具体细节请参阅文章 [Linux ip_forward 数据包转发](https://www.jianshu.com/p/134eeae69281)。


## 配置真实服务器的 ARP 请求与响应策略
在 ARP 协议中，为了减少 arp 请求的次数，当主机接收到询问自己的 arp 请求的时候，就会把源 ip 和源 Mac 放入自 己的 arp 表里面，方便接下来的通讯。如果收到不是询问自己的包（arp 是广播的，所有人都收到），就会丢掉，这样不会造成 arp 表里面无用数据太多导致 有用的记录被删除。

在 LVS 的 VS/DR 模式下，当内网的真实服务器（Linux 主机）要发送一个到外部网络的 ip 包（LVS 负载器分配置过来的作业的处理结果），那么它就会请求路由器的 Mac 地址，发送一个 arp 请求，这个 arp 请求里面包括了自己的 ip 地址和 Mac 地址。而 linux 主机默认是使用 ip 数据包的源 ip 地址作为 arp 里面的源 ip 地址，而不是使用发送设备上面网络接口卡的 ip 地址。这样在 LVS 的 VS/DR 架构下，所有真实服务器在响应外部请求时的 IP 数据包的源地址都是同一个 VIP 地址，那么 arp 请求就会包括 VIP 地址和设备 Mac。而路由器收到这个 arp 请求就会更新自己的 arp 缓存，这样就会造成 ip 欺骗了，VIP 被抢夺，所以就会有问题。

所以当 LVS 运行在 VS/DR 模式下时，需要在所有真实服务器上修改 ARP 请求与响应策略，以保证以上问题不会发生。

因为在 lo（本地环回网络接口）上配置了 VIP，所以需要对真实服务器中的 ARP 请求与响应策略配置如下：

```
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.lo.arp_ignore=1

net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2

```

将以上代码段追加到 /etc/sysctl.conf 文件中，然后执行 sysctl -p 指令就可以。以上配置的具体含义请参阅 [Linux 内核参数 arp_ignore & arp_announce 详解](https://www.jianshu.com/p/a682ecae9693)。

## 在 VS/DR 模式下 VIP 、DIP 和 RIP 必须在同一网段吗？
在 VS/DR 模式下 VIP 、DIP 和 RIP 不需要在同一网段！

其中 VIP 必须是公网 IP；而 DIP 和 RIP 必须在同一网段（可以是任意网段的 IP，也可以是私网 IP），且需要节点主机的 RIP 可以把 IP 数据包发送到一个能把 IP 数据包路由到公网的路由器上。

其实 LVS 在 VS/DR 模式下的要求是 DIP 和 RIP 必须处于同一网段中。在实际的部署过程中发现如果在 Director 上 VIP 和 DIP 在同一网段、或在 RealServer 上 VIP 与 RIP 在同一网段，LVS 集群工作会很不稳定。因为当一个 IP 数据包需要发到默认网关时（在 RealServer 或 Director 上），Linux 主机不知道应该使用哪个接口（在同一子网中的 VIP 和 DIP/RIP），他可能会随机选一个，但这个不一定能成功。我感觉可以通过在 Linux 中配置路由表来解决，但没有验证（哪位同学如果有兴趣可以实践验证一下，如果能把验证结果反馈给我那是再好不过了）。

## 配置真实服务器的 反向路由过滤 策略
在 Linux 中用于对 网卡的反向路由过滤策略进行配置的内核参数是 rp_filter，有关此参数的详细介绍以及配置方式请参见 [Linux 内核参数 rp_filter](https://www.jianshu.com/p/16d5c130670b)。

LVS 在 VS/TUN 模式下，需要对 tunl0 虚拟网卡的反向路由过滤策略进行配置。最直接的办法是把其值设置为 0。
```
net.ipv4.conf.tunl0.rp_filter=0
net.ipv4.conf.all.rp_filter=0
```
因为 Linux 系统在对网卡应用反向路由过滤策略时，除了检查本网卡的 rp_filter 参数外，还会检查 all 配置项上的 rp_filter 参数，并使用这两个值中较大的值作为应用到当前网卡的反向路由过滤策略。所以需要同时把 `net.ipv4.conf.all.rp_filter` 参数设置为 0。

## 配置 tunl0 网卡
LVS 在 VS/TUN 模式下，需要在每个真实服务器上开启 tunl0 网卡，并把 VIP 配置到 tunl0 网卡上。有关 tunl0 网卡的说明可以参考一下 [Linux 中 IP 隧道模块浅析](https://www.jianshu.com/p/cb179f0bee1f)。

## LVS 在 VS/TUN 模式下 RealServer 上的防火墙配置
LVS 在 VS/TUN 模式下 因为 Director 主机需要通过 ipip 协议向 RealServer 分发数据包；所以需要在 RealServer 上配置防火墙，允许 ipip 协议的数据包通过。
```
iptables -I INPUT 1 -p 4 -j ACCEPT
```

## 配置日志

keepalived 默认将日志输出到系统日志/var/log/messages中，因为系统日志很多，查询问题时相对麻烦。

我们可以将 keepalived 的日志单独拿出来，这需要修改日志输出路径。
```bash
# 修改 Keepalived 配置
vi /etc/sysconfig/keepalived

# Options for keepalived. See `keepalived --help' output and keepalived(8) and
# keepalived.conf(5) man pages for a list of all options. Here are the most
# common ones :
#
# --vrrp               -P    Only run with VRRP subsystem.
# --check              -C    Only run with Health-checker subsystem.
# --dont-release-vrrp  -V    Dont remove VRRP VIPs & VROUTEs on daemon stop.
# --dont-release-ipvs  -I    Dont remove IPVS topology on daemon stop.
# --dump-conf          -d    Dump the configuration data.
# --log-detail         -D    Detailed log messages.
# --log-facility       -S    0-7 Set local syslog facility (default=LOG_DAEMON)
#

# 把 KEEPALIVED_OPTIONS=”-D” 修改为 KEEPALIVED_OPTIONS=”-D -d -S 0”，其中 -S 指定 syslog 的 facility
KEEPALIVED_OPTIONS="-D -d -S 0"

# 修改 /etc/rsyslog.conf 末尾添加
vi /etc/rsyslog.conf 
local0.*                                                /var/log/keepalived.log

# 重启日志记录服务
systemctl restart rsyslog

# 重启 keepalived
systemctl restart keepalived

# 此时可以从 /var/log/keepalived.log 查看日志了
tailf /var/log/keepalived.log
```

## ARP导致MAC地址冲突
```bash
[root@sg-gop-10-65-32-35 wangao]# arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
10.65.32.31              ether   48:8e:ef:7b:c6:0a   C                     bond0
10.65.32.83              ether   50:5d:ac:ed:89:dd   C                     bond0
10.65.32.254             ether   00:00:0c:9f:f0:ec   C                     bond0
10.65.32.252             ether   bc:16:65:68:07:81   C                     bond0
10.65.32.34              ether   50:1d:93:f5:eb:97   C                     bond0
10.65.32.8               ether   48:8e:ef:7c:0a:8d   C                     bond0
10.65.32.253             ether   18:e7:28:97:e5:01   C                     bond0
[root@sg-gop-10-65-32-35 wangao]# arp -d 10.65.32.31
[root@sg-gop-10-65-32-35 wangao]#
[root@sg-gop-10-65-32-35 wangao]#
[root@sg-gop-10-65-32-35 wangao]# telnet 10.65.32.31 12100
Trying 10.65.32.31...
Connected to 10.65.32.31.
Escape character is '^]'.

[root@sg-gop-10-65-32-35 wangao]# arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
10.65.32.31              ether   48:8e:ef:7b:c7:5a   C                     bond0
10.65.32.70              ether   00:2e:c7:3a:a5:b5   C                     bond0
10.65.32.83              ether   50:5d:ac:ed:89:dd   C                     bond0
10.65.32.254             ether   00:00:0c:9f:f0:ec   C                     bond0
10.65.32.252             ether   bc:16:65:68:07:81   C                     bond0
10.65.32.34              ether   50:1d:93:f5:eb:97   C                     bond0
10.65.32.8               ether   48:8e:ef:7c:0a:8d   C                     bond0
10.65.32.253             ether   18:e7:28:97:e5:01   C                     bond0


```