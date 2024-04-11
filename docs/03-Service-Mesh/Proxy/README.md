---
title: Proxy
sidebar_position: 2
---

## Service Proxy

有两种类型的网络代理：

1. 反向代理(Reverse Proxy): 可理解成**服务端代理**，是服务端配置的一个中间代理服务器，负责将客户端的请求转发给后端服务器。 
   - 常被用于流量负载均衡(Load Balancer)、API网关、实现缓存/https/安全等功能。
   - ![reverse-proxy-flow.svg](_imgs/reverse-proxy-flow.svg)
2. 正向代理(Forward Proxy)/转发代理: 可理解成**客户端代理**，是客户端配置的一个中间代理服务器，负责将客户端的请求转发给后端服务器。 
   - 常被用于突破某些服务端的访问限制，或者在网络上隐藏自己的真实身份（Tor 洋葱代理）。
   - 也可用于添加某些访问限制：比如学校/企业可以通过前向代理禁止用户访问 一些娱乐网站。
   - ![forward-proxy-flow.svg](_imgs/forward-proxy-flow.svg)


下面介绍几种当下比较流行的代理软件：

全能选手，既可用做代理，又可用做 Web 服务器：

1. Nginx: 使用最广泛，最年长，性能也几乎是最高的，但是配置稍显复杂，学习起来有些门槛。
2. Caddy: 新兴的 Web Server & Network-Proxy。配置比 Nginx 简单，支持自动配置 SSL 证书，默认启用 HTTP2/HTTPS。
   - 是 go 语言写的，性能相比 Nginx 要弱一些，同时内存消耗比 Nginx 大很多。

专用代理软件：

1. Traefik: 一个纯粹的代理软件，支持自动配置 SSL 证书，配置很简单，功能相当丰富，还有好看的 Web UI。
   - Traefik 相对的，性能也要比 Nginx 差。
