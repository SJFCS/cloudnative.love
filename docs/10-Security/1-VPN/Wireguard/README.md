可使用 tailscale 工具连接

 传统 VPN 是多个节点练到一个中心服务器的星型拓扑结构，wireguard 则是网状拓扑结构。 WireGuard 可以实现 NAT 打洞，也就是内网与内网客户端之间直接互连，不通过其它主机中转！

https://youtu.be/RkgL-NfPdYs

单从使用上来说。之前用 OpenVPN 的时候，就是在路由器上开个 server ，下个配置文件下个客户端就连上了。

但是 WireGuard ，感觉更像是一种异地组网工具，比如我现住址（ home-now ）和老家（ home-old ）都申请了公网 ipv4+DDNS ，我就可以通过 WireGuard 来让两边的网络互通。
假设我现住址用的 192.168.1.x ，老家 192.168.3.x 。从 192.168.1.2 发往 192.168.3.2 的包就会到 WireGuard 的节点（路由器），然后根据配置封装后发给 home-old 的 WireGuard 节点，再转发给对应设备。









