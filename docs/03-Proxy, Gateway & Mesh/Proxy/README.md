# Proxy
 [三大主流负载均衡器LVS、Nginx、HAproxy详解](https://blog.csdn.net/lilygg/article/details/89538862)
- [linux负载均衡总结性说明（四层负载/七层负载）](https://www.cnblogs.com/kevingrace/p/6137881.html)
- https://www.cnblogs.com/losbyday/p/5844463.html

[Katran](https://github.com/facebookincubator/katran) 一个 C++ 库和BPF程序，用于构建高性能第 4 层负载平衡转发平面。Katran 利用XDP infrastructure 内核为快速数据包处理提供内核设施。



## LVS 特点是：

首先它是基于 4 层的网络协议的，抗负载能力强，对于服务器的硬件要求除了网卡外，其他没有太多要求；
配置性比较低，这是一个缺点也是一个优点，因为没有可太多配置的东西，大大减少了人为出错的几率；
应用范围比较广，不仅仅对 web 服务做负载均衡，还可以对其他应用（ mysql ）做负载均衡；
LVS 架构中存在一个虚拟 IP 的概念，需要向 IDC 多申请一个 IP 来做虚拟 IP。

## Nginx 负载均衡器的特点是：

工作在网络的 7 层之上，可以针对 http 应用做一些分流的策略，比如针对域名、目录结构；
Nginx 安装和配置比较简单，测试起来比较方便；
也可以承担高的负载压力且稳定，一般能支撑超过上万次的并发；
Nginx 可以通过端口检测到服务器内部的故障，比如根据服务器处理网页返回的状态码、超时等等，并且会把返回错误的请求重新提交到另一个节点，不过其中缺点就是不支持 url 来检测；
Nginx 对请求的异步处理可以帮助节点服务器减轻负载；
Nginx 能支持 http 和 Email，这样就在适用范围上面小很多；
默认有三种调度算法: 轮询、weight 以及 ip_hash （可以解决会话保持的问题），还可以支持第三方的 fair 和 url_hash 等调度算法；

## HAProxy 的特点是：

HAProxy 是工作在网络 7 层之上；
支持 Session 的保持，Cookie 的引导等；
支持 url 检测后端的服务器出问题的检测会有很好的帮助；
支持的负载均衡算法：动态加权轮循(Dynamic Round Robin)，加权源地址哈希(Weighted Source Hash)，加权 URL 哈希和加权参数哈希(Weighted Parameter Hash)；
单纯从效率上来讲 HAProxy 更会比 Nginx 有更出色的负载均衡速度；
HAProxy 可以对 Mysql 进行负载均衡，对后端的 DB 节点进行检测和负载均衡。