2. Envoy: Istio 钦定代理，在服务网格中专门负责流量转发
3. Linkerd: 用 rust 写的轻量高效的代理，值得一看。
4. [OpenResty](https://github.com/openresty/openresty): 基于 Nginx+Lua Web 平台，很多网关/代理的底层都是它。
   1. APISIX: 基于 Openresty 开发的 API 网关，国产项目。
      - 其核心贡献者同时也是 Openresty 社区的核心贡献者，相当活跃，性能也很高，值得考虑。
   2. Kong: 和 APISIX 一样都是基于 Openresty，虽然 Stars 很多，但是 APISIX 有后发优势，性能比 Kong 要好很多。
5. HAProxy: 一个 C 专用负载均衡器，单纯做负载均衡，它的性能比 Nginx 还要好些。
   - 但是纯四层负载均衡 LVS 性能比它更高，另外它的代码结构也不如 nginx，导致二次开发难度大，社区也就小很多。
   - 所以不推荐使用。

高性能的 4 层代理，只关注第四层，因此能获得更高的性能：

- ipvs: 有二十多年历史的 4 层负载均衡技术，linux 内核模块。

在四层负载均衡方面，也有一些将 ipvs/eBPF 及其他技术结合起来的尝试，比如：

- [性能提升40%: 腾讯 TKE 用 ipvs+eBPF 绕过 conntrack 优化 K8s Service](https://juejin.cn/post/6844904198752960520)
- [网易数帆基于 DPDK 的高性能四层负载均衡实践](https://www.infoq.cn/article/hlhteohg8elx6eyveifl)
- [katran](https://github.com/facebookincubator/katran): Facebook 开源的，基于 eBPF 的新一代 4 层负载均衡。一个 C++ 库和BPF程序，用于构建高性能第 4 层负载平衡转发平面。Katran 利用XDP infrastructure 内核为快速数据包处理提供内核设施。


如果你需要插件热加载（hot-plugin）那目前基本上就只有 openresty(lua) 系与 envoy(wasm) 可选，其他项目加个插件还得重新编译整个代理。



## LVS Nginx Haproxy 对比
1. LVS 特点是：

首先它是基于 4 层的网络协议的，抗负载能力强，对于服务器的硬件要求除了网卡外，其他没有太多要求；
配置性比较低，这是一个缺点也是一个优点，因为没有可太多配置的东西，大大减少了人为出错的几率；
应用范围比较广，不仅仅对 web 服务做负载均衡，还可以对其他应用（ mysql ）做负载均衡；
LVS 架构中存在一个虚拟 IP 的概念，需要向 IDC 多申请一个 IP 来做虚拟 IP。

2. Nginx 负载均衡器的特点是：

工作在网络的 7 层之上，可以针对 http 应用做一些分流的策略，比如针对域名、目录结构；
Nginx 安装和配置比较简单，测试起来比较方便；
也可以承担高的负载压力且稳定，一般能支撑超过上万次的并发；
Nginx 可以通过端口检测到服务器内部的故障，比如根据服务器处理网页返回的状态码、超时等等，并且会把返回错误的请求重新提交到另一个节点，不过其中缺点就是不支持 url 来检测；
Nginx 对请求的异步处理可以帮助节点服务器减轻负载；
Nginx 能支持 http 和 Email，这样就在适用范围上面小很多；
默认有三种调度算法: 轮询、weight 以及 ip_hash （可以解决会话保持的问题），还可以支持第三方的 fair 和 url_hash 等调度算法；

3. HAProxy 的特点是：

HAProxy 是工作在网络 7 层之上；
支持 Session 的保持，Cookie 的引导等；
支持 url 检测后端的服务器出问题的检测会有很好的帮助；
支持的负载均衡算法：动态加权轮循(Dynamic Round Robin)，加权源地址哈希(Weighted Source Hash)，加权 URL 哈希和加权参数哈希(Weighted Parameter Hash)；
单纯从效率上来讲 HAProxy 更会比 Nginx 有更出色的负载均衡速度；
HAProxy 可以对 Mysql 进行负载均衡，对后端的 DB 节点进行检测和负载均衡。



<!-- ## HA Stack

Pacemaker 是 Heartbeat 的继承者，基于资源的故障检测、动态资源迁移、复杂的资源依赖关系管理等。

Pacemaker最初是作为Heartbeat的升级版本而创建的。Heartbeat在2008年停止了开发，Pacemaker继续开发和维护，并成为了一个较好的替代方案。

Pacemaker比Heartbeat提供了更多的功能和更强的灵活性，并且可以与不同的资源代理一起使用，如OCF（Open Cluster Framework）和STONITH（Shoot The Other Node In The Head，一种用于强制关闭故障节点的技术）。因此，Pacemaker可以被看作是Heartbeat的一种升级版或者替代方案。

Corosync 是一个高可用性的通信库，为集群提供了一个可靠的通信层，可以与 Pacemaker 配合使用。

Keepalived 是一个基于 VRRP 协议的工具，用于实现虚拟 IP 地址的故障转移。

DRBD是一种数据复制技术，它可以在多个节点之间同步块设备（如硬盘、分区等）的数据，以提高数据的可用性和冗余性。DRBD可以与任何文件系统一起使用，并且对应用程序透明，因此应用程序不需要进行修改。DRBD通常用于构建具有高可用性和灾难恢复能力的数据存储系统。

OCFS2是一种分布式文件系统，它允许多个节点同时访问相同的文件系统，并提供了文件锁定和一致性保证等功能。OCFS2通常用于需要多节点访问相同文件系统的场景，如数据库集群等。


如果多个进程同时读写同一个块设备，可能会发生竞争条件和数据不一致的问题。这是因为块设备通常是以磁盘或闪存等物理媒介为基础的，而这些物理媒介通常不能同时被多个进程访问或修改。因此，操作系统通常会使用同步机制（如互斥锁）来保证只有一个进程能够对块设备进行读写操作，以避免数据的不一致性。

只用drbd设备的话，当两个节点同时网一个文件系统写数据会导致文件系统崩溃，而应以OCFS2集群文件系统，会提供一个文件锁管理器，防止文件系统崩溃。


[具有 DRBD 和 Pacemaker 的高可用 NFS 存储](https://documentation.suse.com/sle-ha/15-SP1/html/SLE-HA-all/art-sleha-nfs-quick.html)

[红帽高可用性群集中的主动/被动 NFS 服务器](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_administration/ch-nfsserver-haaa)


[将 LVM 与 DRBD 结合使用](https://docs.piraeus.daocloud.io/books/drbd-90-user-guide/page/9-using-lvm-with-drbd)

[drbd+ocfs2构建的共享存储方案](https://developer.aliyun.com/article/484016)

[使用 Pacemaker、DRBD、Corosync 和 MySQL 实现近 HA 的主动-被动集群](https://houseofbrick.com/blog/active-passive-cluster-for-near-ha-using-pacemaker-drbd-corosync-and-mysql/)


caddyserver 反代例子：https://ichon.me/post/1027.html

[higress](https://higress.io/zh-cn/)
[nginx-proxy-manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
[OpenSergo](https://opensergo.io/)


- [What is a reverse proxy? - cloudflare](https://www.cloudflare.com/learning/cdn/glossary/reverse-proxy/)
- https://blog.csdn.net/lilygg/article/details/89538862
- https://www.cnblogs.com/kevingrace/p/6137881.html
- https://www.cnblogs.com/losbyday/p/5844463.html
- https://www.cnblogs.com/kevingrace/p/6249028.html
- https://www.cnblogs.com/kevingrace/p/5740940.html -->